local E, L, V, P, G = unpack(ElvUI)
local Mod = E:GetModule('ElvUI_AdditionalFeature')
local NP = E:GetModule('NamePlates')

-- ==========================================
-- 模块 1：施法条打断 Bug 修复与自定义变色逻辑
-- ==========================================
function Mod:OnCastbarInterrupted(castbar, unit, spellID, interruptedBy)
    if castbar and castbar.TargetText then
        castbar.TargetText:SetText("")
    end

    local db = E.db.elvui_additionalfeature
    if not db.eAF_enableInterruptColor then return end

    local colorToUse = nil
    if db.eAF_forceInterruptColor then
        colorToUse = db.eAF_interruptColor
    else
        if NP and NP.db and NP.db.colors and NP.db.colors.castInterruptedColor then
            colorToUse = NP.db.colors.castInterruptedColor
        else
            colorToUse = db.eAF_interruptColor
        end
    end

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

    local inInstance = IsInInstance()
    if inInstance and not db.eAF_enableQuestColorInInstance then
        frame.eAF_IsQuestObjective = false
        return
    end

    frame.eAF_IsQuestObjective = false

    if (frame.QuestIcons and frame.QuestIcons:IsShown()) or 
       (frame.QuestIndicator and frame.QuestIndicator:IsShown()) or 
       (frame.QuestIcon and frame.QuestIcon:IsShown()) then
        frame.eAF_IsQuestObjective = true
    else
        local tooltipData = C_TooltipInfo.GetUnit(frame.unit)
        if tooltipData and tooltipData.lines then
            for _, line in ipairs(tooltipData.lines) do
                if line.type == Enum.TooltipDataLineType.QuestObjective or line.type == 8 then
                    local text = line.leftText
                    if text then
                        local current, max = string.match(text, "(%d+)%s*/%s*(%d+)")
                        if current and max then
                            if tonumber(current) < tonumber(max) then
                                frame.eAF_IsQuestObjective = true
                                break
                            end
                        else
                            local percent = string.match(text, "(%d+)%%")
                            if percent then
                                if tonumber(percent) < 100 then
                                    frame.eAF_IsQuestObjective = true
                                    break
                                end
                            else
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
-- 渲染逻辑：统一处理所有覆盖染色 (优先级枢纽)
-- ==========================================
function Mod:ApplyNameplateColorOverride(frame)
    if not frame or not frame.Health or not frame.unit then return end
    
    local db = E.db.elvui_additionalfeature

    -- 【优先级 1：当前目标染色】
    if db.eAF_enableTargetColor and UnitIsUnit(frame.unit, "target") then
        local color = db.eAF_targetColor
        frame.Health:SetStatusBarColor(color.r, color.g, color.b)
        return
    end

    -- 【优先级 2：焦点目标染色】
    if db.eAF_enableFocusColor and UnitIsUnit(frame.unit, "focus") then
        local color = db.eAF_focusColor
        frame.Health:SetStatusBarColor(color.r, color.g, color.b)
        return 
    end

    -- 【优先级 3：任务目标染色】
    self:CheckQuestObjective(frame)
    if db.eAF_enableQuestColor and frame.eAF_IsQuestObjective then
        local color = db.eAF_questColor
        frame.Health:SetStatusBarColor(color.r, color.g, color.b)
        return
    end
end

-- ==========================================
-- 模块 3：防弹级框架解析器与 Hook 拦截器
-- ==========================================
function Mod:OnHealthUpdateColor(arg1, arg2, arg3)
    local frame = nil
    if type(arg1) == "table" and arg1.unit and arg1.Health then frame = arg1
    elseif type(arg2) == "table" and arg2.unit and arg2.Health then frame = arg2
    elseif type(arg1) == "table" and arg1.__owner and arg1.__owner.unit then frame = arg1.__owner
    elseif type(arg2) == "table" and arg2.__owner and arg2.__owner.unit then frame = arg2.__owner end

    if frame then
        self:CheckQuestObjective(frame)
        self:ApplyNameplateColorOverride(frame)
    end
end

function Mod:OnThreatIndicatorPostUpdate(arg1, arg2, arg3)
    local frame = nil
    if type(arg1) == "table" and arg1.__owner and arg1.__owner.unit then frame = arg1.__owner
    elseif type(arg2) == "table" and arg2.__owner and arg2.__owner.unit then frame = arg2.__owner end

    if frame then
        self:CheckQuestObjective(frame)
        self:ApplyNameplateColorOverride(frame)
    end
end

