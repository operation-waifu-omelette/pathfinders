
modifier_pathfinder_special_windragner_aoe_focusfire = class({})

function modifier_pathfinder_special_windragner_aoe_focusfire:DeclareFunctions()
	local funcs = {		
		MODIFIER_EVENT_ON_ATTACK,
	}
	return funcs
end

function modifier_pathfinder_special_windragner_aoe_focusfire:IsHidden()
	return false
end

function modifier_pathfinder_special_windragner_aoe_focusfire:OnAttack(keys)
	
	if keys.attacker == self:GetParent() and self:GetAbility():GetCaster():HasAbility("pathfinder_special_windragner_aoe_focusfire") then
		print("yep")
		-- Look for a target in the attack range of the ward
		local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
			self:GetParent():GetAbsOrigin(),
			nil,
			self:GetParent():Script_GetAttackRange(),
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE,
			FIND_ANY_ORDER,
			false)
			
		local targets_aimed = 0
		
		-- Send a attack projectile to the chosen enemies
		for i = 1, #enemies do
			if enemies[i] ~= keys.target then
				-- "Unlike most other instant attacks, the ones from the Serpent Wards do not proc any on-hit effects."
				self:GetParent():PerformAttack(enemies[i], true, true, true, true, true, false, false)
				
				targets_aimed	= targets_aimed + 1
				
				if targets_aimed >= self:GetAbility():GetCaster():FindAbilityByName("pathfinder_special_windragner_aoe_focusfire"):GetSpecialValueFor("additional_shots") then
					break
				end
			end
		end
	end
end