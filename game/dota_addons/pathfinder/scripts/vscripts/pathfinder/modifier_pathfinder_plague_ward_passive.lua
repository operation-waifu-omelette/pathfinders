  
modifier_pathfinder_plague_ward_passive = class({})



--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_plague_ward_passive:IsHidden()
	return true
end

function modifier_pathfinder_plague_ward_passive:IsDebuff()
	return false
end

function modifier_pathfinder_plague_ward_passive:IsPurgable()
	return false
end

function modifier_pathfinder_plague_ward_passive:OnCreated(table)	
	if IsServer() then			
		if self:GetAbility():GetCaster():HasAbility("pathfinder_special_venomancer_ward_global_attack") then
			self.dmg_penalty = self:GetAbility():GetCaster():FindAbilityByName("pathfinder_special_venomancer_ward_global_attack"):GetSpecialValueFor("dmg_penalty")
			self.isGlobalWard = true
			self:SetHasCustomTransmitterData( true )
		end
	end
end
function modifier_pathfinder_plague_ward_passive:AddCustomTransmitterData( )
	return
	{
		dmg_penalty = self.dmg_penalty,
		isGlobalWard = self.isGlobalWard,
	}
end

function modifier_pathfinder_plague_ward_passive:HandleCustomTransmitterData( data )
	self.dmg_penalty = data.dmg_penalty
	self.isGlobalWard = data.isGlobalWard
end
--------------------------------------------------------------------------------
require("libraries.has_shard")

function modifier_pathfinder_plague_ward_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE ,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}
	return funcs
end

function modifier_pathfinder_plague_ward_passive:GetModifierAttackRangeOverride( )	
	if self.isGlobalWard and self.isGlobalWard == true then		
		return 8000
	end
end

function modifier_pathfinder_plague_ward_passive:GetModifierAttackSpeedBonus_Constant( params )
	local attack_speed = self:GetAbility():GetLevelSpecialValueFor("attack_speed", self:GetAbility():GetLevel() - 1)
	return attack_speed
end

function modifier_pathfinder_plague_ward_passive:CheckState()
	local true_strike = false
	if HasShard(self:GetAbility():GetCaster(), "special_bonus_unique_venomancer_ward_true_strike") then
		true_strike = true
	end
    local state =
	{
		[ MODIFIER_STATE_MAGIC_IMMUNE ] = true,
		[ MODIFIER_STATE_NO_UNIT_COLLISION ] = true,
		[ MODIFIER_STATE_CANNOT_MISS ] = true_strike,
	}

	return state
end

function modifier_pathfinder_plague_ward_passive:OnAttack(keys)
	
	if keys.attacker == self:GetParent() and not keys.no_attack_cooldown and self:GetCaster() and not self:GetCaster():IsNull() and HasShard(self:GetAbility():GetCaster(), "special_bonus_unique_venomancer_ward_split_shot") then
		-- Look for a target in the attack range of the ward
		local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
			self:GetParent():GetAbsOrigin(),
			nil,
			self:GetParent():Script_GetAttackRange(),
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
			DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE,
			FIND_ANY_ORDER,
			false)
			
		local targets_aimed = 0
		
		-- Send a attack projectile to the chosen enemies
		for i = 1, #enemies do
			if enemies[i] ~= keys.target then
				-- "Unlike most other instant attacks, the ones from the Serpent Wards do not proc any on-hit effects."
				self:GetParent():PerformAttack(enemies[i], false, false, true, true, true, false, false)
				
				targets_aimed	= targets_aimed + 1
				
				if targets_aimed >= self:GetAbility():GetCaster():FindAbilityByName("special_bonus_unique_venomancer_ward_split_shot"):GetSpecialValueFor("additional_shots") then
					break
				end
			end
		end
	end
	if keys.attacker == self:GetParent() and not keys.no_attack_cooldown and keys.unit and self:GetCaster() and not self:GetCaster():IsNull() and self:GetCaster():FindAbilityByName("venomancer_poison_sting_datadriven"):GetLevel() < 1 then
		local damage = {
					victim = keys.unit,
					attacker = self:GetCaster(),
					damage = 1,
					damage_type = DAMAGE_TYPE_PHYSICAL,					
				}
		
		ApplyDamage( damage )
	end
end

function modifier_pathfinder_plague_ward_passive:GetModifierDamageOutgoing_Percentage( params )
	if params.target and (params.target:GetUnitName() == "npc_aghsfort_dark_portal" or params.target:GetUnitName() == "npc_aghsfort_dark_portal_v2") then
		return -80
	end	
	if self.isGlobalWard and self.dmg_penalty and self.isGlobalWard == true then				
		return self.dmg_penalty
	end
end


