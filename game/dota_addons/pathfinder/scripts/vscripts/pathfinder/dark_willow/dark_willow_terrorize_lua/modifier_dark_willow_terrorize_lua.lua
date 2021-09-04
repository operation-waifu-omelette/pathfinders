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
modifier_dark_willow_terrorize_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_dark_willow_terrorize_lua:IsHidden()
	return false
end

function modifier_dark_willow_terrorize_lua:IsDebuff()
	return true
end

function modifier_dark_willow_terrorize_lua:IsStunDebuff()
	return false
end

function modifier_dark_willow_terrorize_lua:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_dark_willow_terrorize_lua:OnCreated( kv )
	if not IsServer() then return end
	-- play effects
	self:PlayEffects()

	-- local cast_location = kv.location
	-- local target_location = self:GetParent():GetOrigin()
	
	
	local travel_dist = 1000
	local fear_target_loc = RotatePosition( Vector(0,0,0), QAngle( 0, math.random (360) -1, 0 ), Vector(0,travel_dist,0) )

	self:GetParent():MoveToPosition( Vector( travel_dist, 0, 0 ) )

end

function modifier_dark_willow_terrorize_lua:OnRefresh( kv )
	
end

function modifier_dark_willow_terrorize_lua:OnRemoved()
end

function modifier_dark_willow_terrorize_lua:OnDestroy()
	if not IsServer() then return end

	-- stop running
	self:GetParent():Stop()
	if self:GetParent():IsCreep() then
		self:GetParent():SetForceAttackTargetAlly( nil ) -- for creeps
	end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_dark_willow_terrorize_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
	}

	return funcs
end

function modifier_dark_willow_terrorize_lua:GetModifierProvidesFOWVision()
	return 1
end
--------------------------------------------------------------------------------
-- Status Effects
function modifier_dark_willow_terrorize_lua:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_SILENCED] = true
	}
	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_dark_willow_terrorize_lua:GetStatusEffectName()
	return "particles/status_fx/status_effect_dark_willow_wisp_fear.vpcf"
end

function modifier_dark_willow_terrorize_lua:PlayEffects()
	-- Get Resources
	local particle_cast1 = "particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell_debuff.vpcf"
	local particle_cast2 = "particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell_fear_debuff.vpcf"

	-- Create Particle
	local effect_cast1 = ParticleManager:CreateParticle( particle_cast1, PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
	local effect_cast2 = ParticleManager:CreateParticle( particle_cast2, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	-- local effect_cast1 = assert(loadfile("lua_abilities/rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast1, PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
	-- local effect_cast2 = assert(loadfile("lua_abilities/rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast2, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )

	-- buff particle
	self:AddParticle(
		effect_cast1,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
	self:AddParticle(
		effect_cast2,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end