local E, L, V, P, G = unpack(ElvUI)
local Mod = E:GetModule('ElvUI_AdditionalFeature')
local NP = E:GetModule('NamePlates')

-- ==========================================
-- 模块 1：施法条打断 Bug 修复与自定义变色逻辑
-- ==========================================
-- 功能说明：
-- 1. 修复 ElvUI 原生同时开启“打断来源”和“施法目标”时，文本重叠的视觉 Bug。
-- 2. 在目标施法被成功打断时，将施法条颜色替换为自定义颜色。
function Mod:OnCastbarInterrupted(castbar, unit, spellID, interruptedBy)
    -- 【Bug 修复】：一旦判定被打断，强制清空目标文本 (TargetText)。
    -- 这样就能腾出空间给打断者文本（例如：[被 Player 打断]），彻底避免文字重叠。
    if castbar and castbar.TargetText then
        castbar.TargetText:SetText("")
    end

    local db = E.db.elvui_additionalfeature
    if not db.eAF_enableInterruptColor then return end

    local colorToUse = nil
    -- 颜色层级判定：强制自定义颜色 > ElvUI 原生配置颜色 > 自定义兜底颜色
    if db.eAF_forceInterruptColor then
        colorToUse = db.eAF_interruptColor
    else
        if NP and NP.db and NP.db.colors and NP.db.colors.castInterruptedColor then
            colorToUse = NP.db.colors.castInterruptedColor
        else
            colorToUse = db.eAF_interruptColor
        end
    end

    -- 应用最终决定的颜色到施法条的 StatusBar 上
    if colorToUse then
        castbar:SetStatusBarColor(colorToUse.r, colorToUse.g, colorToUse.b, colorToUse.a or 1)
    end
end

-- ==========================================
-- 模块 2：任务目标判断 (带正则解析)
-- ==========================================
function Mod:CheckQuestObjective(frame)
    if not frame or not frame.unit then return end
    
    local db = E.db.elvui_additionalfeature
    if not db.eAF_enableQuestColor then return end

    -- 【新增】：副本环境检测
    local inInstance = IsInInstance()
    if inInstance and not db.eAF_enableQuestColorInInstance then
        -- 如果在副本内且没有开启强制检测，直接清理掉该姓名板可能遗留的染色状态并退出
        frame.eAF_IsQuestObjective = false
        return
    end

    frame.eAF_IsQuestObjective = false

    -- 【判断层级 A】：检查 ElvUI 原生的任务图标系统 (极快)
    -- 注意：原生的图标在目标未被选中时可能会被隐藏，因此我们需要 B 计划兜底。
    if (frame.QuestIcons and frame.QuestIcons:IsShown()) or 
       (frame.QuestIndicator and frame.QuestIndicator:IsShown()) or 
       (frame.QuestIcon and frame.QuestIcon:IsShown()) then
        frame.eAF_IsQuestObjective = true
    else
        -- 【判断层级 B】：深度解析底层 Tooltip (慢，但 100% 绝对精准)
        local tooltipData = C_TooltipInfo.GetUnit(frame.unit)
        if tooltipData and tooltipData.lines then
            for _, line in ipairs(tooltipData.lines) do
                -- 匹配任务目标 Enum (常规值为 8)
                if line.type == Enum.TooltipDataLineType.QuestObjective or line.type == 8 then
                    local text = line.leftText
                    if text then
                        -- 【智能进度追踪】：正则表达式解析 "已击杀: 5/10" 格式
                        -- (%d+) 匹配数字，%s* 匹配任意空格，/ 匹配斜杠
                        local current, max = string.match(text, "(%d+)%s*/%s*(%d+)")
                        if current and max then
                            -- 核心逻辑：只有当前击杀数 < 需求总数时，才继续判定为任务怪
                            if tonumber(current) < tonumber(max) then
                                frame.eAF_IsQuestObjective = true
                                break
                            end
                        else
                            -- 解析百分比格式任务，例如 "进度: 50%"
                            local percent = string.match(text, "(%d+)%%")
                            if percent then
                                if tonumber(percent) < 100 then
                                    frame.eAF_IsQuestObjective = true
                                    break
                                end
                            else
                                -- 如果既没有 x/y 也没有 %，说明是特殊任务（如仅仅是一段文字描述），直接染色
                                frame.eAF_IsQuestObjective = true
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

-- ==========================================
-- 渲染逻辑：执行任务目标血条颜色覆盖
-- ==========================================
function Mod:ApplyQuestColor(frame)
    if not frame or not frame.Health then return end
    local db = E.db.elvui_additionalfeature
    -- 如果开关开启，并且经过上一环判定确认为活跃任务目标
    if db.eAF_enableQuestColor and frame.eAF_IsQuestObjective then
        local color = db.eAF_questColor
        -- 强制覆盖 oUF 底层的 StatusBar 颜色
        frame.Health:SetStatusBarColor(color.r, color.g, color.b)
    end
end

-- ==========================================
-- 模块 3：防弹级框架解析器与 Hook 拦截器
-- ==========================================
-- 功能说明：
-- oUF 框架在触发事件时，传进来的参数非常混乱，有时传 Nameplate 框架，有时传 Health 组件本身。
-- 此处使用穷举法，无论传来什么，都顺藤摸瓜提取出真正的带有 unit 属性的框架。

