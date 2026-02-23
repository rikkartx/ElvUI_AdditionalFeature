local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')

-- ==========================================
-- 模块声明：创建插件的主模块
-- 使用 AceHook-3.0 用于拦截原生函数，AceEvent-3.0 用于事件监听
-- ==========================================
local Mod = E:NewModule('ElvUI_AdditionalFeature', 'AceHook-3.0', 'AceEvent-3.0')

-- ==========================================
-- 数据库初始化：将默认设置注册到 ElvUI 的 Profile 数据库中
-- ==========================================
P['elvui_additionalfeature'] = {
    -- [1] 强制单人仇恨颜色
    ['eAF_showTheatSoloColor'] = false,
    
    -- [2] 姓名板施法条打断变色
    ['eAF_enableInterruptColor'] = false,
    ['eAF_forceInterruptColor'] = false,
    ['eAF_interruptColor'] = { r = 199/255, g = 64/255, b = 64/255, a = 1 }, -- 默认红色 #C74040
    
    -- [3] 自定义声望颜色标签 (Custom Tag)
    ['eAF_reactioncolor'] = 'eAF_reactioncolor',
    ['eAF_colorReactionGood'] = { r = 32/255, g = 213/255, b = 27/255 },     -- 默认绿色 (友方) #20D51B
    ['eAF_colorReactionNeutral'] = { r = 241/255, g = 205/255, b = 48/255 }, -- 默认黄色 (中立) #F1CD30
    ['eAF_colorReactionBad'] = { r = 234/255, g = 47/255, b = 47/255 },      -- 默认红色 (敌对) #EA2F2F

    -- [4] 关闭光环冷却转圈动画
    ['eAF_disableAuraSweep'] = false,

    -- [5] 任务目标姓名板变色
    ['eAF_enableQuestColor'] = false,
    ['eAF_enableQuestColorInInstance'] = false,
    ['eAF_questColor'] = { r = 255/255, g = 255/255, b = 255/255 },            -- 默认白色 #FFFFFF
}

