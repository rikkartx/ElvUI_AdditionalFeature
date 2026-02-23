local E, L, V, P, G = unpack(ElvUI)
local Mod = E:GetModule('ElvUI_AdditionalFeature')

-- ==========================================
-- 功能描述：注册一个可自定义名称的文本格式标签 (Text Format Tag)。
-- 使得玩家可以在单位框架或姓名板中使用形如 [eAF_reactioncolor] 的标签，
-- 该标签会动态返回我们定义的友方/中立/敌对的 HEX 颜色代码。
-- ==========================================
function Mod:RegisterCustomTag()
    local tagName = E.db.elvui_additionalfeature.eAF_reactioncolor
    if not tagName or tagName == "" then tagName = "eAF_reactioncolor" end

    -- 防重名及清理逻辑：若玩家修改了标签名，抹除旧名称，防止在“可用文字格式”中堆积
    if self.lastTagName and self.lastTagName ~= tagName then
        if E.TagInfo then E.TagInfo[self.lastTagName] = nil end
    end
    self.lastTagName = tagName

    -- 将标签注册到 ElvUI 的 Tag 系统底层
    E:AddTag(tagName, 'UNIT_FACTION', function(unit)
        local reaction = UnitReaction(unit, 'player')
        
        -- 针对被其他玩家染红的怪物 (Tap Denied) 统一显示灰色
        if not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then return '|cffB0B0B0' end
        if not reaction then return '' end

        local db = E.db.elvui_additionalfeature
        local color
        
        -- 判断单位声望并赋予对应颜色
        if reaction >= 5 then color = db.eAF_colorReactionGood
        elseif reaction == 4 then color = db.eAF_colorReactionNeutral
        else color = db.eAF_colorReactionBad end

        -- 将 RGB (0~1) 转换为十六进制字符串 (0~255) 并注入格式符 |cff
        return string.format('|cff%02x%02x%02x', color.r * 255, color.g * 255, color.b * 255)
    end)

    -- 将新标签推送到 ElvUI 设置面板的“可用的文字格式 (Available Tags)”列表中供玩家参考
    if E.AddTagInfo then
        E:AddTagInfo(tagName, 'Colors', L["Custom reaction color from Additional Feature plugin."])
    end
end

-- ==========================================
-- 模块初始化
-- ==========================================
function Mod:InitializeTag()
    self:RegisterCustomTag()
end