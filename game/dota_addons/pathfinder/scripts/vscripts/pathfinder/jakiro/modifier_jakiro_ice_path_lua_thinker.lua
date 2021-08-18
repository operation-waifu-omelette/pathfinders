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
modifier_jakiro_sepcial_ice_path_fast = class({})
function modifier_jakiro_sepcial_ice_path_fast:IsHidden()
	return false
end
function modifier_jakiro_sepcial_ice_path_fast:RemoveOnDeath()
	return true
end
function modifier_jakiro_sepcial_ice_path_fast:IsDebuff()
	return false
end

function modifier_jakiro_sepcial_ice_path_fast:CheckState()
	if not IsServer() then return end
	local state = {
	[MODIFIER_STATE_UNSLOWABLE] = true,
	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}

	return state
end

function modifier_jakiro_sepcial_ice_path_fast:DeclareFunctions() 
  local funcs = {
	MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT ,
	MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT ,
	MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,	
  }
 
  return funcs
end

function modifier_jakiro_sepcial_ice_path_fast:GetModifierMoveSpeedBonus_Constant()
	return self.ice_speed * ( self:GetRemainingTime() /self:GetDuration() )
end

function modifier_jakiro_sepcial_ice_path_fast:GetModifierIgnoreMovespeedLimit()
	return 1
end

function modifier_jakiro_sepcial_ice_path_fast:GetActivityTranslationModifiers()
	return "haste"
end

function modifier_jakiro_sepcial_ice_path_fast:GetEffectName()	
	return "particles/econ/items/spirit_breaker/spirit_breaker_iron_surge/spirit_breaker_charge_iron.vpcf"
end

function modifier_jakiro_sepcial_ice_path_fast:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


function modifier_jakiro_sepcial_ice_path_fast:OnCreated( kv )
	if IsServer() and self:GetAbility():GetCaster():HasAbility("pathfinder_jakiro_ice_path_fast") then
		local special = self:GetAbility():GetCaster():FindAbilityByName("pathfinder_jakiro_ice_path_fast")	

		self.ice_speed = special:GetLevelSpecialValueFor("move_speed", 1)		
		self.ice_speed_talent = true
		
		self:GetParent():Purge(false, true, false, true, false)		

		
		self:SetHasCustomTransmitterData( true )		
	end
end

function modifier_jakiro_sepcial_ice_path_fast:AddCustomTransmitterData( )

	return
	{
		ice_speed = self.ice_speed,
		ice_speed_talent = self.ice_speed_talent,
	}
end

--------------------------------------------------------------------------------

function modifier_jakiro_sepcial_ice_path_fast:HandleCustomTransmitterData( data )
	self.ice_speed = data.ice_speed
	self.ice_speed_talent = data.ice_speed_talent
end



