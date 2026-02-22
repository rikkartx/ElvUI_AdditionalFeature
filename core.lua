local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')

local Mod = E:NewModule('ElvUI_AdditionalFeature', 'AceHook-3.0', 'AceEvent-3.0')

-- 1. 注册默认设置到 Profile (P) 数据库
P['elvui_additionalfeature'] = {
    ['eAF_showTheatSoloColor'] = false,
    ['eAF_enableInterruptColor'] = false,
    ['eAF_forceInterruptColor'] = false,
    ['eAF_interruptColor'] = { r = 199/255, g = 64/255, b = 64/255, a = 1 }, -- #C74040
    
    ['eAF_reactioncolor'] = 'eAF_reactioncolor',
    ['eAF_colorReactionGood'] = { r = 32/255, g = 213/255, b = 27/255 },     -- #20D51B
    ['eAF_colorReactionNeutral'] = { r = 241/255, g = 205/255, b = 48/255 }, -- #F1CD30
    ['eAF_colorReactionBad'] = { r = 234/255, g = 47/255, b = 47/255 },      -- #EA2F2F

    ['eAF_disableAuraSweep'] = false,
}

-- 核心方法：注册文字标签
function Mod:RegisterCustomTag()
    local tagName = E.db.elvui_additionalfeature.eAF_reactioncolor
    if not tagName or tagName == "" then tagName = "eAF_reactioncolor" end

    if self.lastTagName and self.lastTagName ~= tagName then
        if E.TagInfo then E.TagInfo[self.lastTagName] = nil end
    end
    self.lastTagName = tagName

    E:AddTag(tagName, 'UNIT_FACTION', function(unit)
        local reaction = UnitReaction(unit, 'player')
        if not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then return '|cffB0B0B0' end
        if not reaction then return '' end

        local db = E.db.elvui_additionalfeature
        local color
        
        if reaction >= 5 then
            color = db.eAF_colorReactionGood
        elseif reaction == 4 then
            color = db.eAF_colorReactionNeutral
        else
            color = db.eAF_colorReactionBad
        end

        return string.format('|cff%02x%02x%02x', color.r * 255, color.g * 255, color.b * 255)
    end)

    if E.AddTagInfo then
        E:AddTagInfo(tagName, 'Colors', L["Custom reaction color from Additional Feature plugin."])
    end
end

