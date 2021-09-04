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
modifier_dark_willow_terrorize_lua_skeleton = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_dark_willow_terrorize_lua_skeleton:IsHidden()
	return false
end

function modifier_dark_willow_terrorize_lua_skeleton:IsDebuff()
	return true
end

function modifier_dark_willow_terrorize_lua_skeleton:IsStunDebuff()
	return false
end

function modifier_dark_willow_terrorize_lua_skeleton:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_dark_willow_terrorize_lua_skeleton:OnCreated( kv )
	if not IsServer() then return end
	-- play effects
	self:PlayEffects()

	self:SetDuration( 60, true )
	self:StartIntervalThink( 60 )
	
end

function modifier_dark_willow_terrorize_lua_skeleton:OnRefresh( kv )
end

function modifier_dark_willow_terrorize_lua_skeleton:OnRemoved()
end

function modifier_dark_willow_terrorize_lua_skeleton:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_dark_willow_terrorize_lua_skeleton:OnIntervalThink()
	if IsServer() then
		self:StartIntervalThink( -1 )
		self:GetParent():ForceKill( false )
	end
end

function modifier_dark_willow_terrorize_lua_skeleton:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
	}

	return funcs
end

function modifier_dark_willow_terrorize_lua_skeleton:GetModifierProvidesFOWVision()
	return 1
end
--------------------------------------------------------------------------------
-- Status Effects
function modifier_dark_willow_terrorize_lua_skeleton:CheckState()

	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_dark_willow_terrorize_lua_skeleton:GetStatusEffectName()
	return "particles/status_fx/status_effect_dark_willow_wisp_fear.vpcf"
end

function modifier_dark_willow_terrorize_lua_skeleton:PlayEffects()
	local particle_cast = "particles/dark_willow_shadow_realm_skeletons.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self:GetParent(),
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end