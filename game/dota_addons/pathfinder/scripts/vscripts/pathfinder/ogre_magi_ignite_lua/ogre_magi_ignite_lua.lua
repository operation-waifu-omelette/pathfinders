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
ogre_magi_ignite_lua = class({})
LinkLuaModifier( "modifier_ogre_magi_ignite_lua", "pathfinder/ogre_magi_ignite_lua/modifier_ogre_magi_ignite_lua", LUA_MODIFIER_MOTION_NONE )

require("libraries.has_shard")
--------------------------------------------------------------------------------
-- Ability Start
function ogre_magi_ignite_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- load data
	local projectile_name = "particles/units/heroes/hero_ogre_magi/ogre_magi_ignite.vpcf"
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )

	-- create projectile
	local info = {
		Target = target,
		Source = caster,
		Ability = self,	
		
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = true,                           -- Optional
	}
	ProjectileManager:CreateTrackingProjectile(info)

	-- find secondary target
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self:GetCastRange( target:GetOrigin(), target ),	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	local target_2 = nil
	for _,enemy in pairs(enemies) do
		-- only target those who does not have debuff
		if enemy~=target and ( not enemy:HasModifier("modifier_ogre_magi_ignite_lua") ) then
			target_2 = enemy
			break
		end
	end

	-- create secondary projectile
	if target_2 then
		info.Target = target_2
		ProjectileManager:CreateTrackingProjectile(info)
	end

	-- play effects
	local sound_cast = "Hero_OgreMagi.Ignite.Cast"
	EmitSoundOn( sound_cast, caster )
end


function ogre_magi_ignite_lua:StartSpellFromTarget(source_unit)
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- load data
	local projectile_name = "particles/units/heroes/hero_ogre_magi/ogre_magi_ignite.vpcf"
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )

	-- create projectile
	local info = {
		Target = target,
		Source = source_unit,
		Ability = self,	
		
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = true,                           -- Optional
	}
	ProjectileManager:CreateTrackingProjectile(info)

	if target then
		-- find secondary target
		local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(),	-- int, your team number
			source_unit:GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self:GetCastRange( target:GetOrigin(), target ),	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		local target_2 = nil
		for _,enemy in pairs(enemies) do
			-- only target those who does not have debuff
			if enemy~=target and ( not enemy:HasModifier("modifier_ogre_magi_ignite_lua") ) then
				target_2 = enemy
				break
			end
		end

		-- create secondary projectile
		if target_2 then
			info.Target = target_2
			ProjectileManager:CreateTrackingProjectile(info)
		end
	end

	-- play effects
	local sound_cast = "Hero_OgreMagi.Ignite.Cast"
	EmitSoundOn( sound_cast, caster )
end

--------------------------------------------------------------------------------
-- Projectile
function ogre_magi_ignite_lua:OnProjectileHit( target, location )
	if not target then return end
	

	if IsServer() and target and self:GetCaster():HasAbility("pathfinder_special_friendly_ignite") and target:GetTeamNumber() == DOTA_TEAM_BADGUYS then
		local allies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, target:GetAbsOrigin(), nil, self:GetCastRange(location, nil), DOTA_TEAM_GOODGUYS, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
		local projectile_name = "particles/units/heroes/hero_ogre_magi/ogre_magi_ignite.vpcf"
		local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )

		if #allies > 0 then
			local ally = allies[RandomInt(1, #allies)]
			

			local info = {
			Target = ally,
			Source = target,
			Ability = self,	
			
			EffectName = projectile_name,
			iMoveSpeed = projectile_speed,
			bDodgeable = false,                           -- Optional
			}
			ProjectileManager:CreateTrackingProjectile(info)
		end
	elseif target:TriggerSpellAbsorb( self ) then return end

	-- load data
	local duration = self:GetSpecialValueFor( "duration" )

	-- add debuff
	target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_ogre_magi_ignite_lua", -- modifier name
		{ duration = duration } -- kv
	)

	if self:GetCaster():HasAbility("pathfinder_special_ignite_fireblast") and self:GetCaster():FindAbilityByName("ogre_magi_fireblast_lua"):GetLevel() > 0 and target:GetTeamNumber() == DOTA_TEAM_BADGUYS then
		local chance = self:GetCaster():FindAbilityByName("pathfinder_special_ignite_fireblast"):GetLevelSpecialValueFor("chance", 1)
		if RandomInt(1,100) < chance then
			self:GetCaster():SetCursorCastTarget(target)
			self:GetCaster():FindAbilityByName("ogre_magi_fireblast_lua"):OnSpellStart()
			if self:GetCaster():HasModifier("modifier_ogre_magi_multicast_lua") then
				local param = {}
				param.unit = self:GetCaster()
				param.ability = self:GetCaster():FindAbilityByName("ogre_magi_fireblast_lua")
				param.target = target				
				self:GetCaster():FindModifierByName("modifier_ogre_magi_multicast_lua"):OnAbilityFullyCast(param)
			end
		end
	end

	-- play effects
	local sound_cast = "Hero_OgreMagi.Ignite.Target"
	EmitSoundOn( sound_cast, self:GetCaster() )
end