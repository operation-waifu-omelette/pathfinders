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
modifier_dark_willow_bedlam_lua_attack = class({})
LinkLuaModifier( "dark_willow_bramble_maze_lua", "pathfinder/dark_willow/dark_willow_bramble_maze_lua/dark_willow_bramble_maze_lua", LUA_MODIFIER_MOTION_NONE )


--------------------------------------------------------------------------------
-- Classifications
function modifier_dark_willow_bedlam_lua_attack:IsHidden()
	return false
end

function modifier_dark_willow_bedlam_lua_attack:IsDebuff()
	return false
end

function modifier_dark_willow_bedlam_lua_attack:IsStunDebuff()
	return false
end

function modifier_dark_willow_bedlam_lua_attack:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_dark_willow_bedlam_lua_attack:OnCreated( kv )
	-- references
	local damage = self:GetAbility():GetSpecialValueFor( "attack_damage" )
	self.interval = self:GetAbility():GetSpecialValueFor( "attack_interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "attack_radius" )

	if self:GetCaster():FindAbilityByName("dark_willow_bedlam_lua_blitz") then
		self.interval = self:GetAbility():GetSpecialValueFor( "attack_interval" ) * self:GetCaster():FindAbilityByName("dark_willow_bedlam_lua_blitz"):GetSpecialValueFor("speed_multiplier")
		self.radius = self:GetAbility():GetSpecialValueFor( "attack_radius" ) + self:GetCaster():FindAbilityByName("dark_willow_bedlam_lua_blitz"):GetSpecialValueFor("add_range")
		damage = damage + self:GetCaster():GetAttackDamage() 
	end
	

	

	if not IsServer() then return end
	-- precache projectile
	-- local projectile_name = "particles/units/heroes/hero_dark_willow/dark_willow_willowisp_base_attack.vpcf"
	local projectile_name = ""
	local projectile_speed = 1400

	self.info = {
		-- Target = target,
		Source = self:GetParent(),
		Ability = self:GetAbility(),	
		
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = true,                           -- Optional
		-- bIsAttack = false,                                -- Optional

		ExtraData = {
			damage = damage,
		}
	}

	-- Start interval
	self:StartIntervalThink( self.interval )

	-- play effects
	self:PlayEffects()
end

function modifier_dark_willow_bedlam_lua_attack:OnRefresh( kv )
	-- references
	local damage = self:GetAbility():GetSpecialValueFor( "attack_damage" )
	self.interval = self:GetAbility():GetSpecialValueFor( "attack_interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "attack_radius" )

	if self:GetCaster():FindAbilityByName("dark_willow_bedlam_lua_blitz") then
		self.interval = self:GetAbility():GetSpecialValueFor( "attack_interval" ) * self:GetCaster():FindAbilityByName("dark_willow_bedlam_lua_blitz"):GetSpecialValueFor("speed_multiplier")
		self.radius = self:GetAbility():GetSpecialValueFor( "attack_radius" ) + self:GetCaster():FindAbilityByName("dark_willow_bedlam_lua_blitz"):GetSpecialValueFor("add_range")
		damage = damage + self:GetCaster():GetAttackDamage() 
	end

	if not IsServer() then return end
	-- update projectile
	self.info.ExtraData.damage = 0

	-- play effects
	local sound_cast = "Hero_DarkWillow.WispStrike.Cast"
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_dark_willow_bedlam_lua_attack:OnRemoved()
end

function modifier_dark_willow_bedlam_lua_attack:OnDestroy()
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_dark_willow_bedlam_lua_attack:OnIntervalThink()
	-- find enemies
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		-- create projectile effect
		local effect = self:PlayEffects1( enemy, self.info.iMoveSpeed )

		-- launch attack
		self.info.Target = enemy
		self.info.ExtraData.effect = effect

		ProjectileManager:CreateTrackingProjectile( self.info )

		-- play effects
		local sound_cast = "Hero_DarkWillow.WillOWisp.Damage"
		EmitSoundOn( sound_cast, self:GetParent() )

		-- brambles for snare
		if IsServer() then
			if self:GetCaster():HasAbility("dark_willow_bedlam_lua_snare") and self:GetCaster():FindAbilityByName("dark_willow_bramble_maze_lua"):IsTrained() then
				if not enemy:IsRooted() then -- if not already rooted
					self:GetCaster():FindAbilityByName("dark_willow_bramble_maze_lua"):PlaceSingleBramble(enemy:GetOrigin())
				end
			end
		end

		-- only on first unit
		break
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_dark_willow_bedlam_lua_attack:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_dark_willow/dark_willow_wisp_aoe.vpcf"
	local sound_cast = "Hero_DarkWillow.WispStrike.Cast"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	-- local effect_cast = assert(loadfile("pathfinder/rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, self.radius, self.radius ) )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_dark_willow_bedlam_lua_attack:PlayEffects1( target, speed )
	local particle_cast = "particles/units/heroes/hero_dark_willow/dark_willow_willowisp_base_attack.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	-- local effect_cast = assert(loadfile("pathfinder/rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )

	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( speed, 0, 0 ) )

	return effect_cast
end