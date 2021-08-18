modifier_pathfinder_special_venomancer_ward_corpse_debuff = class({})

function modifier_pathfinder_special_venomancer_ward_corpse_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

function modifier_pathfinder_special_venomancer_ward_corpse_debuff:IsHidden()
	return true
end


function modifier_pathfinder_special_venomancer_ward_corpse_debuff:OnDeath(params)
	--local caster = self:GetAbility():GetCaster()
	local caster = params.attacker
	if caster ~= self:GetAbility():GetCaster() then
		return nil
	end	
	local target = self:GetParent()	

	local corpse_ability = caster:FindAbilityByName("pathfinder_special_venomancer_ward_corpse")
	if not corpse_ability then
		return nil
	end
		

	local radius = corpse_ability:GetSpecialValueFor("radius")
	local spawn_chance = corpse_ability:GetSpecialValueFor("spawn_chance")

	if caster:IsHero() and CalcDistanceBetweenEntityOBB(caster, target) < radius then
		if RandomInt(0, 100) < spawn_chance then
			local kv = {caster = caster,
						target = target,
						ability = caster:FindAbilityByName("venomancer_plague_ward_datadriven"),
						target_points = {target:GetAbsOrigin(),},
						Duration = caster:FindAbilityByName("venomancer_plague_ward_datadriven"):GetLevelSpecialValueFor("duration", caster:FindAbilityByName("venomancer_plague_ward_datadriven"):GetLevel()-1),}
			venomancer_plague_ward_datadriven_on_spell_start(kv)
		end		
	end
end