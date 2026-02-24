local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')

local Mod = E:NewModule('ElvUI_AdditionalFeature', 'AceHook-3.0', 'AceEvent-3.0')

-- ==========================================
-- 自动排序引擎 (Auto-Order Engine)
-- 告别手动写 order = 1, 2, 3，调用一次自动 +1
-- ==========================================
local orderCount = 0
local function getOrder()
    orderCount = orderCount + 1
    return orderCount
end

-- ==========================================
-- 数据库初始化
-- ==========================================
P['elvui_additionalfeature'] = {
    -- 姓名板相关
    ['eAF_enableTargetColor'] = false,                                         
    ['eAF_targetColor'] = { r = 75, g = 189, b = 235 }, -- #4BBDEB
    ['eAF_showTheatSoloColor'] = false,
    ['eAF_enableInterruptColor'] = false,
    ['eAF_forceInterruptColor'] = false,
    ['eAF_interruptColor'] = { r = 199/255, g = 64/255, b = 64/255, a = 1 }, -- #C74040
    ['eAF_difficultyColorAlpha'] = 1.0,
    ['eAF_enableQuestColor'] = false,
    ['eAF_enableQuestColorInInstance'] = false,
    ['eAF_questColor'] = { r = 255/255, g = 255/255, b = 255/255 },            -- #FFFFFF

    -- 光环相关
    ['eAF_disableAuraSweep'] = false,

    -- 标签相关
    ['eAF_reactioncolor'] = 'eAF_reactioncolor',
    ['eAF_colorReactionGood'] = { r = 32/255, g = 213/255, b = 27/255 },     -- #20D51B
    ['eAF_colorReactionNeutral'] = { r = 241/255, g = 205/255, b = 48/255 }, -- #F1CD30
    ['eAF_colorReactionBad'] = { r = 234/255, g = 47/255, b = 47/255 },      -- #EA2F2F
}

