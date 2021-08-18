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
--------------------------------------------------------------------------------modifier_dawnbreaker_luminosity_lua_charge
dawnbreaker_luminosity_lua = class({})

require("libraries.timers")

LinkLuaModifier( "modifier_dawnbreaker_luminosity_lua", "pathfinder/dawnbreaker_luminosity_lua/modifier_dawnbreaker_luminosity_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dawnbreaker_luminosity_lua_charge", "pathfinder/dawnbreaker_luminosity_lua/dawnbreaker_luminosity_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dawnbreaker_luminosity_lua_buff", "pathfinder/dawnbreaker_luminosity_lua/modifier_dawnbreaker_luminosity_lua_buff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dawnbreaker_celestial_hammer_lua_nohammer", "pathfinder/dawnbreaker_celestial_hammer_lua/modifier_dawnbreaker_celestial_hammer_lua_nohammer", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_dawnbreaker_celestial_hammer_lua_attach_trail", "pathfinder/dawnbreaker_celestial_hammer_lua/modifier_dawnbreaker_celestial_hammer_lua", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
-- Init Abilities
function dawnbreaker_luminosity_lua:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dawnbreaker.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_sven.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_huskar.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_luminosity.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_luminosity_attack_buff.vpcf", context )
end

function dawnbreaker_luminosity_lua:Spawn()
	if not IsServer() then return end
end

function dawnbreaker_luminosity_lua:GetBehavior()
	if self:GetCaster():FindAbilityByName("dawnbreaker_luminosity_lua_charge") then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function dawnbreaker_luminosity_lua:GetAOERadius()
	if self:GetCaster():FindAbilityByName("dawnbreaker_luminosity_lua_charge") then
		return self:GetCaster():FindAbilityByName("dawnbreaker_luminosity_lua_charge"):GetLevelSpecialValueFor("aoe", 1)
	end
end

function dawnbreaker_luminosity_lua:GetManaCost(iLevel)
	if self:GetCaster():FindAbilityByName("dawnbreaker_luminosity_lua_charge") then
		return 25	
	end
end

--------------------------------------------------------------------------------
-- Passive Modifier
function dawnbreaker_luminosity_lua:GetIntrinsicModifierName()
	return "modifier_dawnbreaker_luminosity_lua"
end

function dawnbreaker_luminosity_lua:GetCastRange(vLocation, hTarget)
	if self:GetCaster():FindAbilityByName("dawnbreaker_luminosity_lua_charge") then
		return self:GetCaster():FindAbilityByName("dawnbreaker_luminosity_lua_charge"):GetLevelSpecialValueFor("range",1)
	else
		return self:GetSpecialValueFor("heal_radius")
	end
end

function dawnbreaker_luminosity_lua:OnAbilityPhaseStart()
	if not IsServer() or not self:GetCaster():HasAbility("dawnbreaker_luminosity_lua_charge") then return end

	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_sven/sven_spell_storm_bolt_lightning.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetOrigin(), true )
	local vLightningOffset = self:GetCaster():GetOrigin() + Vector( 0, 0, 1600 )
	ParticleManager:SetParticleControl( nFXIndex, 1, vLightningOffset )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
	return true
end

function dawnbreaker_luminosity_lua:OnSpellStart()	
	if not IsServer() or not self:GetCaster():HasAbility("dawnbreaker_luminosity_lua_charge") then return end

	local bolt_speed = 900

	local info = {
			EffectName = "particles/units/heroes/hero_sven/sven_spell_storm_bolt.vpcf",
			Ability = self,
			iMoveSpeed = bolt_speed,
			Source = self:GetCaster(),
			Target = self:GetCursorTarget(),
			bDodgeable = true,
			bProvidesVision = true,
			iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
			iVisionRadius = 250,			
		}

	local proj = ProjectileManager:CreateTrackingProjectile( info )

	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_dawnbreaker_luminosity_lua_charge", {projID = tostring(proj), duration = 3} )

	EmitSoundOn( "Hero_Sven.StormBolt", self:GetCaster() )
end

