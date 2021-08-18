
modifier_pathfinder_special_venomancer_ward_corpse = class({})
LinkLuaModifier( "modifier_pathfinder_special_venomancer_ward_corpse_debuff", "pathfinder/modifier_pathfinder_special_venomancer_ward_corpse_debuff", LUA_MODIFIER_MOTION_NONE )

require("pathfinder.plague_ward")

function modifier_pathfinder_special_venomancer_ward_corpse:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK,
	}
	return funcs
end

function modifier_pathfinder_special_venomancer_ward_corpse:IsHidden()
	return true
end


function modifier_pathfinder_special_venomancer_ward_corpse:OnAttackLanded(params)
	if params.attacker == self:GetAbility():GetCaster() then
		if self:GetAbility():GetCaster():FindAbilityByName("venomancer_poison_sting_datadriven"):GetLevel() < 1 then
			return
		end
		
		local debuff_duration = self:GetAbility():GetCaster():FindAbilityByName("venomancer_poison_sting_datadriven"):GetLevelSpecialValueFor("duration", self:GetAbility():GetCaster():FindAbilityByName("venomancer_poison_sting_datadriven"):GetLevel()-1)
		if IsServer() and self:GetAbility():GetCaster() == self:GetParent() then
			params.target:AddNewModifier(params.target, self:GetAbility(), "modifier_pathfinder_special_venomancer_ward_corpse_debuff", {duration = debuff_duration})
		end
	end
end

function modifier_pathfinder_special_venomancer_ward_corpse:OnAttack(keys)
	
	if keys.attacker == self:GetParent() and not keys.no_attack_cooldown and self:GetCaster() and not self:GetCaster():IsNull() and HasShard(self:GetAbility():GetCaster(), "pathfinder_special_venomancer_ward_corpse") then
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
				
				if targets_aimed >= self:GetAbility():GetCaster():FindAbilityByName("pathfinder_special_venomancer_ward_corpse"):GetSpecialValueFor("additional_shots") then
					break
				end
			end
		end
	end
end