-- 拦截一：血量更新引发的颜色重绘
function Mod:OnHealthUpdateColor(arg1, arg2, arg3)
    local frame = nil
    -- 由于 oUF 的传参存在各种可能性，此处进行穷举提取，确保能拿到真正的 Nameplate
    if type(arg1) == "table" and arg1.unit and arg1.Health then frame = arg1
    elseif type(arg2) == "table" and arg2.unit and arg2.Health then frame = arg2
    elseif type(arg1) == "table" and arg1.__owner and arg1.__owner.unit then frame = arg1.__owner
    elseif type(arg2) == "table" and arg2.__owner and arg2.__owner.unit then frame = arg2.__owner end

    if frame then
        self:CheckQuestObjective(frame)
        self:ApplyQuestColor(frame)
    end
end

-- 拦截二：仇恨模块引发的颜色重绘 (极为关键)
-- 解决痛点：战斗中 ElvUI 会根据仇恨高低（红/黄/绿）强行给怪上色，导致任务怪血条狂闪。
-- 在此处进行拦截，使任务染色的优先级永远高于仇恨染色。
function Mod:OnThreatIndicatorPostUpdate(arg1, arg2, arg3)
    local frame = nil
    if type(arg1) == "table" and arg1.__owner and arg1.__owner.unit then frame = arg1.__owner
    elseif type(arg2) == "table" and arg2.__owner and arg2.__owner.unit then frame = arg2.__owner end

    if frame then
        self:CheckQuestObjective(frame)
        self:ApplyQuestColor(frame)
    end
end

-- ==========================================
-- 【新增】：防弹级透明度修改拦截器
-- ==========================================
function Mod:ApplyDifficultyAlpha(frame)
    if not frame then return end
    local db = E.db.elvui_additionalfeature
    local alpha = db.eAF_difficultyColorAlpha
    if not alpha then return end

    -- 方案 A: 降维打击 - 遍历 oUF 底层的标签文本注册表
    -- 只要文字的内容含有 difficultycolor、smartlevel 或 level 标签，强行改透明度
    if frame.__tags then
        for fontString, tagStr in pairs(frame.__tags) do
            if type(tagStr) == "string" and (string.find(tagStr, "difficultycolor") or string.find(tagStr, "smartlevel") or string.find(tagStr, "level")) then
                fontString:SetAlpha(alpha)
            end
        end
    end

    -- 方案 B: 穷举 ElvUI 各版本可能的 Level 控件命名
    if frame.Level then frame.Level:SetAlpha(alpha) end
    if frame.LevelText then frame.LevelText:SetAlpha(alpha) end
    if frame.tags and frame.tags.Level then frame.tags.Level:SetAlpha(alpha) end
    if frame.TagTexts and frame.TagTexts.Level then frame.TagTexts.Level:SetAlpha(alpha) end
end

-- 挂载到底层的 NamePlateCallBack：当姓名板出现时触发
function Mod:OnNamePlateCallBack(np_module, frame, event, unit)
    if event == "NAME_PLATE_UNIT_ADDED" then
        self:ApplyDifficultyAlpha(frame)
    end
end

-- ==========================================
-- 模块初始化：向 ElvUI 原生事件注入我们的逻辑
-- ==========================================
function Mod:InitializeNameplate()
    -- 1. Hook 强制单人仇恨 (拦截 PreUpdate，接管 oUF 的 isTank/useSolo 判断)
    local orig_ThreatIndicator_PreUpdate = NP.ThreatIndicator_PreUpdate
    NP.ThreatIndicator_PreUpdate = function(self, unit, pass)
        if pass then
            local isTank, offTank, useSolo, targetGUID, targetRole = orig_ThreatIndicator_PreUpdate(self, unit, pass)
            if E.db.elvui_additionalfeature.eAF_showTheatSoloColor then
                useSolo = NP.db.threat.useSoloColor -- 强制采用 Solo 仇恨颜色配置
            end
            return isTank, offTank, useSolo, targetGUID, targetRole
        else
            orig_ThreatIndicator_PreUpdate(self, unit, pass)
            if E.db.elvui_additionalfeature.eAF_showTheatSoloColor then
                self.useSolo = NP.db.threat.useSoloColor
            end
        end
    end

    -- 应用单人仇恨到已创建的姓名板
    if NP.CreatedPlates then
        for nameplate in pairs(NP.CreatedPlates) do
            if nameplate.ThreatIndicator then
                nameplate.ThreatIndicator.PreUpdate = NP.ThreatIndicator_PreUpdate
            end
        end
    end

    -- 2. Hook 施法条打断
    if NP.Castbar_PostCastInterrupted then
        self:SecureHook(NP, "Castbar_PostCastInterrupted", "OnCastbarInterrupted")
    end
    
    -- 3. Hook 血条颜色更新（用于覆盖任务色）
    if NP.Health_UpdateColor then
        self:SecureHook(NP, "Health_UpdateColor", "OnHealthUpdateColor")
    end

    -- 4. Hook 仇恨颜色更新（用于确立任务色的绝对优先级）
    if NP.ThreatIndicator_PostUpdate then
        self:SecureHook(NP, "ThreatIndicator_PostUpdate", "OnThreatIndicatorPostUpdate")
    end

    -- 5. Hook 挂载底层姓名板加载事件和标签刷新事件
    if NP.NamePlateCallBack then
        self:SecureHook(NP, "NamePlateCallBack", "OnNamePlateCallBack")
    end

    -- 拦截 ElvUI 可能刷新标签文本的生命周期，防止设置被重置覆盖
    local tagMethods = { "Update_Tags", "Configure_Tags", "Construct_TagText", "UpdateTags" }
    for _, method in ipairs(tagMethods) do
        if NP[method] then
            self:SecureHook(NP, method, function(self_np, frame)
                Mod:ApplyDifficultyAlpha(frame)
            end)
        end
    end
end