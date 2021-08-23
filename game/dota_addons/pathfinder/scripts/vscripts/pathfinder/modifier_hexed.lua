-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
modifier_hexed = modifier_hexed or class({})

require("constants")

--------------------------------------------------------------------------------
-- Classifications
function modifier_hexed:IsHidden()
	return false
end

function modifier_hexed:GetTexture()
	return "buyback"
end

function modifier_hexed:IsDebuff()
	return true
end

function modifier_hexed:IsPurgable()
	return false
end

function modifier_hexed:RemoveOnDeath()
	return false
end
require("libraries.has_shard")
require("constants")
-- Initializations
function modifier_hexed:OnCreated( kv )
	-- references
	self.base_speed = 350
	

	local models = courier_models

	self.model = models[RandomInt(1, #models)]
	
	if IsServer() then
		local parent = self:GetParent()
		-- play effects		
		self:PlayEffects( true )
		
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


		-- self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_nyx_assassin_vendetta_break", {})
		if parent:HasModifier("modifier_phoenix_sun_ray_pf_caster_dummy") then
			parent:RemoveModifierByName("modifier_phoenix_sun_ray_pf_caster_dummy")
		end
	end
end

function modifier_hexed:OnRefresh( kv )
	-- references
	self.base_speed = self:GetAbility():GetSpecialValueFor( "movespeed" )
	if IsServer() then
		-- play effects
		self:PlayEffects( true )
	end
end

function modifier_hexed:OnDestroy( kv )
	if IsServer() then
		-- play effects
		self:PlayEffects( false )
		local parent = self:GetParent()
		parent:SetModelScale(1)
		if self.effects then
			for _, particle in pairs(self.effects) do
				ParticleManager:DestroyParticle(particle, false)
				ParticleManager:ReleaseParticleIndex(particle)
			end
		end
		-- self:GetParent():RemoveModifierByName("modifier_nyx_assassin_vendetta_break")
	end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_hexed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
	}
	return funcs
end

function modifier_hexed:GetModifierMoveSpeed_Absolute()
	return self.base_speed
end
function modifier_hexed:GetModifierModelChange()
	return self.model
end
function modifier_hexed:GetModifierHPRegenAmplify_Percentage( params )
	return -100
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_hexed:CheckState()
	local state = {	}
	if IsServer() then
		state = {[MODIFIER_STATE_DISARMED] = true,
				[MODIFIER_STATE_SILENCED] = true,
				[MODIFIER_STATE_MUTED] = true,
				[MODIFIER_STATE_PASSIVES_DISABLED] = true,
				[MODIFIER_STATE_FLYING]	= false,
				}
	end

	return state
end



--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_hexed:PlayEffects( bStart )
	local sound_cast = "Hero_Lion.Hex.Target"
	local particle_cast = "particles/units/heroes/hero_shadowshaman/shadowshaman_voodoo.vpcf"

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_hexed:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 1000
end

function modifier_hexed:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end
