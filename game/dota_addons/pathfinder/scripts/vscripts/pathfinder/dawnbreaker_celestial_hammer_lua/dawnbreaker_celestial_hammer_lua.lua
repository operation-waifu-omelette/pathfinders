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
dawnbreaker_celestial_hammer_lua = class({})
LinkLuaModifier( "modifier_dawnbreaker_celestial_hammer_lua", "pathfinder/dawnbreaker_celestial_hammer_lua/modifier_dawnbreaker_celestial_hammer_lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_dawnbreaker_celestial_hammer_lua_nohammer", "pathfinder/dawnbreaker_celestial_hammer_lua/modifier_dawnbreaker_celestial_hammer_lua_nohammer", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_dawnbreaker_celestial_hammer_lua_thinker", "pathfinder/dawnbreaker_celestial_hammer_lua/modifier_dawnbreaker_celestial_hammer_lua_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dawnbreaker_celestial_hammer_lua_trail", "pathfinder/dawnbreaker_celestial_hammer_lua/modifier_dawnbreaker_celestial_hammer_lua_trail", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dawnbreaker_celestial_hammer_lua_debuff", "pathfinder/dawnbreaker_celestial_hammer_lua/modifier_dawnbreaker_celestial_hammer_lua_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_frost_boss_pull", "pathfinder/frost_boss", LUA_MODIFIER_MOTION_HORIZONTAL )

--------------------------------------------------------------------------------
-- Init Abilities
function dawnbreaker_celestial_hammer_lua:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dawnbreaker.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_projectile.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_grounded.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_aoe_impact.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_burning_trail.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_trail.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_debuff.vpcf", context )
end

function dawnbreaker_celestial_hammer_lua:Spawn()
	if not IsServer() then return end
end

function dawnbreaker_celestial_hammer_lua:OnUpgrade()
	local sub = self:GetCaster():FindAbilityByName( "dawnbreaker_converge_lua" )
	if not sub then
		sub = self:GetCaster():AddAbility( "dawnbreaker_converge_lua" )
	end

	sub:SetLevel( self:GetLevel() )
end

--------------------------------------------------------------------------------
-- Ability Cast Filter
function dawnbreaker_celestial_hammer_lua:CastFilterResultLocation( vLoc )
	-- check nohammer
	if self:GetCaster():HasModifier( "modifier_dawnbreaker_celestial_hammer_lua_nohammer" ) then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function dawnbreaker_celestial_hammer_lua:GetCustomCastErrorLocation( vLoc )
	-- check nohammer
	if self:GetCaster():HasModifier( "modifier_dawnbreaker_celestial_hammer_lua_nohammer" ) then
		return "#dota_hud_error_nohammer"
	end

	return ""
end

function dawnbreaker_celestial_hammer_lua:GetCastRange(vLocation, hTarget)
	if IsServer() then return 900000 end
	return self:GetSpecialValueFor( "range" )
end

--------------------------------------------------------------------------------
-- Ability Start
function dawnbreaker_celestial_hammer_lua:OnSpellStart()
	self.pull_list = {}
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- load data
	local name = ""
	local radius = self:GetSpecialValueFor( "projectile_radius" )
	local speed = self:GetSpecialValueFor( "projectile_speed" )
	local distance = self:GetSpecialValueFor( "range" )

	-- get direction
	local direction = point-caster:GetOrigin()
	local len = direction:Length2D()
	direction.z = 0
	direction = direction:Normalized()

	distance = math.min( distance, len )

	-- create thinker
	local thinker = CreateModifierThinker(
		caster, -- player source
		self, -- ability source
		"modifier_dawnbreaker_celestial_hammer_lua_thinker", -- modifier name
		{}, -- kv
		caster:GetOrigin(),
		self:GetCaster():GetTeamNumber(),
		false
	)

	-- create linear projectile
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
	
		-- bDeleteOnHit = true,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	
		EffectName = name,
		fDistance = distance,
		fStartRadius = radius,
		fEndRadius = radius,
		vVelocity = direction * speed,
	}
	local data = {
		cast = 1,
		targets = {},
		thinker = thinker,
	}
	local id = ProjectileManager:CreateLinearProjectile( info )
	thinker.id = id
	self.projectiles[id] = data
	self.pull_list[id] = {}
	table.insert( self.thinkers, thinker )	

	-- swap with sub-ability
	local ability = caster:FindAbilityByName( "dawnbreaker_converge_lua" )
	if ability then
		ability:SetActivated( true )

		caster:SwapAbilities(
			"dawnbreaker_celestial_hammer_lua",
			"dawnbreaker_converge_lua",
			false,
			true
		)

		ability:StartCooldown( ability:GetCooldown( -1 ) )
	end

	-- set no hammer
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_dawnbreaker_celestial_hammer_lua_nohammer", -- modifier name
		{} -- kv
	)

	-- play effects
	data.effect = self:PlayEffects1( caster:GetOrigin(), distance, direction * speed )
