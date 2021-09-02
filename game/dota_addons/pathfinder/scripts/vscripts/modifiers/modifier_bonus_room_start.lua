modifier_bonus_room_start = class({})

--------------------------------------------------------------------------------
require("constants")
function modifier_bonus_room_start:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_MODEL_CHANGE}
    return funcs
end

function modifier_bonus_room_start:GetModifierModelChange()
    return self.model
end

require("libraries.has_shard")

function modifier_bonus_room_start:OnCreated(kv)
    local models = courier_models

    self.model = models[RandomInt(1, #models)]

    if IsServer() then
		local parent = self:GetParent()
        -- play effects
        self:PlayEffects(true)
		local supp_effect = AddPatronEffect(parent)
		self.model = supp_effect.model
		self.effects = {}

		if supp_effect.scale then
			parent:SetModelScale(supp_effect.scale)
		end
		if supp_effect.material_group then
			Timers:CreateTimer(0, function()
				if parent:HasModifier(self:GetName()) then
					parent:SetMaterialGroup(tostring(supp_effect.material_group))
				end
			end)
		end
		if supp_effect.particles_data then
			WearFunc:_CreateParticlesFromConfigList(supp_effect.particles_data, parent, self.effects)
		end

        if parent:HasModifier("modifier_phoenix_sun_ray_pf_caster_dummy") then
			parent:RemoveModifierByName("modifier_phoenix_sun_ray_pf_caster_dummy")
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

function modifier_bonus_room_start:GetPriority()
    return MODIFIER_PRIORITY_ULTRA + 1000
end

function modifier_bonus_room_start:OnDestroy(kv)
    if IsServer() then
        -- play effects
        self:PlayEffects(false)
		local parent = self:GetParent()
		parent:SetModelScale(1)
		if self.effects then
			for _, particle in pairs(self.effects) do
				ParticleManager:DestroyParticle(particle, false)
				ParticleManager:ReleaseParticleIndex(particle)
			end
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