function dawnbreaker_luminosity_lua:OnProjectileHit( hTarget, vLocation )
	if IsServer() and self:GetCaster():HasAbility("dawnbreaker_luminosity_lua_charge") and hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) then
		EmitSoundOn( "Hero_Sven.StormBoltImpact", hTarget )
		local bolt_aoe = self:GetCaster():FindAbilityByName("dawnbreaker_luminosity_lua_charge"):GetLevelSpecialValueFor("aoe", 1)
		local stun_duration = self:GetCaster():FindAbilityByName("dawnbreaker_luminosity_lua_charge"):GetLevelSpecialValueFor("stun_duration", 1)

		local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), hTarget:GetOrigin(), hTarget, bolt_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
					enemy:AddNewModifier( self:GetCaster(), self, "modifier_stunned", { duration = stun_duration * (1 - enemy:GetStatusResistance())} )
				end
			end
		end		
	end
	if self:GetCaster():HasModifier("modifier_dawnbreaker_luminosity_lua_charge") then
		self:GetCaster():RemoveModifierByName("modifier_dawnbreaker_luminosity_lua_charge")
	end

	return true
end


-----------
---- active charge
----------


modifier_dawnbreaker_luminosity_lua_charge = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_dawnbreaker_luminosity_lua_charge:IsHidden()
	return true
end

function modifier_dawnbreaker_luminosity_lua_charge:IsDebuff()
	return false
end

function modifier_dawnbreaker_luminosity_lua_charge:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_dawnbreaker_luminosity_lua_charge:OnCreated( kv )	
	if not IsServer() then return end
	self:GetParent():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)
	self:StartIntervalThink(0.03)
	self.projectile = tonumber(kv.projID)
	self.target = kv.target	

	self:GetParent():AddNewModifier( self:GetParent(), self, "modifier_dawnbreaker_celestial_hammer_lua_attach_trail", {} )
	self:GetParent():AddNoDraw()
end

function modifier_dawnbreaker_luminosity_lua_charge:OnIntervalThink()
	if not IsServer() then return end
	if self.projectile then
		local location = ProjectileManager:GetTrackingProjectileLocation( self.projectile )
		if location then			
			self:GetParent():SetAbsOrigin(location)				
		end
	end
end

function modifier_dawnbreaker_luminosity_lua_charge:CheckState()
	local state =
	{		
		[ MODIFIER_STATE_INVULNERABLE ] = true,
		[ MODIFIER_STATE_STUNNED ] = true,
		[ MODIFIER_STATE_OUT_OF_GAME ] = true,
		[ MODIFIER_STATE_UNTARGETABLE ] = true,
		
	}
	return state
end


function modifier_dawnbreaker_luminosity_lua_charge:OnDestroy()
	if not IsServer() then return end
	self:GetParent():FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_2)
	self:GetParent():RemoveModifierByName("modifier_dawnbreaker_celestial_hammer_lua_attach_trail")
	self:GetParent():RemoveNoDraw()
end

--------------------------------------------------------------------------------
----------
------------
------------------------ LUX IMMORTALIS
--------------------------------

modifier_dawnbreaker_luminosity_lua_stacking				= class({
	IsHidden				= function(self) return false end,
	IsPurgable	  			= function(self) return true end,
	IsDebuff	  			= function(self) return false end,	
	RemoveOnDeath			= function(self) return true end,	
	DestroyOnExpire			= function(self) return false end,	
})

function modifier_dawnbreaker_luminosity_lua_stacking:OnCreated()
	self.ability = self:GetCaster():FindAbilityByName("dawnbreaker_luminosity_lua_stacking")
	if not self.ability then
		self:Destroy()
	end
	self:StartIntervalThink(self:GetDuration())
end

function modifier_dawnbreaker_luminosity_lua_stacking:OnIntervalThink()
	if self:GetStackCount() > 0 then
		self:DecrementStackCount()
		self:DecrementStackCount()
		self:DecrementStackCount()
		self:DecrementStackCount()			
		self:DecrementStackCount()			
		self:ForceRefresh()
	else
		self:Destroy()
	end
end

function modifier_dawnbreaker_luminosity_lua_stacking:OnRefresh(table)
	self:StartIntervalThink(self:GetDuration())
end

function modifier_dawnbreaker_luminosity_lua_stacking:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_SCALE,		
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_STATUS_RESISTANCE, 
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,		
	}
end