--------------------------------------------------------------------------------
modifier_jakiro_ice_path_lua_thinker = class({})
LinkLuaModifier( "modifier_jakiro_sepcial_ice_path_fast", "pathfinder/jakiro/modifier_jakiro_ice_path_lua_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_jakiro_sepcial_ice_path_armour", "pathfinder/jakiro/modifier_jakiro_ice_path_lua", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
-- Classifications
function modifier_jakiro_ice_path_lua_thinker:IsHidden()
	return false
end

function modifier_jakiro_ice_path_lua_thinker:IsDebuff()
	return false
end

function modifier_jakiro_ice_path_lua_thinker:IsStunDebuff()
	return false
end

function modifier_jakiro_ice_path_lua_thinker:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_jakiro_ice_path_lua_thinker:OnCreated( kv )
	self.parent = self:GetParent()
	self.caster = self:GetCaster()

	-- references
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.range = self:GetAbility():GetLevelSpecialValueFor( "range", self:GetAbility():GetLevel() - 1 ) + self.caster:GetCastRangeBonus()
	self.delay = self:GetAbility():GetSpecialValueFor( "path_delay" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.radius = self:GetAbility():GetSpecialValueFor( "path_radius" )

	if not IsServer() then return end	
		

	-- ability properties
	self.abilityDamageType = self:GetAbility():GetAbilityDamageType()
	self.abilityTargetTeam = self:GetAbility():GetAbilityTargetTeam()
	self.abilityTargetType = self:GetAbility():GetAbilityTargetType()
	self.abilityTargetFlags = self:GetAbility():GetAbilityTargetFlags()

	-- set up data
	self.delayed = true
	self.targets = {}	

	
	
	local a = Vector(kv.ax,kv.ay,kv.az)
	local b = Vector(kv.bx,kv.by,kv.bz)

	-- calculate direction
	local dir = b - a
	dir.z = 0
	self.direction = dir:Normalized()
	self.startpoint = a
	self.endpoint = b
	

	-- self.startpoint = self.parent:GetOrigin() + self.direction + start_range
	-- self.endpoint = self.startpoint + self.direction * self.range

	-- precache damage
	self.damageTable = {
		-- victim = target,
		attacker = self.caster,
		damage = damage,
		damage_type = self.abilityDamageType,
		ability = self:GetAbility(), --Optional.
	}
	-- ApplyDamage(damageTable)

	-- Start interval
	self:StartIntervalThink( self.delay )

	-- play effects
	self:PlayEffects1()
	self:PlayEffects2()
end

function modifier_jakiro_ice_path_lua_thinker:OnRefresh( kv )
end

function modifier_jakiro_ice_path_lua_thinker:OnRemoved()
end

function modifier_jakiro_ice_path_lua_thinker:OnDestroy()
	if not IsServer() then return end
	UTIL_Remove( self:GetParent() )
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_jakiro_ice_path_lua_thinker:OnIntervalThink()
	if self.delayed then
		-- after the delay
		self.delayed = false
		self:SetDuration( self.duration, false )
		self:StartIntervalThink( 0.03 )

		-- create vision along line
		local step = 0
		while step < self.range do
			local loc = self.startpoint + self.direction * step
			AddFOWViewer(
				self.caster:GetTeamNumber(),
				loc,
				self.radius,
				self.duration,
				false
			)

			step = step + self.radius
		end

		-- play effects
		return
	end

	-- continuously find units in line
	local enemies = FindUnitsInLine(
		self.caster:GetTeamNumber(),	-- int, your team number
		self.startpoint,	-- point, center point
		self.endpoint,
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		self.abilityTargetTeam,	-- int, team filter
		self.abilityTargetType,	-- int, type filter
		self.abilityTargetFlags	-- int, flag filter
	)

	for _,enemy in pairs(enemies) do
		-- add modifier
		local duration = self:GetRemainingTime()
		enemy:AddNewModifier(
			self.caster, -- player source
			self:GetAbility(), -- ability source
			"modifier_jakiro_ice_path_lua", -- modifier name
			{ duration = duration } -- kv
		)
		-- only for uncaught enemies
		if not self.targets[enemy] then

			-- set as caught
			self.targets[enemy] = true									
			self.damageTable.victim = enemy
			ApplyDamage( self.damageTable )
		end
	end


	if self:GetCaster():HasAbility("pathfinder_jakiro_ice_path_fast") then				
		local allies = FindUnitsInLine(
			self.caster:GetTeamNumber(),	-- int, your team number
			self.startpoint,	-- point, center point
			self.endpoint,
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO,	-- int, type filter
			0	-- int, flag filter
		)		
		for _,ally in pairs(allies) do
			ally:AddNewModifier(
				self.caster, -- player source
				self:GetAbility(), -- ability source
				"modifier_jakiro_sepcial_ice_path_fast", -- modifier name
				{ duration = 3 } -- kv
			)
		end
	end

	if self:GetCaster():HasAbility("pathfinder_jakiro_ice_path_armour") then		
		local allies = FindUnitsInLine(
			self.caster:GetTeamNumber(),	-- int, your team number
			self.startpoint,	-- point, center point
			self.endpoint,
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO,	-- int, type filter
			0	-- int, flag filter
		)		

		local buff_duration_mult = self:GetCaster():FindAbilityByName("pathfinder_jakiro_ice_path_armour"):GetLevelSpecialValueFor("buff_duration_mult",1)
		for _,ally in pairs(allies) do
			ally:AddNewModifier(
				self.caster, -- player source
				self:GetAbility(), -- ability source
				"modifier_jakiro_sepcial_ice_path_armour", -- modifier name
				{ duration = self.duration * buff_duration_mult } -- kv
			)
		end
	end

end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_jakiro_ice_path_lua_thinker:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_jakiro/jakiro_ice_path.vpcf"
	local sound_cast = "Hero_Jakiro.IcePath.Cast"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self.parent )
	ParticleManager:SetParticleControl( effect_cast, 0, self.startpoint )
	ParticleManager:SetParticleControl( effect_cast, 1, self.endpoint )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( 0, 0, self.delay ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self.parent )
end

function modifier_jakiro_ice_path_lua_thinker:PlayEffects2()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_jakiro/jakiro_ice_path_b.vpcf"
	local sound_cast = "Hero_Jakiro.IcePath"

	-- Get Data

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self.parent )
	ParticleManager:SetParticleControl( effect_cast, 0, self.startpoint )
	ParticleManager:SetParticleControl( effect_cast, 1, self.endpoint )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( self.delay + self.duration, 0, 0 ) )
	ParticleManager:SetParticleControl( effect_cast, 9, self.startpoint )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		9,
		self.caster,
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self.parent )
end