-- ==========================================
-- 设置菜单构建：将插件选项注入到 ElvUI 原生设置面板 (/ec)
-- ==========================================
local function InsertOptions()
    E.Options.args.elvui_additionalfeature = {
        order = 100,
        type = 'group',
        name = L["Additional Feature"],
        args = {
            -- 模块 1：强制单人仇恨颜色
            header1 = { order = 1, type = 'header', name = L["Force Solo Threat Color"] },
            eAF_showTheatSoloColor = {
                order = 2, type = 'toggle', name = L["Enable Solo Threat Color"], desc = L["Force use solo threat color even in a group/raid."],
                get = function(info) return E.db.elvui_additionalfeature.eAF_showTheatSoloColor end,
                set = function(info, value)
                    E.db.elvui_additionalfeature.eAF_showTheatSoloColor = value
                    if NP.ConfigureAll then NP:ConfigureAll() end
                end,
            },
            
            -- 模块 2：施法条打断变色
            header2 = { order = 3, type = 'header', name = L["Castbar Interrupt Settings"] },
            eAF_enableInterruptColor = {
                order = 4, type = 'toggle', name = L["Nameplate Interrupt Color"], desc = L["Change the castbar color when a spell is interrupted."],
                get = function(info) return E.db.elvui_additionalfeature.eAF_enableInterruptColor end,
                set = function(info, value) E.db.elvui_additionalfeature.eAF_enableInterruptColor = value end,
            },
            eAF_forceInterruptColor = {
                order = 5, type = 'toggle', name = L["Force Custom Interrupt Color"], desc = L["FORCE_INTERRUPT_COLOR_DESC"],
                disabled = function() return not E.db.elvui_additionalfeature.eAF_enableInterruptColor end,
                get = function(info) return E.db.elvui_additionalfeature.eAF_forceInterruptColor end,
                set = function(info, value) E.db.elvui_additionalfeature.eAF_forceInterruptColor = value end,
            },
            eAF_interruptColor = {
                order = 6, type = 'color', name = L["Custom Interrupt Color"], desc = L["Color to use when a spell is interrupted."], hasAlpha = true,
                disabled = function() return not E.db.elvui_additionalfeature.eAF_enableInterruptColor end,
                get = function(info) local t = E.db.elvui_additionalfeature.eAF_interruptColor; return t.r, t.g, t.b, t.a end,
                set = function(info, r, g, b, a) local t = E.db.elvui_additionalfeature.eAF_interruptColor; t.r, t.g, t.b, t.a = r, g, b, a end,
            },

            -- 模块 3：自定义声望标签
            header3 = { order = 7, type = 'header', name = L["Custom Reaction Color Tag"] },
            eAF_reactioncolor = {
                order = 8, type = 'input', name = L["Custom Tag Name"], desc = L["Change the tag name used in text formats."],
                get = function(info) return E.db.elvui_additionalfeature.eAF_reactioncolor end,
                set = function(info, value)
                    value = value:gsub("[%[%]%s]", "")
                    if value == "" then value = "eAF_reactioncolor" end
                    E.db.elvui_additionalfeature.eAF_reactioncolor = value
                    if Mod.RegisterCustomTag then Mod:RegisterCustomTag() end
                    if NP.ConfigureAll then NP:ConfigureAll() end
                end,
            },
            tagDescription = {
                order = 9, type = 'description', fontSize = "medium",
                name = function()
                    local tag = E.db.elvui_additionalfeature.eAF_reactioncolor or "eAF_reactioncolor"
                    return string.format(L["TAG_USAGE_DESC"], tag)
                end,
            },
            eAF_colorReactionGood = {
                order = 10, type = 'color', name = L["Good"], hasAlpha = false,
                get = function(info) return E.db.elvui_additionalfeature.eAF_colorReactionGood.r, E.db.elvui_additionalfeature.eAF_colorReactionGood.g, E.db.elvui_additionalfeature.eAF_colorReactionGood.b end,
                set = function(info, r, g, b) E.db.elvui_additionalfeature.eAF_colorReactionGood.r, E.db.elvui_additionalfeature.eAF_colorReactionGood.g, E.db.elvui_additionalfeature.eAF_colorReactionGood.b = r, g, b; if NP.ConfigureAll then NP:ConfigureAll() end; end,
            },
            eAF_colorReactionNeutral = {
                order = 11, type = 'color', name = L["Neutral"], hasAlpha = false,
                get = function(info) return E.db.elvui_additionalfeature.eAF_colorReactionNeutral.r, E.db.elvui_additionalfeature.eAF_colorReactionNeutral.g, E.db.elvui_additionalfeature.eAF_colorReactionNeutral.b end,
                set = function(info, r, g, b) E.db.elvui_additionalfeature.eAF_colorReactionNeutral.r, E.db.elvui_additionalfeature.eAF_colorReactionNeutral.g, E.db.elvui_additionalfeature.eAF_colorReactionNeutral.b = r, g, b; if NP.ConfigureAll then NP:ConfigureAll() end; end,
            },
            eAF_colorReactionBad = {
                order = 12, type = 'color', name = L["Bad"], hasAlpha = false,
                get = function(info) return E.db.elvui_additionalfeature.eAF_colorReactionBad.r, E.db.elvui_additionalfeature.eAF_colorReactionBad.g, E.db.elvui_additionalfeature.eAF_colorReactionBad.b end,
                set = function(info, r, g, b) E.db.elvui_additionalfeature.eAF_colorReactionBad.r, E.db.elvui_additionalfeature.eAF_colorReactionBad.g, E.db.elvui_additionalfeature.eAF_colorReactionBad.b = r, g, b; if NP.ConfigureAll then NP:ConfigureAll() end; end,
            },

            -- 模块 4：光环动画设置
            header4 = { order = 13, type = 'header', name = L["Auras Settings"] },
            eAF_disableAuraSweep = {
                order = 14, type = 'toggle', name = L["Disable Aura Sweep"], desc = L["DISABLE_AURA_SWEEP_DESC"],
                get = function(info) return E.db.elvui_additionalfeature.eAF_disableAuraSweep end,
                set = function(info, value)
                    E.db.elvui_additionalfeature.eAF_disableAuraSweep = value
                    local A = E:GetModule('Auras')
                    if A then
                        -- 动态实时更新当前屏幕上存在的所有光环，无需 /reload
                        local updateSweep = function(header, button)
                            if button and button.cooldown then
                                if value then
                                    button.cooldown:SetDrawSwipe(false)
                                    button.cooldown:SetDrawEdge(false)
                                else
                                    if A.UpdateButton and button.duration then
                                        A:UpdateButton(button, button.duration, button.expiration, button.modRate)
                                    end
                                end
                            end
                        end
                        if A.BuffFrame and A.BuffFrame.ForEachChild then A.BuffFrame:ForEachChild(updateSweep) end
                        if A.DebuffFrame and A.DebuffFrame.ForEachChild then A.DebuffFrame:ForEachChild(updateSweep) end
                    end
                end,
            },

            -- 模块 5：任务目标变色
            header5 = { order = 15, type = 'header', name = L["Quest Objective Settings"] },
            eAF_enableQuestColor = {
                order = 16, type = 'toggle', name = L["Nameplate Quest Color"], desc = L["Change the nameplate health bar color for quest objectives."],
                get = function(info) return E.db.elvui_additionalfeature.eAF_enableQuestColor end,
                set = function(info, value)
                    E.db.elvui_additionalfeature.eAF_enableQuestColor = value
                    if NP.ConfigureAll then NP:ConfigureAll() end
                end,
            },
            eAF_enableQuestColorInInstance = {
                order = 17, type = 'toggle', name = L["Enable in Instances (may cause performance issues)"], desc = L["ENABLE_QUEST_COLOR_IN_INSTANCE_DESC"],
                disabled = function() return not E.db.elvui_additionalfeature.eAF_enableQuestColor end,
                get = function(info) return E.db.elvui_additionalfeature.eAF_enableQuestColorInInstance end,
                set = function(info, value)
                    E.db.elvui_additionalfeature.eAF_enableQuestColorInInstance = value
                    if NP.ConfigureAll then NP:ConfigureAll() end
                end,
            },
            eAF_questColor = {
                order = 17, type = 'color', name = L["Quest Objective Color"], desc = L["Color to use for quest objectives."], hasAlpha = false,
                disabled = function() return not E.db.elvui_additionalfeature.eAF_enableQuestColor end,
                get = function(info)
                    local t = E.db.elvui_additionalfeature.eAF_questColor
                    return t.r, t.g, t.b
                end,
                set = function(info, r, g, b)
                    local t = E.db.elvui_additionalfeature.eAF_questColor
                    t.r, t.g, t.b = r, g, b
                    if NP.ConfigureAll then NP:ConfigureAll() end
                end,
            },
        },
    }
end

-- ==========================================
-- 插件初始化入口：当 ElvUI 准备就绪时调用
-- 负责插入选项菜单并调度各个子功能模块的初始化
-- ==========================================
function Mod:Initialize()
    InsertOptions()

    if self.InitializeTag then self:InitializeTag() end
    if self.InitializeAura then self:InitializeAura() end
    if self.InitializeNameplate then self:InitializeNameplate() end
end

E:RegisterModule(Mod:GetName())