end

--------------------------------------------------------------------------------
-- Projectile
dawnbreaker_celestial_hammer_lua.projectiles = {}
dawnbreaker_celestial_hammer_lua.thinkers = {}
function dawnbreaker_celestial_hammer_lua:OnProjectileThinkHandle( handle )
	local data = self.projectiles[handle]
	if data.thinker:IsNull() then return end

	if data.cast==1 then
		local location = ProjectileManager:GetLinearProjectileLocation( handle )
		-- move thinker along projectile
		data.thinker:SetOrigin( location )

		-- destroy trees
		local radius = self:GetSpecialValueFor( "projectile_radius" )
		GridNav:DestroyTreesAroundPoint( location, radius, false )

	elseif data.cast==2 then
		local location = ProjectileManager:GetTrackingProjectileLocation( handle )
		local radius = self:GetSpecialValueFor( "projectile_radius" )

		-- move thinker along projectile
		data.thinker:SetOrigin( location )

		-- find enemies not yet hit
		local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			location,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)
		for _,enemy in pairs(enemies) do
			if not data.targets[enemy] then
				data.targets[enemy] = true

				-- hammer hit
				self:HammerHit( enemy, location )									
			end
		end

		-- destroy trees
		local radius = self:GetSpecialValueFor( "projectile_radius" )
		GridNav:DestroyTreesAroundPoint( location, radius, false )
	end
end

function dawnbreaker_celestial_hammer_lua:OnProjectileHitHandle( target, location, handle )
	local data = self.projectiles[handle]
	if not handle then return end

	if data.cast==1 then
		if target then
			self:HammerHit( target, location )
			if self:GetCaster():HasAbility("dawnbreaker_celestial_hammer_lua_skewer") then
				target:AddNewModifier(self:GetCaster(), self, "modifier_frost_boss_pull", {proj = handle})	
				table.insert(self.pull_list[handle], target)	
			end
			return false
		end

		if self:GetCaster():HasAbility("dawnbreaker_celestial_hammer_lua_skewer") then			
			for _,pulled in pairs(self.pull_list[handle]) do
				pulled:RemoveModifierByName("modifier_frost_boss_pull")				
			end
			self.pull_list[handle] = {}
		end

		-- set thinker origin
		local loc = GetGroundPosition( location, self:GetCaster() )
		data.thinker:SetOrigin( loc )

		-- begin delay
		local mod = data.thinker:FindModifierByName( "modifier_dawnbreaker_celestial_hammer_lua_thinker" )
		mod:Delay()

		-- stop effect
		self:StopEffects( data.effect )

		-- destroy handle
		self.projectiles[handle] = nil

	elseif data.cast==2 then
		local caster = self:GetCaster()

		-- destroy thinker
		for i,thinker in pairs(self.thinkers) do
			if thinker == data.thinker then
				table.remove( self.thinkers, i )
				break
			end
		end
		local mod = data.thinker:FindModifierByName( "modifier_dawnbreaker_celestial_hammer_lua_thinker" )
		mod:Destroy()

		-- reset sub-ability
		local ability = caster:FindAbilityByName( "dawnbreaker_converge_lua" )
		if ability then
			caster:SwapAbilities(
				"dawnbreaker_celestial_hammer_lua",
				"dawnbreaker_converge_lua",
				true,
				false
			)
		end

		-- remove nohammer
		local nohammer = caster:FindModifierByName( "modifier_dawnbreaker_celestial_hammer_lua_nohammer" )
		if nohammer then
			nohammer:Decrement()
		end

		-- destroy converge modifier
		local converge = caster:FindModifierByName( "modifier_dawnbreaker_celestial_hammer_lua" )
		if converge then
			converge:Destroy()
			self:GetCaster():FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_2)
		end

		-- destroy handle
		self.projectiles[handle] = nil

		-- play effects
		self:PlayEffects3()
	end
end

