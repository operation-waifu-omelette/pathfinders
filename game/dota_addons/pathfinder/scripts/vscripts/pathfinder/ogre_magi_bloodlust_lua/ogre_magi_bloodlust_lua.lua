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

ogre_magi_bloodlust_lua = class({})
LinkLuaModifier( "modifier_ogre_magi_bloodlust_lua", "pathfinder/ogre_magi_bloodlust_lua/modifier_ogre_magi_bloodlust_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ogre_magi_bloodlust_lua_buff", "pathfinder/ogre_magi_bloodlust_lua/modifier_ogre_magi_bloodlust_lua_buff", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function ogre_magi_bloodlust_lua:GetIntrinsicModifierName()
	return "modifier_ogre_magi_bloodlust_lua"
end

--------------------------------------------------------------------------------
-- Ability Start
function ogre_magi_bloodlust_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- load data
	local duration = self:GetSpecialValueFor( "duration" )

	-- add buff
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_ogre_magi_bloodlust_lua_buff", -- modifier name
		{ duration = duration } -- kv
	)

	if caster:FindAbilityByName("pathfinder_special_bloodlust_fear") then
		local radius = caster:FindAbilityByName("pathfinder_special_bloodlust_fear"):GetLevelSpecialValueFor("radius",1)
		local fear_duration = caster:FindAbilityByName("pathfinder_special_bloodlust_fear"):GetLevelSpecialValueFor("duration",1)

		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
			target:GetAbsOrigin(),
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			FIND_ANY_ORDER,
			false )

		for _,enemy in pairs(enemies) do
			local unit_name = enemy:GetUnitName()
			if unit_name ~= "pathfinder_frost_boss" and unit_name ~= "npc_dota_boss_timbersaw" and unit_name ~= "npc_dota_creature_temple_guardian" and unit_name ~= "npc_dota_boss_void_spirit" and unit_name ~= "npc_dota_creature_storegga" and unit_name ~= "npc_dota_boss_aghanim" then
				enemy:AddNewModifier(
					self:GetCaster(),
					self, 
					"modifier_nevermore_requiem_fear", 
					{duration = fear_duration}
				)
			end
		end		
	end

	-- play effects
	self:PlayEffects( target )
end

function ogre_magi_bloodlust_lua:FireShieldProjectile(attacker, target)
	local info = {
			Target = target,
			Source = attacker,
			Ability = self,	
			EffectName = "particles/units/heroes/hero_ogre_magi/ogre_magi_fire_shield_projectile.vpcf",
			iMoveSpeed = 900,
			bReplaceExisting = false,                         -- Optional
			bProvidesVision = true,                           -- Optional
			iVisionRadius = 50,				-- Optional
			iVisionTeamNumber = attacker:GetTeamNumber()  ,      -- Optional			
		}
	ProjectileManager:CreateTrackingProjectile(info)	
end

function ogre_magi_bloodlust_lua:OnProjectileHit(hTarget, vLocation)
	if self:GetCaster():FindAbilityByName("pathfinder_special_om_shield_bloodlust") and hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then		
		self:GetCaster():PerformAttack(hTarget, false, true, true, false, false, false, true)
	end	
end

--------------------------------------------------------------------------------
function ogre_magi_bloodlust_lua:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_cast.vpcf"
	local sound_cast = "Hero_OgreMagi.Bloodlust.Cast"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		2,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		3,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
end