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
modifier_jakiro_macropyre_lua_thinker = class({})
require("libraries.timers")

--------------------------------------------------------------------------------
-- Classifications
function modifier_jakiro_macropyre_lua_thinker:IsHidden()
	return false
end

function modifier_jakiro_macropyre_lua_thinker:IsDebuff()
	return false
end

function modifier_jakiro_macropyre_lua_thinker:IsStunDebuff()
	return false
end

function modifier_jakiro_macropyre_lua_thinker:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_jakiro_macropyre_lua_thinker:OnCreated( kv )
	-- ListenToGameEvent( "refresh_pyres", Dynamic_Wrap( getclass( self ), "RefreshPyre" ), self )
	
	self.caster = self:GetCaster()
	self.parent = self:GetParent()	

	-- references
	self.radius = self:GetAbility():GetSpecialValueFor( "path_radius" )
	self.duration = self:GetAbility():GetSpecialValueFor( "linger_duration" )	

	self.interval = self:GetAbility():GetSpecialValueFor( "burn_interval" )
	self.range = self:GetAbility():GetCastRange( self.parent:GetAbsOrigin(), nil ) + self.caster:GetCastRangeBonus()

	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	

	if not IsServer() then return end

	-- ability properties
	self.abilityDamageType = self:GetAbility():GetAbilityDamageType()
	self.abilityTargetTeam = self:GetAbility():GetAbilityTargetTeam()
	self.abilityTargetType = self:GetAbility():GetAbilityTargetType()
	self.abilityTargetFlags = self:GetAbility():GetAbilityTargetFlags()

	-- calculate stuff
	-- local start_range = 234
	-- self.direction = Vector( kv.x, kv.y, 0 )
	-- self.startpoint = self.parent:GetOrigin() + self.direction * start_range
	-- self.endpoint = self.startpoint + self.direction * self.range

	self.startpoint = Vector(kv.fromx, kv.fromy, kv.fromz)
	self.endpoint = Vector(kv.tox, kv.toy, kv.toz)
	
	local dir = (self.endpoint - self.startpoint)	
	dir.z = 0
	self.direction = dir:Normalized()

	-- destroy trees along line
	local step = 0
	while step < self.range do
		local loc = self.startpoint + self.direction * step
		GridNav:DestroyTreesAroundPoint( loc, self.radius, true )

		step = step + self.radius
	end

	-- Start interval
	self:StartIntervalThink( self.interval )

	-- play effects
	self:PlayEffects()
end

function modifier_jakiro_macropyre_lua_thinker:OnRefresh( kv )
	
end

function modifier_jakiro_macropyre_lua_thinker:OnRemoved()
end

function modifier_jakiro_macropyre_lua_thinker:OnDestroy()
	if not IsServer() then return end
	if self.effect_cast then
		ParticleManager:DestroyParticle(self.effect_cast, false)
		ParticleManager:ReleaseParticleIndex(self.effect_cast)
	end
	for i,pyre in pairs(self:GetAbility().all_pyres) do
		self:GetAbility().all_pyres[i] = nil
	end
	StopSoundOn( "hero_jakiro.macropyre", self:GetParent() )
	-- self:GetAbility():SetFrozenCooldown(false)
	UTIL_Remove( self:GetParent() )
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_jakiro_macropyre_lua_thinker:OnIntervalThink()
	local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	if IsServer() and self.caster:HasAbility("pathfinder_jakiro_macropyre_heal") then
		target_team = DOTA_UNIT_TARGET_TEAM_BOTH
	end
	-- continuously find units in line
	local enemies = FindUnitsInLine(
		self.caster:GetTeamNumber(),	-- int, your team number
		self.startpoint,	-- point, center point
		self.endpoint,
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		-- self.abilityTargetTeam,	-- int, team filter
		target_team,
		self.abilityTargetType,	-- int, type filter
		self.abilityTargetFlags	-- int, flag filter
	)

	for _,enemy in pairs(enemies) do
		-- add modifier
		enemy:AddNewModifier(
			self.caster, -- player source
			self:GetAbility(), -- ability source
			"modifier_jakiro_macropyre_lua", -- modifier name
			{
				duration = self.duration,
				interval = self.interval,
				damage = self.damage * self.interval,
				damage_type = self.abilityDamageType,
			} -- kv
		)
	end

	if IsServer() and self.caster:HasAbility("pathfinder_jakiro_macropyre_eternal") then
		local allies = FindUnitsInLine(
			self.caster:GetTeamNumber(),	-- int, your team number
			self.startpoint,	-- point, center point
			self.endpoint,
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO,
			0
		)	
		for _,ally in pairs(allies) do
			if ally == self.caster then
				self:GetAbility():RefreshPyres()
				break
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_jakiro_macropyre_lua_thinker:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/econ/items/jakiro/jakiro_ti10_immortal/jakiro_ti10_macropyre.vpcf"
	local sound_cast = "hero_jakiro.macropyre"
		

	-- Create Particle
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self.parent )
	ParticleManager:SetParticleControl( self.effect_cast, 0, self.startpoint )
	ParticleManager:SetParticleControl( self.effect_cast, 1, self.endpoint )
	ParticleManager:SetParticleControl( self.effect_cast, 2, Vector( 999, 0, 0 ) )
	-- ParticleManager:ReleaseParticleIndex( effect_cast )

	-- buff particle
	self:AddParticle(
		self.effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	self.parent:EmitSoundParams(sound_cast, 0, 0.4, 0)
	-- EmitSoundOn( sound_cast, self.parent )
end