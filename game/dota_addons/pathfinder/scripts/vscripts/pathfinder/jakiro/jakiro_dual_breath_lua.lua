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
require("libraries.has_shard")
--------------------------------------------------------------------------------
jakiro_dual_breath_lua = class({})
LinkLuaModifier( "modifier_jakiro_dual_breath_lua", "pathfinder/jakiro/modifier_jakiro_dual_breath_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_jakiro_dual_breath_lua_fire", "pathfinder/jakiro/modifier_jakiro_dual_breath_lua_fire", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_jakiro_dual_breath_lua_ice", "pathfinder/jakiro/modifier_jakiro_dual_breath_lua_ice", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pathfinder_jakiro_dual_breath_fart", "pathfinder/jakiro/jakiro_dual_breath_lua", LUA_MODIFIER_MOTION_NONE )
require("libraries.timers")
--------------------------------------------------------------------------------

function jakiro_dual_breath_lua:Spawn()
	if IsServer() then		
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pathfinder_jakiro_dual_breath_fart", {})
	end
end

function jakiro_dual_breath_lua:GetCastRange(vLocation, hTarget)				
	return self:GetLevelSpecialValueFor( "range", self:GetLevel() - 1 )	
end

-- Ability Start
function jakiro_dual_breath_lua:OnSpellStart()		
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local point = self:GetCursorPosition()

	-- load data
	local delay = self:GetSpecialValueFor( "fire_delay" )

	-- set position
	if target then
		point = target:GetOrigin()
	end

	-- create modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_jakiro_dual_breath_lua", -- modifier name
		{
			duration = delay,
			x = point.x,
			y = point.y,
		} -- kv
	)
end


--------------------------------------------------------------------------------
-- Projectile
function jakiro_dual_breath_lua:OnProjectileHit_ExtraData( target, location, data )
	if not target then return end

	-- load data
	local caster = self:GetCaster()
	local delay = self:GetSpecialValueFor( "fire_delay" )
	local duration = self:GetSpecialValueFor( "duration" ) + FindTalentValue(self:GetCaster(), "special_bonus_unique_jakiro_dual_breath_duration")	

	-- determine which breath
	local modifier = "modifier_jakiro_dual_breath_lua_ice"
	if data.fire==1 then modifier = "modifier_jakiro_dual_breath_lua_fire" end

	-- add modifier
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		modifier, -- modifier name
		{ duration = duration } -- kv
	)

	local ice_path = self:GetCaster():FindAbilityByName("jakiro_ice_path_lua")
	local ice_blob_special = self:GetCaster():FindAbilityByName("pathfinder_jakiro_duel_breath_ice_blob")

	if data.fire ~= 1 and target and ice_blob_special and ice_path:GetLevel() > 0 then
		local chance = ice_blob_special:GetLevelSpecialValueFor("chance", 1)
		if RollPseudoRandomPercentage(chance,DOTA_PSEUDO_RANDOM_CUSTOM_GAME_3, self:GetCaster()) then
			local radius = ice_path:GetLevelSpecialValueFor("path_radius", ice_path:GetLevel() - 1)
			local front = target:GetAbsOrigin() + target:GetForwardVector() * (radius / 2)
			local back = target:GetAbsOrigin() + target:GetForwardVector() * -1 * (radius / 2)
			ice_path:IceFromAToB(front,back)						

		end
	end


	local liquid_fire = self:GetCaster():FindAbilityByName("jakiro_liquid_fire_lua")
	local liquid_fire_special = self:GetCaster():FindAbilityByName("pathfinder_jakiro_duel_breath_liquid_fire")

	if data.fire == 1 and target and liquid_fire_special and liquid_fire:GetLevel() > 0 then
		local chance = liquid_fire_special:GetLevelSpecialValueFor("chance", 1)
		if RollPseudoRandomPercentage(chance,DOTA_PSEUDO_RANDOM_CUSTOM_GAME_4, self:GetCaster()) then
			local old = self:GetCaster():GetCursorCastTarget()
			self:GetCaster():SetCursorCastTarget(target)
			liquid_fire:OnSpellStart()
			liquid_fire:EndCooldown()
			if old then
				self:GetCaster():SetCursorCastTarget(old)
			end
		end
	end
end


modifier_pathfinder_jakiro_dual_breath_fart = class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,
	RemoveOnDeath 			= function(self) return false end,
	AllowIllusionDuplicate	= function(self) return false end
})