-- 为了在刚选中目标时能“立刻”上色，加入一个轻量级的目标切换事件
-- 虽然不处理原目标退色，但至少保证新选中的怪能在第一时间变黄，而不是等掉血才变色。
function Mod:OnPlayerTargetChanged()
    if NP.Plates then
        for frame in pairs(NP.Plates) do
            if frame:IsShown() and frame.unit and frame.Health then
                frame:UpdateAllElements('eAF_OnPlayerTargetChanged_Refresh')
            end
        end
    end
end

function Mod:OnPlayerFocusChanged()
    if NP.Plates then
        for frame in pairs(NP.Plates) do
            if frame:IsShown() and frame.unit and frame.Health then
                frame:UpdateAllElements('eAF_OnPlayerFocusChanged_Refresh')
            end
        end
    end
end

-- ==========================================
-- 透明度修改拦截器
-- ==========================================
function Mod:ApplyDifficultyAlpha(frame)
    if not frame then return end
    local db = E.db.elvui_additionalfeature
    local alpha = db.eAF_difficultyColorAlpha
    if not alpha then return end

    if frame.__tags then
        for fontString, tagStr in pairs(frame.__tags) do
            if type(tagStr) == "string" and (string.find(tagStr, "difficultycolor") or string.find(tagStr, "smartlevel") or string.find(tagStr, "level")) then
                fontString:SetAlpha(alpha)
            end
        end
    end

    if frame.Level then frame.Level:SetAlpha(alpha) end
    if frame.LevelText then frame.LevelText:SetAlpha(alpha) end
    if frame.tags and frame.tags.Level then frame.tags.Level:SetAlpha(alpha) end
    if frame.TagTexts and frame.TagTexts.Level then frame.TagTexts.Level:SetAlpha(alpha) end
end

function Mod:OnNamePlateCallBack(np_module, frame, event, unit)
    if event == "NAME_PLATE_UNIT_ADDED" then
        self:ApplyDifficultyAlpha(frame)
    end
end

-- ==========================================
-- 模块初始化：向 ElvUI 原生事件注入我们的逻辑
-- ==========================================
function Mod:InitializeNameplate()
    -- 0. 注册原生目标切换事件
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "OnPlayerTargetChanged")
    self:RegisterEvent("PLAYER_FOCUS_CHANGED", "OnPlayerFocusChanged")

    -- 1. Hook 强制单人仇恨
    local orig_ThreatIndicator_PreUpdate = NP.ThreatIndicator_PreUpdate
    NP.ThreatIndicator_PreUpdate = function(self, unit, pass)
        if pass then
            local isTank, offTank, useSolo, targetGUID, targetRole = orig_ThreatIndicator_PreUpdate(self, unit, pass)
            if E.db.elvui_additionalfeature.eAF_showTheatSoloColor then
                useSolo = NP.db.threat.useSoloColor 
            end
            return isTank, offTank, useSolo, targetGUID, targetRole
        else
            orig_ThreatIndicator_PreUpdate(self, unit, pass)
            if E.db.elvui_additionalfeature.eAF_showTheatSoloColor then
                self.useSolo = NP.db.threat.useSoloColor
            end
        end
    end

    if NP.Plates then
        for nameplate in pairs(NP.Plates) do
            if nameplate.ThreatIndicator then
                nameplate.ThreatIndicator.PreUpdate = NP.ThreatIndicator_PreUpdate
            end
        end
    end

    -- 2. Hook 施法条打断
    if NP.Castbar_PostCastInterrupted then
        self:SecureHook(NP, "Castbar_PostCastInterrupted", "OnCastbarInterrupted")
    end
    
    -- 3. Hook 血条颜色更新
    if NP.Health_UpdateColor then
        self:SecureHook(NP, "Health_UpdateColor", "OnHealthUpdateColor")
    end

    -- 4. Hook 仇恨颜色更新
    if NP.ThreatIndicator_PostUpdate then
        self:SecureHook(NP, "ThreatIndicator_PostUpdate", "OnThreatIndicatorPostUpdate")
    end

    -- 5. Hook 挂载底层姓名板加载事件和标签刷新事件
    if NP.NamePlateCallBack then
        self:SecureHook(NP, "NamePlateCallBack", "OnNamePlateCallBack")
    end

    local tagMethods = { "Update_Tags", "Configure_Tags", "Construct_TagText", "UpdateTags" }
    for _, method in ipairs(tagMethods) do
        if NP[method] then
            self:SecureHook(NP, method, function(self_np, frame)
                Mod:ApplyDifficultyAlpha(frame)
            end)
        end
    end
end