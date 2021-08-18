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
require("libraries.timers")
--------------------------------------------------------------------------------
dawnbreaker_solar_guardian_lua = class({})
LinkLuaModifier( "modifier_dawnbreaker_solar_guardian_lua", "pathfinder/dawnbreaker_solar_guardian_lua/modifier_dawnbreaker_solar_guardian_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dawnbreaker_solar_guardian_lua_leap", "pathfinder/dawnbreaker_solar_guardian_lua/modifier_dawnbreaker_solar_guardian_lua_leap", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_arc_lua", "pathfinder/generic/modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_custom_indicator", "pathfinder/generic/modifier_generic_custom_indicator", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_stunned_lua", "pathfinder/generic/modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_3_charges", "pathfinder/generic/modifier_generic_3_charges", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dawnbreaker_solar_guardian_lua_permanent_thinker", "pathfinder/dawnbreaker_solar_guardian_lua/dawnbreaker_solar_guardian_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dawnbreaker_solar_guardian_lua_capture_victim", "pathfinder/dawnbreaker_solar_guardian_lua/dawnbreaker_solar_guardian_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Init Abilities
function dawnbreaker_solar_guardian_lua:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dawnbreaker.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_aoe.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_damage.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_healing_buff.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_airtime_buff.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_landing.vpcf", context )
end

function dawnbreaker_solar_guardian_lua:Spawn()
	if not IsServer() then return end
	local this = self
	Timers(2, function()
		if IsValidEntity(this) and this:GetCaster():FindAbilityByName("dawnbreaker_solar_guardian_lua_charges") then
			this:RefreshIntrinsicModifier()
			return nil			
		else
			return 2
		end
	end)	
end

function dawnbreaker_solar_guardian_lua:OnUpgrade()
	if self:GetCaster():FindAbilityByName("dawnbreaker_solar_guardian_lua_permanent_dummy") then
		self:GetCaster():FindAbilityByName("dawnbreaker_solar_guardian_lua_permanent"):SetActivated(true)
	end
end

function dawnbreaker_solar_guardian_lua:GetIntrinsicModifierName()
	if self:GetCaster():FindAbilityByName("dawnbreaker_solar_guardian_lua_charges") then
		return "modifier_generic_3_charges"
	end
end


--------------------------------------------------------------------------------
-- Custom KV
function dawnbreaker_solar_guardian_lua:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------
-- Ability Cast Filter
function dawnbreaker_solar_guardian_lua:CastFilterResultLocation( vLoc )
	-- check nohammer
	if self:GetCaster():HasModifier( "modifier_dawnbreaker_celestial_hammer_lua_nohammer" ) then
		return UF_FAIL_CUSTOM
	end	

	if not IsServer() then return end

	if not GameRules.Aghanim:GetCurrentRoom():IsInRoomBounds( vLoc ) then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function dawnbreaker_solar_guardian_lua:GetCustomCastErrorLocation( vLoc )
	-- check nohammer
	if self:GetCaster():HasModifier( "modifier_dawnbreaker_celestial_hammer_lua_nohammer" ) then
		return "#dota_hud_error_nohammer"
	end	

	if not IsServer() then return "" end

	if not GameRules.Aghanim:GetCurrentRoom():IsInRoomBounds( vLoc ) then
		return "#dota_hud_error_outofbound"
	end

	return ""
end

--------------------------------------------------------------------------------
-- Ability Start
function dawnbreaker_solar_guardian_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- load data
	local channel = self:GetChannelTime()
	local leaptime = self:GetSpecialValueFor( "airtime_duration" )

	-- add modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_dawnbreaker_solar_guardian_lua", -- modifier name
		{
			duration = channel+leaptime,
			x = point.x,
			y = point.y,
		} -- kv
	)

	-- store point
	self.point = point
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_4)

	if self:GetCaster():FindAbilityByName("dawnbreaker_solar_guardian_lua_capture") then
		local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			self:GetCaster():GetAbsOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self:GetSpecialValueFor("radius"),	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)		
		for _,enemy in pairs(enemies) do		
			if not enemy:HasModifier("modifier_absolute_no_cc")	 then
				enemy:AddNewModifier(self:GetCaster(), self, "modifier_dawnbreaker_solar_guardian_lua_capture_victim", {duration = self:GetChannelTime() + leaptime})					
			end
		end		
	end
