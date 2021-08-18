
modifier_pathfinder_special_venomancer_gale_attack = class({})
require("pathfinder.venomous_gale")

function modifier_pathfinder_special_venomancer_gale_attack:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_pathfinder_special_venomancer_gale_attack:IsHidden()
	return true
end


function modifier_pathfinder_special_venomancer_gale_attack:OnAttackLanded(params)
	local gale_ability = self:GetAbility():GetCaster():FindAbilityByName("venomancer_venomous_gale_datadriven")
	if params.attacker == self:GetAbility():GetCaster() then
		if gale_ability:GetLevel() < 1 then
			return
		end
		
		if IsServer() and self:GetAbility():GetCaster() == self:GetParent() then
			if RandomInt(0,100) < self:GetAbility():GetSpecialValueFor("proc_chance") then
				local cast_point = params.attacker:GetOrigin() + ((params.target:GetOrigin() - params.attacker:GetOrigin()):Normalized() * 40)
							
				params.attacker:SetCursorPosition(params.target:GetAbsOrigin())
				params.attacker:FindAbilityByName("venomancer_venomous_gale_datadriven"):OnAbilityPhaseStart()
				params.attacker:EmitSoundParams("Hero_Venomancer.VenomousGale", 0, 0.6, 0)

				for i = 1, self:GetAbility():GetSpecialValueFor("extra_gales") do
					
					local new_point = RotatePosition(params.attacker:GetAbsOrigin(),QAngle(0,i * self:GetAbility():GetSpecialValueFor("angle"),0),cast_point)				
					params.attacker:SetCursorPosition(new_point)
					params.attacker:FindAbilityByName("venomancer_venomous_gale_datadriven"):OnSpellStart()					
					
					local new_point = RotatePosition(params.attacker:GetAbsOrigin(),QAngle(0,i * -1 * self:GetAbility():GetSpecialValueFor("angle"),0),cast_point)				
					params.attacker:SetCursorPosition(new_point)
					params.attacker:FindAbilityByName("venomancer_venomous_gale_datadriven"):OnSpellStart()						
				end				
			end
		end
	end
end