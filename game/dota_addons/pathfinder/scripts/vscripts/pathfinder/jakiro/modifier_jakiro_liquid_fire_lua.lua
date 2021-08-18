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
modifier_jakiro_liquid_fire_lua = class({})
require("libraries.has_shard")
require("libraries.timers")

--------------------------------------------------------------------------------
-- Classifications
function modifier_jakiro_liquid_fire_lua:IsHidden()
	return false
end

function modifier_jakiro_liquid_fire_lua:IsDebuff()
	return true
end

function modifier_jakiro_liquid_fire_lua:IsStunDebuff()
	return false
end

function modifier_jakiro_liquid_fire_lua:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_jakiro_liquid_fire_lua:OnCreated( kv )
	-- references
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.slow = self:GetAbility():GetSpecialValueFor( "slow_attack_speed_pct" )

	if not IsServer() then return end

	-- precache damage
	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(), --Optional.
	}
	-- ApplyDamage(damageTable)

	self:DealBurstDamage()

	self:StartIntervalThink( 0.5 )
end

function modifier_jakiro_liquid_fire_lua:DealBurstDamage()
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )
	if self:GetCaster():HasAbility("pathfinder_jakiro_liquid_fire_burst") then
		local total_damage = (self:GetDuration() / 0.5) * damage / 2
		local burst_damage = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = total_damage,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(), --Optional.
		}

		if self:GetCaster():HasModifier("pathfinder_jakiro_liquid_fire_allies_checker") and self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then		
			local heal = total_damage * 1.5
			self:GetParent():Heal(heal, self:GetAbility())			
		else
			ApplyDamage( burst_damage )
		end	
	end
end

function modifier_jakiro_liquid_fire_lua:OnRefresh( kv )
	-- references
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.slow = self:GetAbility():GetSpecialValueFor( "slow_attack_speed_pct" )

	if not IsServer() then return end

	self:DealBurstDamage()

	-- update damage
	self.damageTable.damage = damage	
end

function modifier_jakiro_liquid_fire_lua:OnRemoved()
end

function modifier_jakiro_liquid_fire_lua:OnDestroy()

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_jakiro_liquid_fire_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_DEATH,
	}

	return funcs
end

function modifier_jakiro_liquid_fire_lua:GetModifierAttackSpeedBonus_Constant()
	-- if self:GetCaster():HasModifier("pathfinder_jakiro_liquid_fire_allies_checker") and self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then		
	-- 	return self.slow 
	-- end
	if not self:GetParent():IsMagicImmune() then
		return self.slow * -1
	end
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_jakiro_liquid_fire_lua:OnIntervalThink()
	if self:GetCaster():HasModifier("pathfinder_jakiro_liquid_fire_allies_checker") and self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then		
		local heal = self:GetAbility():GetSpecialValueFor( "damage" ) * 1.5
		self:GetParent():Heal(heal, self:GetAbility())	
		self.healfx = ParticleManager:CreateParticle( "particles/econ/items/undying/fall20_undying_head/fall20_undying_soul_rip_heal_body.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl(self.healfx, 0, self:GetParent():GetAbsOrigin())		
		ParticleManager:ReleaseParticleIndex( self.healfx )		
	else
		if self:GetParent():IsBuilding() or (not self:GetParent():IsMagicImmune() and not self:GetParent():IsBuilding()) then
			ApplyDamage( self.damageTable )
		end
	end	
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_jakiro_liquid_fire_lua:GetEffectName()
	return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
end

function modifier_jakiro_liquid_fire_lua:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_jakiro_liquid_fire_lua:OnDeath(params)
	if params.unit ~= self:GetParent() then return end
	if IsServer() then
		if self:GetCaster():HasAbility("pathfinder_jakiro_liquid_fire_macropyre") and self:GetCaster():FindAbilityByName("jakiro_macropyre_lua"):GetLevel() > 0 then
			local chance = self:GetCaster():FindAbilityByName("pathfinder_jakiro_liquid_fire_macropyre"):GetLevelSpecialValueFor("chance",1)
			if RollPseudoRandomPercentage(chance,DOTA_PSEUDO_RANDOM_CUSTOM_GAME_6, self:GetCaster()) then
				local macropyre = self:GetCaster():FindAbilityByName("jakiro_macropyre_lua")
				local radius =macropyre:GetLevelSpecialValueFor("path_radius", macropyre:GetLevel() - 1)
				local duration =macropyre:GetLevelSpecialValueFor("duration", macropyre:GetLevel() - 1) /2

				local start = params.unit:GetAbsOrigin() + params.unit:GetForwardVector() * (radius / 4)
				local stop = params.unit:GetAbsOrigin() + params.unit:GetForwardVector() * -1 * (radius / 4)

				macropyre:MakeMacropyreAt(start,stop, duration)
			end
			
		end
	end
end

function modifier_jakiro_liquid_fire_lua:Splinter()
	if not IsServer() or not self:GetCaster():HasAbility("pathfinder_jakiro_liquid_fire_splinter") then return end
	local search_radius = self:GetCaster():FindAbilityByName("pathfinder_jakiro_liquid_fire_splinter"):GetLevelSpecialValueFor("radius", 1)
	local targets_num = self:GetCaster():FindAbilityByName("pathfinder_jakiro_liquid_fire_splinter"):GetLevelSpecialValueFor("targets", 1)
	local min_range = self:GetCaster():FindAbilityByName("pathfinder_jakiro_liquid_fire_splinter"):GetLevelSpecialValueFor("min_range", 1)
	local targets = FindRadius(self:GetParent(), search_radius, false)

	local target_count = 0
	for _,enemy in pairs(targets) do
		if not enemy or target_count > targets_num then break end			
		
		if (enemy:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D() > min_range then
			local info = 
			{
				Target = enemy,
				Source = self:GetParent(),
				Ability = self:GetAbility(),
				iMoveSpeed = self:GetCaster():GetProjectileSpeed() / 2,
				vSourceLoc = self:GetParent():GetOrigin(),
				EffectName = "particles/units/heroes/hero_jakiro/jakiro_base_attack_fire.vpcf",
				extraData = {},
			}
			ProjectileManager:CreateTrackingProjectile( info )
			target_count = target_count + 1
			EmitSoundOn( "n_mud_golem.Boulder.Cast", self:GetParent() )		
		end
	end

end