end

--------------------------------------------------------------------------------
-- Ability Channeling
function dawnbreaker_solar_guardian_lua:OnChannelFinish( interrupted )
	-- unit identifier
	local caster = self:GetCaster()

	if interrupted then
		local mod = caster:FindModifierByName( "modifier_dawnbreaker_solar_guardian_lua" )
		if mod and (not mod:IsNull()) then
			mod:Destroy()
			self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_4)
		end
		return
	end

	-- load data
	local duration = self:GetSpecialValueFor( "airtime_duration" )
	

	-- add leap modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_dawnbreaker_solar_guardian_lua_leap", -- modifier name
		{
			duration = duration,
			x = self.point.x,
			y = self.point.y,
		} -- kv
	)
end


function dawnbreaker_solar_guardian_lua:Pulse(point, value_multiplier)	

	local damage = self:GetSpecialValueFor( "base_damage" ) * value_multiplier
	local heal = self:GetSpecialValueFor( "base_heal" ) * value_multiplier
	local radius = self:GetSpecialValueFor( "radius" )

	local damageTable = {
		-- victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL ,
		ability = self, --Optional.
	}

	-- find enemies
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		point,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	for _,enemy in pairs(enemies) do
		-- damage
		damageTable.victim = enemy
		ApplyDamage( damageTable )
	end

	-- find allies
	local allies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		point,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	for _,ally in pairs(allies) do
		-- heal
		ally:Heal( heal, self )

		if ally ~= self:GetCaster() then
			-- effects
			local particle_heal = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_healing_buff.vpcf"
			-- Create Particle
			local heal_fx = ParticleManager:CreateParticle( particle_heal, PATTACH_ABSORIGIN_FOLLOW, ally )
			ParticleManager:ReleaseParticleIndex( heal_fx )
		end

		SendOverheadEventMessage(
			nil,
			OVERHEAD_ALERT_HEAL,
			ally,
			heal,
			self:GetCaster():GetPlayerOwner()
		)
	end
	
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_damage.vpcf"	

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, point )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_ring_flames.vpcf"
	effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )	
	ParticleManager:SetParticleControl( effect_cast, 1, point )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( radius, radius, radius ) )

	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_outer_diamonds.vpcf"
	effect_cast2 = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )	
	ParticleManager:SetParticleControl( effect_cast2, 0, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast2, 1, point )
	ParticleManager:SetParticleControl( effect_cast2, 2, Vector( radius, radius, radius ) )

	particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_ambient_solar_flare.vpcf"
	effect_cast3 = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )		
	ParticleManager:SetParticleControl( effect_cast3, 0, point )
	ParticleManager:SetParticleControl( effect_cast3, 1, point )
	ParticleManager:SetParticleControl( effect_cast3, 2, Vector( radius, radius, radius ) )

	Timers(0.2, function()
		ParticleManager:DestroyParticle(effect_cast, false)
		ParticleManager:ReleaseParticleIndex( effect_cast )
		ParticleManager:DestroyParticle(effect_cast2, false)
		ParticleManager:ReleaseParticleIndex( effect_cast2 )
		ParticleManager:DestroyParticle(effect_cast3, false)
		ParticleManager:ReleaseParticleIndex( effect_cast3 )
	end)	
	
end



------------------------
-------------------------
dawnbreaker_solar_guardian_lua_permanent_dummy = class({})

function dawnbreaker_solar_guardian_lua_permanent_dummy:Spawn()
	if not IsServer() then return end			
	
	
	self:GetCaster():FindAbilityByName("dawnbreaker_solar_guardian_lua_permanent"):SetHidden(false)
	if self:GetCaster():FindAbilityByName("dawnbreaker_solar_guardian_lua"):IsTrained() then
		self:GetCaster():FindAbilityByName("dawnbreaker_solar_guardian_lua_permanent"):SetActivated(true)
		self:GetCaster():FindAbilityByName("dawnbreaker_solar_guardian_lua_permanent"):SetLevel(1)
	else
		self:GetCaster():FindAbilityByName("dawnbreaker_solar_guardian_lua_permanent"):SetLevel(1)
		self:GetCaster():FindAbilityByName("dawnbreaker_solar_guardian_lua_permanent"):SetActivated(false)
	end
