modifier_bonus_room_start = class({})

--------------------------------------------------------------------------------
require("constants")
function modifier_bonus_room_start:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_MODEL_CHANGE, MODIFIER_PROPERTY_MODEL_SCALE}
    return funcs
end

function modifier_bonus_room_start:GetModifierModelChange()
    return self.model
end

require("libraries.has_shard")

function modifier_bonus_room_start:OnCreated(kv)
    local models = courier_models

    self.model = models[RandomInt(1, #models)]
    self.patron_effect = nil

    if IsServer() then
        -- play effects
        self:PlayEffects(true)
        local table = AddPatronEffect(self:GetParent())
        self.model = table[2]
        self.patron_effect = table[1]
        self.scale = table[3]
        if self.patron_effect then
            self.effect = ParticleManager:CreateParticle(self.effect, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:SetParticleControlEnt(self.effect, 0, self:GetParent(), PATTACH_POINT_FOLLOW,
                "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(self.effect, 3, self:GetParent(), PATTACH_POINT_FOLLOW,
                "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
        end
        -- self:GetParent():SetModelScale(1.13)

        if self:GetParent():HasModifier("modifier_phoenix_sun_ray_pf_caster_dummy") then
            self:GetParent():RemoveModifierByName("modifier_phoenix_sun_ray_pf_caster_dummy")
        end
    end
end

function modifier_bonus_room_start:PlayEffects(bStart)
    local particle_cast = "particles/units/heroes/hero_shadowshaman/shadowshaman_voodoo.vpcf"

    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:ReleaseParticleIndex(effect_cast)
end

function modifier_bonus_room_start:IsHidden()
    return false
end

-----------------------------------------------------------------------------------------

function modifier_bonus_room_start:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_bonus_room_start:GetTexture()
    return "buyback"
end

-- -----------------------------------------------------------------------------------------

-- function modifier_bonus_room_start:ShouldUseOverheadOffset()
-- 	return true
-- end

-- -----------------------------------------------------------------------------------------

-- function modifier_bonus_room_start:GetEffectAttachType()
-- 	return PATTACH_OVERHEAD_FOLLOW
-- end

-- -----------------------------------------------------------------------------------------

-- function modifier_bonus_room_start:GetEffectName()
-- 	return "particles/generic_gameplay/generic_silenced.vpcf"
-- end

--------------------------------------------------------------------------------

function modifier_bonus_room_start:GetStatusEffectName()
    if IsServer() and tostring(PlayerResource:GetSteamID(self:GetParent():GetPlayerOwnerID())) == "76561198107181525" then -- hardcode for snike
        return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_gold_lvl2.vpcf"
    end
end

function modifier_bonus_room_start:GetPriority()
    return MODIFIER_PRIORITY_ULTRA + 1000
end

function modifier_bonus_room_start:OnDestroy(kv)
    if IsServer() then
        -- play effects
        self:PlayEffects(false)
        if self.effect then
            ParticleManager:DestroyParticle(self.effect, false)
            ParticleManager:ReleaseParticleIndex(self.effect)
        end
    end
end

--------------------------------------------------------------------------------

function modifier_bonus_room_start:CheckState()
    local state = {}

    if IsServer() then
        state[MODIFIER_STATE_SILENCED] = true
        state[MODIFIER_STATE_MUTED] = true
    end

    return state
end

function modifier_bonus_room_start:GetModifierModelScale()
    if not IsServer() then
        return
    end
    local playerID = tostring(PlayerResource:GetSteamID(self:GetParent():GetPlayerOwnerID()))

    for id, table in pairs(patron_id) do
        if playerID == id then

            return table.model_scale

        end
    end
end
