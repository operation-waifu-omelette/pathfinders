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
modifier_jakiro_macropyre_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_jakiro_macropyre_lua:IsHidden()
	return false
end

function modifier_jakiro_macropyre_lua:IsDebuff()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return false
	else
		return true
	end
end

function modifier_jakiro_macropyre_lua:IsStunDebuff()
	return false
end

function modifier_jakiro_macropyre_lua:IsPurgable()
	return false
end

function modifier_jakiro_macropyre_lua:DeclareFunctions()
	local funcs = {		
		MODIFIER_EVENT_ON_DEATH,
	}

	return funcs
end

function modifier_jakiro_macropyre_lua:OnDeath( kv )
	if kv.unit ~= self:GetParent() then return end
	local macropyre = self:GetCaster():FindAbilityByName("jakiro_macropyre_lua")
	if self:GetCaster():HasAbility("pathfinder_jakiro_macropyre_cooldown_reduction") and not macropyre:IsCooldownReady() then
		local full_cooldown = macropyre:GetCooldown(self:GetAbility():GetLevel())
		local reduce_amount = full_cooldown / 100 * self:GetCaster():FindAbilityByName("pathfinder_jakiro_macropyre_cooldown_reduction"):GetLevelSpecialValueFor("cd_percent",1)
		local current_cooldown = macropyre:GetCooldownTimeRemaining()
		local new_cooldown = current_cooldown - reduce_amount
		macropyre:EndCooldown()
		macropyre:StartCooldown(math.max(new_cooldown,0))
	end
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_jakiro_macropyre_lua:OnCreated( kv )
	if not IsServer() then return end
	local interval = kv.interval
	local damage = kv.damage
	local damage_type = kv.damage_type

	-- precache damage
	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = damage_type,
		ability = self:GetAbility(), --Optional.
	}
	-- ApplyDamage(damageTable)

	-- Start interval
	self:StartIntervalThink( interval )
end

function modifier_jakiro_macropyre_lua:OnRefresh( kv )
	if not IsServer() then return end
	local damage = kv.damage
	local damage_type = kv.damage_type

	-- update damage
	self.damageTable.damage = damage
	self.damageTable.damage_type = damage_type
end

function modifier_jakiro_macropyre_lua:OnRemoved()
end

function modifier_jakiro_macropyre_lua:OnDestroy()

end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_jakiro_macropyre_lua:OnIntervalThink()
	-- apply damage
	if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
		ApplyDamage( self.damageTable )
	elseif self:GetParent():IsHero() then
		if self:GetCaster():HasAbility("pathfinder_jakiro_macropyre_heal") then
			
			local heal_amount = self.damageTable.damage / 100 * self:GetCaster():FindAbilityByName("pathfinder_jakiro_macropyre_heal"):GetLevelSpecialValueFor("heal_percent", 1)
			self:GetParent():Heal(heal_amount, self:GetAbility())
			self.healfx = ParticleManager:CreateParticle( "particles/econ/items/undying/fall20_undying_head/fall20_undying_soul_rip_heal_body.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			ParticleManager:SetParticleControl(self.healfx, 0, self:GetParent():GetAbsOrigin())		
			ParticleManager:ReleaseParticleIndex( self.healfx )				
		end
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_jakiro_macropyre_lua:GetEffectName()
	return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
end

function modifier_jakiro_macropyre_lua:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end