function modifier_pathfinder_jakiro_dual_breath_fart:OnCreated( kv )	
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_pathfinder_jakiro_dual_breath_fart:OnIntervalThink()
	if self:GetCaster():HasAbility("pathfinder_jakiro_dual_breath_fart") and self:GetAbility():GetLevel() > 0 and not self:GetParent():IsSilenced() then
		local distance = self:GetAbility():GetSpecialValueFor( "range" ) + FindTalentValue(self:GetCaster(), "special_bonus_unique_jakiro_dual_breath_range")
		local start_radius = self:GetAbility():GetSpecialValueFor( "start_radius" )
		local end_radius = self:GetAbility():GetSpecialValueFor( "end_radius" )
		self.speed_ice = self:GetAbility():GetSpecialValueFor( "speed" )
		self.speed_fire = self:GetAbility():GetSpecialValueFor( "speed_fire" )

		if not IsServer() then return end
		local caster = self:GetCaster()

		-- calculate direction
		self.direction = self:GetParent():GetForwardVector() * -1
		self.direction.z = 0
		self.direction = self.direction:Normalized()
		
		local left_qangle = QAngle(0, -20, 0)		
		local right_qangle = QAngle(0, 20, 0)	

		local left_dir = RotatePosition(caster:GetAbsOrigin(), left_qangle, caster:GetAbsOrigin() + self.direction * 20) - caster:GetAbsOrigin()
		left_dir.z = 0
		left_dir  = left_dir:Normalized()

		local right_dir = RotatePosition(caster:GetAbsOrigin(), right_qangle, caster:GetAbsOrigin() + self.direction * 20) - caster:GetAbsOrigin()
		right_dir.z = 0
		right_dir = right_dir:Normalized()

		-- precache projectile
		self.info = {
			Source = caster,
			Ability = self:GetAbility(),
			vSpawnOrigin = caster:GetAbsOrigin(),
			
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			
			-- EffectName = projectile_name,
			fDistance = distance,
			fStartRadius = start_radius,
			fEndRadius = end_radius,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
			-- vVelocity = projectile_direction * speed_ice,
		}
		local chance = self:GetCaster():FindAbilityByName("pathfinder_jakiro_dual_breath_fart"):GetLevelSpecialValueFor("chance", 1)
		-- if RandomInt(1, 100) < chance then
		if RollPseudoRandomPercentage(chance,DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, self:GetCaster()) then
			if RollPseudoRandomPercentage(50,DOTA_PSEUDO_RANDOM_CUSTOM_GAME_2,self:GetCaster()) then
				self:BreatheFire()
				self.direction = left_dir
				self:BreatheFire()
				self.direction = right_dir
				self:BreatheFire()
			else
				self:BreatheIce()
				self.direction = left_dir
				self:BreatheIce()
				self.direction = right_dir
				self:BreatheIce()
			end

		end
	end
end

function modifier_pathfinder_jakiro_dual_breath_fart:BreatheFire()
	if not IsServer() then return end
	local caster = self:GetCaster()

	-- launch fire projectile
	self.info.EffectName = "particles/units/heroes/hero_jakiro/jakiro_dual_breath_fire.vpcf"
	self.info.vVelocity = self.direction * self.speed_fire
	self.info.ExtraData = {
		fire = 1
	}
	ProjectileManager:CreateLinearProjectile( self.info )

	
	local sound_cast = "Hero_Jakiro.DualBreath.Cast"
	EmitSoundOn( sound_cast, self:GetCaster() )

	local particle_cast = "particles/units/heroes/hero_jakiro/jakiro_dual_breath_fire_launch_2.vpcf"

	local caster = self:GetCaster()

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( effect_cast, 0, caster:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, self.info.vVelocity )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		9,
		caster,
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_pathfinder_jakiro_dual_breath_fart:BreatheIce()
	if not IsServer() then return end
	local caster = self:GetCaster()

	self.info.EffectName = "particles/units/heroes/hero_jakiro/jakiro_dual_breath_ice.vpcf"
	self.info.vVelocity = self.direction * self.speed_ice
	self.info.ExtraData = {
		fire = 0
	}
	ProjectileManager:CreateLinearProjectile( self.info )

	-- play effects
	local sound_cast = "Hero_Jakiro.DualBreath.Cast"
	EmitSoundOn( sound_cast, self:GetCaster() )	
end