-- 2. 在 ElvUI 设置面板中插入选项菜单
local function InsertOptions()
    E.Options.args.elvui_additionalfeature = {
        order = 100,
        type = 'group',
        name = L["Additional Feature"],
        args = {
            header1 = {
                order = 1,
                type = 'header',
                name = L["Force Solo Threat Color"],
            },
            eAF_showTheatSoloColor = {
                order = 2,
                type = 'toggle',
                name = L["Enable Solo Threat Color"],
                desc = L["Force use solo threat color even in a group/raid."],
                get = function(info) return E.db.elvui_additionalfeature.eAF_showTheatSoloColor end,
                set = function(info, value)
                    E.db.elvui_additionalfeature.eAF_showTheatSoloColor = value
                    if NP.ConfigureAll then NP:ConfigureAll() end
                end,
            },
            header2 = {
                order = 3,
                type = 'header',
                name = L["Castbar Interrupt Settings"],
            },
            eAF_enableInterruptColor = {
                order = 4,
                type = 'toggle',
                name = L["Nameplate Interrupt Color"],
                desc = L["Change the castbar color when a spell is interrupted."],
                get = function(info) return E.db.elvui_additionalfeature.eAF_enableInterruptColor end,
                set = function(info, value) E.db.elvui_additionalfeature.eAF_enableInterruptColor = value end,
            },
            eAF_forceInterruptColor = {
                order = 5,
                type = 'toggle',
                name = L["Force Custom Interrupt Color"],
                desc = L["FORCE_INTERRUPT_COLOR_DESC"],
                disabled = function() return not E.db.elvui_additionalfeature.eAF_enableInterruptColor end,
                get = function(info) return E.db.elvui_additionalfeature.eAF_forceInterruptColor end,
                set = function(info, value) E.db.elvui_additionalfeature.eAF_forceInterruptColor = value end,
            },
            eAF_interruptColor = {
                order = 6,
                type = 'color',
                name = L["Custom Interrupt Color"],
                desc = L["Color to use when a spell is interrupted."],
                hasAlpha = true,
                disabled = function() return not E.db.elvui_additionalfeature.eAF_enableInterruptColor end,
                get = function(info)
                    local t = E.db.elvui_additionalfeature.eAF_interruptColor
                    return t.r, t.g, t.b, t.a
                end,
                set = function(info, r, g, b, a)
                    local t = E.db.elvui_additionalfeature.eAF_interruptColor
                    t.r, t.g, t.b, t.a = r, g, b, a
                end,
            },
            header3 = {
                order = 7,
                type = 'header',
                name = L["Custom Reaction Color Tag"],
            },
            eAF_reactioncolor = {
                order = 8,
                type = 'input',
                name = L["Custom Tag Name"],
                desc = L["Change the tag name used in text formats."],
                get = function(info) return E.db.elvui_additionalfeature.eAF_reactioncolor end,
                set = function(info, value)
                    value = value:gsub("[%[%]%s]", "")
                    if value == "" then value = "eAF_reactioncolor" end
                    E.db.elvui_additionalfeature.eAF_reactioncolor = value
                    Mod:RegisterCustomTag()
                    if NP.ConfigureAll then NP:ConfigureAll() end
                end,
            },
            tagDescription = {
                order = 9,
                type = 'description',
                name = function()
                    local tag = E.db.elvui_additionalfeature.eAF_reactioncolor or "eAF_reactioncolor"
                    return string.format(L["TAG_USAGE_DESC"], tag)
                end,
                fontSize = "medium",
            },
            eAF_colorReactionGood = {
                order = 10,
                type = 'color',
                name = L["Good"],
                hasAlpha = false,
                get = function(info) return E.db.elvui_additionalfeature.eAF_colorReactionGood.r, E.db.elvui_additionalfeature.eAF_colorReactionGood.g, E.db.elvui_additionalfeature.eAF_colorReactionGood.b end,
                set = function(info, r, g, b) E.db.elvui_additionalfeature.eAF_colorReactionGood.r, E.db.elvui_additionalfeature.eAF_colorReactionGood.g, E.db.elvui_additionalfeature.eAF_colorReactionGood.b = r, g, b; if NP.ConfigureAll then NP:ConfigureAll() end; end,
            },
            eAF_colorReactionNeutral = {
                order = 11,
                type = 'color',
                name = L["Neutral"],
                hasAlpha = false,
                get = function(info) return E.db.elvui_additionalfeature.eAF_colorReactionNeutral.r, E.db.elvui_additionalfeature.eAF_colorReactionNeutral.g, E.db.elvui_additionalfeature.eAF_colorReactionNeutral.b end,
                set = function(info, r, g, b) E.db.elvui_additionalfeature.eAF_colorReactionNeutral.r, E.db.elvui_additionalfeature.eAF_colorReactionNeutral.g, E.db.elvui_additionalfeature.eAF_colorReactionNeutral.b = r, g, b; if NP.ConfigureAll then NP:ConfigureAll() end; end,
            },
            eAF_colorReactionBad = {
                order = 12,
                type = 'color',
                name = L["Bad"],
                hasAlpha = false,
                get = function(info) return E.db.elvui_additionalfeature.eAF_colorReactionBad.r, E.db.elvui_additionalfeature.eAF_colorReactionBad.g, E.db.elvui_additionalfeature.eAF_colorReactionBad.b end,
                set = function(info, r, g, b) E.db.elvui_additionalfeature.eAF_colorReactionBad.r, E.db.elvui_additionalfeature.eAF_colorReactionBad.g, E.db.elvui_additionalfeature.eAF_colorReactionBad.b = r, g, b; if NP.ConfigureAll then NP:ConfigureAll() end; end,
            },
            header4 = {
                order = 13,
                type = 'header',
                name = L["Auras Settings"],
            },
            eAF_disableAuraSweep = {
                order = 14,
                type = 'toggle',
                name = L["Disable Aura Sweep"],
                desc = L["DISABLE_AURA_SWEEP_DESC"],
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
        },
    }
end

function Mod:OnCastbarInterrupted(castbar, unit, spellID, interruptedBy)
    local db = E.db.elvui_additionalfeature
    if not db.eAF_enableInterruptColor then return end
    if not interruptedBy then return end

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

function Mod:OnAuraUpdateButton(aurasMod, button, duration, expiration, modRate)
    if E.db.elvui_additionalfeature.eAF_disableAuraSweep then
        if button.cooldown then
            button.cooldown:SetDrawSwipe(false)
            button.cooldown:SetDrawEdge(false)
        end
    end
end

function Mod:Initialize()
    InsertOptions()

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

    if NP.CreatedPlates then
        for nameplate in pairs(NP.CreatedPlates) do
            if nameplate.ThreatIndicator then
                nameplate.ThreatIndicator.PreUpdate = NP.ThreatIndicator_PreUpdate
            end
        end
    end

    if NP.Castbar_PostCastInterrupted then
        self:SecureHook(NP, "Castbar_PostCastInterrupted", "OnCastbarInterrupted")
    end

    self:RegisterCustomTag()

    local A = E:GetModule('Auras')
    if A and A.UpdateButton then
        self:SecureHook(A, "UpdateButton", "OnAuraUpdateButton")
    end
end

E:RegisterModule(Mod:GetName())