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
modifier_burning_aura = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_burning_aura:IsHidden()
	return false
end

function modifier_burning_aura:IsDebuff()
	return false
end

function modifier_burning_aura:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_burning_aura:OnCreated( kv )
	-- references	
	local burn_ability = self:GetAbility()	
	if not IsServer() then return end
	self.radius = self:GetAbility():GetCaster():GetOwner():FindAbilityByName("pathfinder_juggernaut_summon_healing_ward"):GetSpecialValueFor( "radius" )	
	
	local interval = 1	
	
	-- precache damage
	self.damageTable = {
		-- victim = target,
		attacker = self:GetCaster(),
		damage = burn_ability:GetCaster():GetAverageTrueAttackDamage(nil),
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(), --Optional.
	}

	-- Start interval
	self:StartIntervalThink( interval )

	-- Play effects
	self:PlayEffects1()
end

function modifier_burning_aura:OnRefresh( kv )
	-- references
	local burn_ability = self:GetAbility()	
	local damage = burn_ability:GetCaster():GetAverageTrueAttackDamage(nil)

	if not IsServer() then return end
	self.damageTable.damage = damage
end

function modifier_burning_aura:OnRemoved()
end

function modifier_burning_aura:OnDestroy()
end

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Interval Effects
function modifier_burning_aura:OnIntervalThink()
	-- find enemies
	local enemies = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		if enemy:GetUnitName() ~= "npc_dota_creature_bonus_greevil" then
			-- apply damage
			self.damageTable.victim = enemy

			ApplyDamage( self.damageTable )

			-- play effects
			self:PlayEffects2( enemy )
		end
	end
end

--------------------------------------------------------------------------------
-- Aura Effects
function modifier_burning_aura:IsAura()
	return false
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_burning_aura:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_bringer_scorched_earth_buff.vpcf"
end

function modifier_burning_aura:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_burning_aura:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_doom_bringer/doom_scorched_earth.vpcf"
	local sound_cast = "Hero_DoomBringer.ScorchedEarthAura"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )

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

function modifier_burning_aura:PlayEffects2( target )
	-- Get Resources
	local particle_cast = "particles/base_attacks/ranged_tower_bad_explosion_c.vpcf"	

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt( effect_cast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true )
	ParticleManager:ReleaseParticleIndex( effect_cast )	
end