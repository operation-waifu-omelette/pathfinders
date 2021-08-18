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
require("libraries.timers")
--------------------------------------------------------------------------------
ogre_magi_fireblast_lua = class({})
LinkLuaModifier( "modifier_ogre_magi_fireblast_gold", "pathfinder/ogre_magi_fireblast_lua/ogre_magi_fireblast_lua.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function ogre_magi_fireblast_lua:Spawn()
	if not IsServer() then return end
	local this = self
	Timers(2, function()
		if IsValidEntity(this) and this:GetCaster():FindAbilityByName("pathfinder_special_om_gold_fireblast") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ogre_magi_fireblast_gold", {})
			return nil			
		else
			return 2
		end
	end)	
end

function ogre_magi_fireblast_lua:GetBehavior()
	if self:GetCaster():FindAbilityByName("pathfinder_special_om_aoe_fireblast") then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
	else
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end
end

function ogre_magi_fireblast_lua:GetAOERadius()
	if self:GetCaster():FindAbilityByName("pathfinder_special_om_aoe_fireblast") then
		return self:GetCaster():FindAbilityByName("pathfinder_special_om_aoe_fireblast"):GetLevelSpecialValueFor("aoe", 1)
	end
end


-- Ability Start
function ogre_magi_fireblast_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	if not target then return end

	-- cancel if linken
	if target:TriggerSpellAbsorb( self ) then
		return
	end

	-- load data
	local duration = self:GetSpecialValueFor( "stun_duration" )
	local damage = self:GetSpecialValueFor( "fireblast_damage" )

	-- Apply damage
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
	}
	ApplyDamage( damageTable )

	-- stun
	target:AddNewModifier(
		self:GetCaster(),
		self, 
		"modifier_stunned", 
		{duration = duration}
	)	

	-- play effects
	self:PlayEffects( target )

	if IsServer() and self:GetCaster():HasAbility("pathfinder_special_om_aoe_fireblast") then
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
			target:GetAbsOrigin(),
			nil,
			self:GetCaster():FindAbilityByName("pathfinder_special_om_aoe_fireblast"):GetLevelSpecialValueFor("aoe", 1),
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			FIND_ANY_ORDER,
			false )

		for _,enemy in pairs(enemies) do
			if enemy and enemy ~= target then
				local damageTable = {
					victim = enemy,
					attacker = caster,
					damage = damage,
					damage_type = self:GetAbilityDamageType(),
					ability = self, --Optional.
				}
				ApplyDamage( damageTable )

				-- stun
				enemy:AddNewModifier(
					self:GetCaster(),
					self, 
					"modifier_stunned", 
					{duration = duration}
				)

				-- play effects
				self:PlayEffects( enemy )				
			end
		end
	end
end

--------------------------------------------------------------------------------
function ogre_magi_fireblast_lua:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_ogre_magi/ogre_magi_fireblast.vpcf"
	local sound_cast = "Hero_OgreMagi.Fireblast.Cast"
	local sound_target = "Hero_OgreMagi.Fireblast.Target"

	-- Create Particle
	-- local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
	EmitSoundOn( sound_target, target )
end


--------
---------
-----------

modifier_ogre_magi_fireblast_gold = class({})

function modifier_ogre_magi_fireblast_gold:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH ,		
	}

	return funcs
end

function modifier_ogre_magi_fireblast_gold:IsHidden()
	return true
end

function modifier_ogre_magi_fireblast_gold:IsDebuff()
	return false
end

function modifier_ogre_magi_fireblast_gold:IsPurgable()
	return false
end
function modifier_ogre_magi_fireblast_gold:RemoveOnDeath()
	return false
end

function modifier_ogre_magi_fireblast_gold:OnDeath(params)
	if params.attacker == self:GetCaster() and params.inflictor == self:GetAbility() then

		local big_gold = self:GetCaster():FindAbilityByName("pathfinder_special_om_gold_fireblast"):GetLevelSpecialValueFor("captain_gold",1)
		local small_gold = self:GetCaster():FindAbilityByName("pathfinder_special_om_gold_fireblast"):GetLevelSpecialValueFor("creep_gold",1)

		local bag = CreateItem( "item_bag_of_gold", nil, nil )

		if params.unit:IsConsideredHero() then
			bag:SetCurrentCharges(big_gold)
		else
			bag:SetCurrentCharges(small_gold)
		end

		CreateItemOnPositionForLaunch( params.unit:GetAbsOrigin(), bag )
		bag:LaunchLootInitialHeight( true, 0, 250, 0.75, params.unit:GetAbsOrigin() + RandomVector(RandomFloat(10,50)) )
		EmitSoundOn( "Dungeon.TreasureItemDrop", params.unit )
	end
end