end
------------------
-- SOLAR SANCTUARY
dawnbreaker_solar_guardian_lua_permanent = class({})

function dawnbreaker_solar_guardian_lua_permanent:Spawn()
	if not IsServer() then return end			
	self:SetHidden(true)	
end

function dawnbreaker_solar_guardian_lua_permanent:GetAOERadius()
	return self:GetCaster():FindAbilityByName("dawnbreaker_solar_guardian_lua"):GetSpecialValueFor("radius")
end

function dawnbreaker_solar_guardian_lua_permanent:GetManaCost(iLevel)
	return self:GetCaster():GetMana()
end

function dawnbreaker_solar_guardian_lua_permanent:OnAbilityPhaseStart()
	if not IsServer() then return end
	local sound_cast = "Hero_Dawnbreaker.Solar_Guardian.Channel"	
	EmitSoundOn( sound_cast, self:GetCaster() )
	self:GetCaster():StartGestureWithFade(ACT_DOTA_GENERIC_CHANNEL_1,0,0.1)
	
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian.vpcf"	
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		self.effect_cast,
		3,
		self.parent,
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)


	return true
end

function dawnbreaker_solar_guardian_lua_permanent:OnAbilityPhaseInterrupted()
	self:GetCaster():FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)

	if self.effect_cast then
		ParticleManager:DestroyParticle(self.effect_cast, false)
		ParticleManager:ReleaseParticleIndex(self.effect_cast)
	end
end

function dawnbreaker_solar_guardian_lua_permanent:OnSpellStart()
	if not IsServer() then return end

	
	
	self:GetCaster():FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)
	self:SetActivated(false)

	local point = self:GetCursorPosition()
	self.thinker = CreateModifierThinker(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_dawnbreaker_solar_guardian_lua_permanent_thinker", -- modifier name
		{
		
		}, -- kv
		point,
		self:GetCaster():GetTeamNumber(),
		false
	)
	ParticleManager:DestroyParticle(self.effect_cast, false)
	ParticleManager:ReleaseParticleIndex(self.effect_cast)

	AddFOWViewer(DOTA_TEAM_GOODGUYS, point, 600, 15, false)
end


---- thinker
modifier_dawnbreaker_solar_guardian_lua_permanent_thinker = class({})

function modifier_dawnbreaker_solar_guardian_lua_permanent_thinker:IsHidden()
	return true
end

function modifier_dawnbreaker_solar_guardian_lua_permanent_thinker:IsDebuff()
	return false
end

function modifier_dawnbreaker_solar_guardian_lua_permanent_thinker:IsPurgable()
	return false
end

function modifier_dawnbreaker_solar_guardian_lua_permanent_thinker:OnCreated()
	if not IsServer() or not self:GetCaster():HasAbility("dawnbreaker_solar_guardian_lua") or not self:GetCaster():FindAbilityByName("dawnbreaker_solar_guardian_lua"):IsTrained() then self:Destroy() end
	local interval = self:GetCaster():FindAbilityByName("dawnbreaker_solar_guardian_lua"):GetSpecialValueFor( "pulse_interval" )
	self:StartIntervalThink(interval)
end

function modifier_dawnbreaker_solar_guardian_lua_permanent_thinker:OnIntervalThink()
	if not IsServer() then return end
	local mult = self:GetCaster():FindAbilityByName("dawnbreaker_solar_guardian_lua_permanent"):GetLevelSpecialValueFor("value_mult",1) / 100	
	self:GetCaster():FindAbilityByName("dawnbreaker_solar_guardian_lua"):Pulse(self:GetParent():GetOrigin(), mult)
end

function modifier_dawnbreaker_solar_guardian_lua_permanent_thinker:OnDestroy()
	if not IsServer() then return end
	UTIL_Remove( self:GetParent() )
end


----------------------
--------------------------
-----------------------

modifier_dawnbreaker_solar_guardian_lua_capture_victim = class({})

function modifier_dawnbreaker_solar_guardian_lua_capture_victim:IsHidden()
	return true
end

function modifier_dawnbreaker_solar_guardian_lua_capture_victim:IsDebuff()
	return true
end

function modifier_dawnbreaker_solar_guardian_lua_capture_victim:IsPurgable()
	return false
end

function modifier_dawnbreaker_solar_guardian_lua_capture_victim:OnCreated()
	
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_trail.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, self:GetParent() )
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

