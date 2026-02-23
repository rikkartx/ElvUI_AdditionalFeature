local E, L, V, P, G = unpack(ElvUI)
local Mod = E:GetModule('ElvUI_AdditionalFeature')

-- ==========================================
-- 功能描述：强制抹除光环 (Buff/Debuff) 图标上的原生冷却旋转动画。
-- 原理：在 ElvUI 每次更新光环的时间和动画时进行拦截，
-- 强行将 Cooldown 框架的阴影扇区 (Swipe) 和高亮边缘 (Edge) 隐藏掉，仅保留数字。
-- ==========================================
function Mod:OnAuraUpdateButton(aurasMod, button, duration, expiration, modRate)
    if E.db.elvui_additionalfeature.eAF_disableAuraSweep then
        if button.cooldown then
            button.cooldown:SetDrawSwipe(false)
            button.cooldown:SetDrawEdge(false)
        end
    end
end

-- ==========================================
-- 模块初始化
-- ==========================================
function Mod:InitializeAura()
    local A = E:GetModule('Auras')
    if A and A.UpdateButton then
        -- SecureHook：后置钩子，在原函数执行完毕后再执行我们的逻辑以确保覆盖生效
        self:SecureHook(A, "UpdateButton", "OnAuraUpdateButton")
    end
end