-- ==========================================
-- 设置菜单构建 (标签页化 + 自动排序重构版)
-- ==========================================
local function InsertOptions()
    -- 每次重构菜单前重置排序计数器
    orderCount = 0

    E.Options.args.elvui_additionalfeature = {
        order = 100,
        type = 'group',
        name = L["Additional Feature"],
        -- 核心魔法：让子组以“顶部标签页(Tabs)”的形式呈现，瞬间高大上！
        childGroups = "tab", 
        args = {
            -- ======================================
            -- 大模块 1：姓名板 (NamePlates)
            -- ======================================
            nameplateGroup = {
                order = getOrder(),
                type = 'group',
                name = L["NamePlates"] or "NamePlates",
                args = {
                    -- [新增] 小标题：当前目标颜色设置
                    header_target = { order = getOrder(), type = 'header', name = L["Target Nameplate Color"] or "Target Nameplate Color" },
                    eAF_enableTargetColor = {
                        order = getOrder(), type = 'toggle', name = L["Enable Target Color"] or "Enable Target Color", desc = L["Change the nameplate health bar color for the current target."] or "Change the nameplate health bar color for the current target.",
                        get = function(info) return E.db.elvui_additionalfeature.eAF_enableTargetColor end,
                        set = function(info, value)
                            E.db.elvui_additionalfeature.eAF_enableTargetColor = value
                            if NP.ConfigureAll then NP:ConfigureAll() end
                        end,
                    },
                    eAF_targetColor = {
                        order = getOrder(), type = 'color', name = L["Target Color"] or "Target Color", desc = L["Color to use for the current target."] or "Color to use for the current target.", hasAlpha = false,
                        disabled = function() return not E.db.elvui_additionalfeature.eAF_enableTargetColor end,
                        get = function(info) local t = E.db.elvui_additionalfeature.eAF_targetColor; return t.r, t.g, t.b end,
                        set = function(info, r, g, b) local t = E.db.elvui_additionalfeature.eAF_targetColor; t.r, t.g, t.b = r, g, b; if NP.ConfigureAll then NP:ConfigureAll() end; end,
                    },
                    
                    -- 小标题：强制单人仇恨颜色设置
                    header_threat = { order = getOrder(), type = 'header', name = L["Force Solo Threat Color"] },
                    eAF_showTheatSoloColor = {
                        order = getOrder(), type = 'toggle', name = L["Enable Solo Threat Color"], desc = L["Force use solo threat color even in a group/raid."],
                        get = function(info) return E.db.elvui_additionalfeature.eAF_showTheatSoloColor end,
                        set = function(info, value)
                            E.db.elvui_additionalfeature.eAF_showTheatSoloColor = value
                            if NP.ConfigureAll then NP:ConfigureAll() end
                        end,
                    },
                    
                    -- 小标题：施法条打断设置
                    header_interrupt = { order = getOrder(), type = 'header', name = L["Castbar Interrupt Settings"] },
                    eAF_enableInterruptColor = {
                        order = getOrder(), type = 'toggle', name = L["Nameplate Interrupt Color"], desc = L["Change the castbar color when a spell is interrupted."],
                        get = function(info) return E.db.elvui_additionalfeature.eAF_enableInterruptColor end,
                        set = function(info, value) E.db.elvui_additionalfeature.eAF_enableInterruptColor = value end,
                    },
                    eAF_forceInterruptColor = {
                        order = getOrder(), type = 'toggle', name = L["Force Custom Interrupt Color"], desc = L["FORCE_INTERRUPT_COLOR_DESC"],
                        disabled = function() return not E.db.elvui_additionalfeature.eAF_enableInterruptColor end,
                        get = function(info) return E.db.elvui_additionalfeature.eAF_forceInterruptColor end,
                        set = function(info, value) E.db.elvui_additionalfeature.eAF_forceInterruptColor = value end,
                    },
                    eAF_interruptColor = {
                        order = getOrder(), type = 'color', name = L["Custom Interrupt Color"], desc = L["Color to use when a spell is interrupted."], hasAlpha = true,
                        disabled = function() return not E.db.elvui_additionalfeature.eAF_enableInterruptColor end,
                        get = function(info) local t = E.db.elvui_additionalfeature.eAF_interruptColor; return t.r, t.g, t.b, t.a end,
                        set = function(info, r, g, b, a) local t = E.db.elvui_additionalfeature.eAF_interruptColor; t.r, t.g, t.b, t.a = r, g, b, a end,
                    },

                    -- 小标题：等级颜色透明度
                    header_alpha = { order = getOrder(), type = 'header', name = L["Nameplate Level Text Alpha"] or "Level Text Alpha" },
                    eAF_difficultyColorAlpha = {
                        order = getOrder(), type = 'range', name = L["Nameplate Level Text Alpha"] or "Level Text Alpha", desc = L["Adjust the transparency of the nameplate level text object."],
                        min = 0, max = 1, step = 0.05, isPercent = true,
                        get = function(info) return E.db.elvui_additionalfeature.eAF_difficultyColorAlpha end,
                        set = function(info, value)
                            E.db.elvui_additionalfeature.eAF_difficultyColorAlpha = value
                            
                            -- 【修复】：直接遍历修改透明度，并强制 oUF 引擎重绘标签！
                            if NP.CreatedPlates then
                                for nameplate in pairs(NP.CreatedPlates) do
                                    if Mod.ApplyDifficultyAlpha then 
                                        Mod:ApplyDifficultyAlpha(nameplate) 
                                    end
                                    -- 强行踢一脚渲染引擎，让透明度在拖动滑块时瞬间生效
                                    if nameplate.UpdateTags then
                                        nameplate:UpdateTags()
                                    end
                                end
                            end
                            
                            -- 兜底全局重配
                            if NP.ConfigureAll then NP:ConfigureAll() end
                        end,
                    },

                    -- 小标题：任务目标颜色设置
                    header_quest = { order = getOrder(), type = 'header', name = L["Quest Objective Settings"] },
                    eAF_enableQuestColor = {
                        order = getOrder(), type = 'toggle', name = L["Nameplate Quest Color"], desc = L["Change the nameplate health bar color for quest objectives."],
                        get = function(info) return E.db.elvui_additionalfeature.eAF_enableQuestColor end,
                        set = function(info, value)
                            E.db.elvui_additionalfeature.eAF_enableQuestColor = value
                            if NP.ConfigureAll then NP:ConfigureAll() end
                        end,
                    },
                    eAF_enableQuestColorInInstance = {
                        order = getOrder(), type = 'toggle', name = L["Enable in Instances (may cause performance issues)"], desc = L["ENABLE_QUEST_COLOR_IN_INSTANCE_DESC"],
                        disabled = function() return not E.db.elvui_additionalfeature.eAF_enableQuestColor end,
                        get = function(info) return E.db.elvui_additionalfeature.eAF_enableQuestColorInInstance end,
                        set = function(info, value)
                            E.db.elvui_additionalfeature.eAF_enableQuestColorInInstance = value
                            if NP.ConfigureAll then NP:ConfigureAll() end
                        end,
                    },
                    eAF_questColor = {
                        order = getOrder(), type = 'color', name = L["Quest Objective Color"], desc = L["Color to use for quest objectives."], hasAlpha = false,
                        disabled = function() return not E.db.elvui_additionalfeature.eAF_enableQuestColor end,
                        get = function(info) local t = E.db.elvui_additionalfeature.eAF_questColor; return t.r, t.g, t.b end,
                        set = function(info, r, g, b) local t = E.db.elvui_additionalfeature.eAF_questColor; t.r, t.g, t.b = r, g, b; if NP.ConfigureAll then NP:ConfigureAll() end; end,
                    },
                },
            },

            -- ======================================
            -- 大模块 2：光环 (Auras)
            -- ======================================
            auraGroup = {
                order = getOrder(),
                type = 'group',
                name = L["Auras"] or "Auras",
                args = {
                    header_aura = { order = getOrder(), type = 'header', name = L["Auras Settings"] },
                    eAF_disableAuraSweep = {
                        order = getOrder(), type = 'toggle', name = L["Disable Aura Sweep"], desc = L["DISABLE_AURA_SWEEP_DESC"],
                        get = function(info) return E.db.elvui_additionalfeature.eAF_disableAuraSweep end,
                        set = function(info, value)
                            E.db.elvui_additionalfeature.eAF_disableAuraSweep = value
                            local A = E:GetModule('Auras')
                            if A then
                                local updateSweep = function(header, button)
                                    if button and button.cooldown then
                                        if value then
                                            button.cooldown:SetDrawSwipe(false)
                                            button.cooldown:SetDrawEdge(false)
                                        else
                                            if A.UpdateButton and button.duration then A:UpdateButton(button, button.duration, button.expiration, button.modRate) end
                                        end
                                    end
                                end
                                if A.BuffFrame and A.BuffFrame.ForEachChild then A.BuffFrame:ForEachChild(updateSweep) end
                                if A.DebuffFrame and A.DebuffFrame.ForEachChild then A.DebuffFrame:ForEachChild(updateSweep) end
                            end
                        end,
                    },
                },
            },

            -- ======================================
            -- 大模块 3：自定义标签 (Tags)
            -- ======================================
            tagGroup = {
                order = getOrder(),
                type = 'group',
                name = L["Custom Tags"] or "Custom Tags Settings",
                args = {
                    header_reaction = { order = getOrder(), type = 'header', name = L["Custom Reaction Color Tag"] },
                    eAF_reactioncolor = {
                        order = getOrder(), type = 'input', name = L["Custom Tag Name"], desc = L["Change the tag name used in text formats."],
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
                        order = getOrder(), type = 'description', fontSize = "medium",
                        name = function()
                            local tag = E.db.elvui_additionalfeature.eAF_reactioncolor or "eAF_reactioncolor"
                            return string.format(L["TAG_USAGE_DESC"], tag)
                        end,
                    },
                    eAF_colorReactionGood = {
                        order = getOrder(), type = 'color', name = L["Good"], hasAlpha = false,
                        get = function(info) return E.db.elvui_additionalfeature.eAF_colorReactionGood.r, E.db.elvui_additionalfeature.eAF_colorReactionGood.g, E.db.elvui_additionalfeature.eAF_colorReactionGood.b end,
                        set = function(info, r, g, b) E.db.elvui_additionalfeature.eAF_colorReactionGood.r, E.db.elvui_additionalfeature.eAF_colorReactionGood.g, E.db.elvui_additionalfeature.eAF_colorReactionGood.b = r, g, b; if NP.ConfigureAll then NP:ConfigureAll() end; end,
                    },
                    eAF_colorReactionNeutral = {
                        order = getOrder(), type = 'color', name = L["Neutral"], hasAlpha = false,
                        get = function(info) return E.db.elvui_additionalfeature.eAF_colorReactionNeutral.r, E.db.elvui_additionalfeature.eAF_colorReactionNeutral.g, E.db.elvui_additionalfeature.eAF_colorReactionNeutral.b end,
                        set = function(info, r, g, b) E.db.elvui_additionalfeature.eAF_colorReactionNeutral.r, E.db.elvui_additionalfeature.eAF_colorReactionNeutral.g, E.db.elvui_additionalfeature.eAF_colorReactionNeutral.b = r, g, b; if NP.ConfigureAll then NP:ConfigureAll() end; end,
                    },
                    eAF_colorReactionBad = {
                        order = getOrder(), type = 'color', name = L["Bad"], hasAlpha = false,
                        get = function(info) return E.db.elvui_additionalfeature.eAF_colorReactionBad.r, E.db.elvui_additionalfeature.eAF_colorReactionBad.g, E.db.elvui_additionalfeature.eAF_colorReactionBad.b end,
                        set = function(info, r, g, b) E.db.elvui_additionalfeature.eAF_colorReactionBad.r, E.db.elvui_additionalfeature.eAF_colorReactionBad.g, E.db.elvui_additionalfeature.eAF_colorReactionBad.b = r, g, b; if NP.ConfigureAll then NP:ConfigureAll() end; end,
                    },
                },
            },
        },
    }
end

-- ==========================================
-- 插件初始化入口
-- ==========================================
function Mod:Initialize()
    InsertOptions()

    if self.InitializeTag then self:InitializeTag() end
    if self.InitializeAura then self:InitializeAura() end
    if self.InitializeNameplate then self:InitializeNameplate() end
end

E:RegisterModule(Mod:GetName())