function modifier_dawnbreaker_luminosity_lua_stacking:GetModifierAttackRangeBonus() 
	if not self:GetParent():PassivesDisabled() then
		return 4 * self:GetStackCount()
	end
	return 0
end

function modifier_dawnbreaker_luminosity_lua_stacking:GetModifierIncomingDamage_Percentage()
	if not self:GetParent():PassivesDisabled() then
		return -1 * self.ability:GetLevelSpecialValueFor("damage_reduction",1) * self:GetStackCount()
	end
	return 0
end

function modifier_dawnbreaker_luminosity_lua_stacking:GetModifierConstantHealthRegen() 
	if not self:GetParent():PassivesDisabled() then		
		return self.ability:GetLevelSpecialValueFor("health_regen",1) * self:GetStackCount()
	end
	return 0
end

function modifier_dawnbreaker_luminosity_lua_stacking:GetModifierStatusResistance() 
	if not self:GetParent():PassivesDisabled() then
		return self.ability:GetLevelSpecialValueFor("status_resist",1) * self:GetStackCount()
	end
	return 0
end

function modifier_dawnbreaker_luminosity_lua_stacking:GetModifierModelScale() 
	if not self:GetParent():PassivesDisabled() then
		return 2 * self:GetStackCount()
	end
	return 1
end

function modifier_dawnbreaker_luminosity_lua_stacking:GetModifierBaseAttack_BonusDamage()
	return self.ability:GetLevelSpecialValueFor("attack_damage",1) * self:GetStackCount()
end


--------------------------------------------------------------------------------
----------
------------
------------------------ EXPLOSION
--------------------------------

modifier_dawnbreaker_luminosity_lua_explosion		= class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return true end,	
	RemoveOnDeath			= function(self) return true end,	
})

function modifier_dawnbreaker_luminosity_lua_explosion:OnCreated()
	self.ability = self:GetCaster():FindAbilityByName("dawnbreaker_luminosity_lua_explosion")
	if not self.ability then
		self:Destroy()
	end	

	if not IsServer() then return end

	local stun_duration = self.ability:GetLevelSpecialValueFor("stun_duration",1)
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = stun_duration * (1 - self:GetParent():GetStatusResistance())})

	local particle_cast = "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_radiant_bind_debuff.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, Vector(5,5,5) )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		true, -- bHeroEffect
		false -- bOverheadEffect
	)
end


function modifier_dawnbreaker_luminosity_lua_explosion:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH,				
	}
end


function modifier_dawnbreaker_luminosity_lua_explosion:OnDeath(params)
	if params.unit == self:GetParent() then
		local sound = "Hero_Huskar.Inner_Fire.Cast"
		EmitSoundOn( sound, self:GetParent() )
		local radius = self.ability:GetLevelSpecialValueFor("aoe",1)		
		local health_percent = self.ability:GetLevelSpecialValueFor("health_pct",1)
		local heal_dmg = self:GetParent():GetMaxHealth() / 100 * health_percent
		local units = FindUnitsInRadius(
				self:GetCaster():GetTeamNumber(),	-- int, your team number
				self:GetParent():GetAbsOrigin(),	-- point, center point
				nil,	-- handle, cacheUnit. (not known)
				radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
				DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
				0,	-- int, flag filter
				0,	-- int, order filter
				false	-- bool, can grow cache
			)
		local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_huskar/huskar_inner_fire.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
		ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
		ParticleManager:ReleaseParticleIndex(effect_cast)
		for _,unit in pairs(units) do
			local damageInfo = 
			{
				victim = unit,
				attacker = self:GetCaster(),
				damage = heal_dmg,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self,
			}
			if unit:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
				ApplyDamage( damageInfo )				

				local knockback =
				{
					knockback_duration = 0.35,
					duration = 0.35,
					knockback_distance = radius / 2.5,
					knockback_height = 30,
					center_x = self:GetParent():GetAbsOrigin().x,
					center_y = self:GetParent():GetAbsOrigin().y,
					center_z = self:GetParent():GetAbsOrigin().z,
				}
				unit:RemoveModifierByName("modifier_knockback")
				unit:AddNewModifier(self:GetCaster(), self, "modifier_knockback", knockback)				
			else
				unit:Heal(heal_dmg, self:GetAbility())
			end
		end
	end
end