--------------------------------------------------------------------------------
-- Helper
function dawnbreaker_celestial_hammer_lua:HammerHit( target, location )
	local damage = self:GetSpecialValueFor( "hammer_damage" )

	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)

	if self:GetCaster():HasAbility("dawnbreaker_celestial_hammer_lua_illusion") and RollPseudoRandomPercentage(self:GetCaster():FindAbilityByName("dawnbreaker_celestial_hammer_lua_illusion"):GetLevelSpecialValueFor("chance",1),DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, self:GetCaster())  then
		local illusion_damage_pct = self:GetCaster():FindAbilityByName("dawnbreaker_celestial_hammer_lua_illusion"):GetLevelSpecialValueFor("illusion_damage_pct",1)				
		local illusion_incoming_dmg = self:GetCaster():FindAbilityByName("dawnbreaker_celestial_hammer_lua_illusion"):GetLevelSpecialValueFor("illusion_incoming_dmg",1)	
		
		local modifierKeys = {}
		modifierKeys.outgoing_damage = illusion_damage_pct - 100
		modifierKeys.incoming_damage = illusion_incoming_dmg
		modifierKeys.duration = 9
		
		local illusion = CreateIllusions( self:GetCaster(), self:GetCaster(), modifierKeys, 1, 70, true, true)
		illusion[1]:AddNewModifier(self:GetCaster(), self, "modifier_phantom_lancer_juxtapose_illusion", {})
		illusion[1]:AddNewModifier(self:GetCaster(), self, "modifier_phased", {})
		illusion[1]:AddNewModifier(self:GetCaster(), self, "modifier_no_healthbar", {})
		illusion[1]:SetControllableByPlayer(-1, true)			
		FindClearSpaceForUnit(illusion[1], location, false)
	end

	-- play effects
	self:PlayEffects2( target )
end

function dawnbreaker_celestial_hammer_lua:Converge()
	local caster = self:GetCaster()

	local target
	for i,thinker in ipairs(self.thinkers) do
		target = thinker
		break
	end
	if not target then return end

	-- find projectile if exist
	if self.projectiles[target.id] then
		-- stop effect
		self:StopEffects( self.projectiles[target.id].effect )

		-- destroy projectile
		self.projectiles[target.id] = nil
		ProjectileManager:DestroyLinearProjectile( target.id )
	end

	-- set thinker to return
	local mod = target:FindModifierByName( "modifier_dawnbreaker_celestial_hammer_lua_thinker" )
	mod:Return()


	-- add travel modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_dawnbreaker_celestial_hammer_lua", -- modifier name
		{
			target = target:entindex(),
		} -- kv
	)

	-- play effects
	local sound_cast = "Hero_Dawnbreaker.Converge.Cast"
	EmitSoundOn( sound_cast, caster )
	self:GetCaster():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)

	converge_voiceline = {
			"dawnbreaker_valora_call_01",
			"dawnbreaker_valora_call_02",
			"dawnbreaker_valora_call_03",
			"dawnbreaker_valora_call_04",
			"dawnbreaker_valora_call_05",
			"dawnbreaker_valora_call_06",
			"dawnbreaker_valora_call_06_02",
			"dawnbreaker_valora_call_07",
			"dawnbreaker_valora_call_07_02",
			"dawnbreaker_valora_call_08",
			"dawnbreaker_valora_call_18",			
	}
	self:GetCaster():EmitSound(converge_voiceline[RandomInt(1, #converge_voiceline)])			
end

--------------------------------------------------------------------------------
-- Effects
function dawnbreaker_celestial_hammer_lua:PlayEffects1( start, distance, velocity )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_projectile.vpcf"
	local sound_cast = "Hero_Dawnbreaker.Celestial_Hammer.Cast"

	-- Get Data
	local min_rate = 1
	local duration = distance/velocity:Length2D()
	local rotation = 0.5

	local rate = rotation/duration
	while rate<min_rate do
		rotation = rotation + 1
		rate = rotation/duration
	end

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, start )
	ParticleManager:SetParticleControl( effect_cast, 1, velocity )
	ParticleManager:SetParticleControl( effect_cast, 4, Vector( rate, 0, 0 ) )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )

	return effect_cast
end

function dawnbreaker_celestial_hammer_lua:PlayEffects2( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_aoe_impact.vpcf"
	local sound_cast = "Hero_Dawnbreaker.Celestial_Hammer.Damage"

	-- Get Data
	local radius = self:GetSpecialValueFor( "projectile_radius" )

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, target )
end

function dawnbreaker_celestial_hammer_lua:PlayEffects3()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge.vpcf"

	-- Get Data
	local radius = self:GetSpecialValueFor( "projectile_radius" )

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		3,
		hTarget,
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function dawnbreaker_celestial_hammer_lua:StopEffects( effect )
	ParticleManager:DestroyParticle( effect, false )
	ParticleManager:ReleaseParticleIndex( effect )
end

--------------------------------------------------------------------------------
-- Sub-ability: Converge
dawnbreaker_converge_lua = class({})

function dawnbreaker_converge_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	local main = caster:FindAbilityByName( "dawnbreaker_celestial_hammer_lua" )
	if main then
		main:Converge()
	end

	-- set as inactive
	self:SetActivated( false )
end