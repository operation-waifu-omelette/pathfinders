modifier_pathfinder_special_venomancer_bigass_ward_dummy = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_special_venomancer_bigass_ward_dummy:IsHidden()
	return true
end

function modifier_pathfinder_special_venomancer_bigass_ward_dummy:IsDebuff()
	return false
end

function modifier_pathfinder_special_venomancer_bigass_ward_dummy:IsPurgable()
	return false
end

function modifier_pathfinder_special_venomancer_bigass_ward_dummy:DestroyOnExpire()
	return false
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_pathfinder_special_venomancer_bigass_ward_dummy:OnCreated( kv )
		local caster = self:GetAbility():GetCaster()	
		if IsServer() then			
			caster:AddAbility("pathfinder_venomancer_bigass_ward"):SetLevel(1)
			caster:SwapAbilities("pathfinder_venomancer_bigass_ward", "venomancer_poison_sting_datadriven", true, true)
		end				
end

function modifier_pathfinder_special_venomancer_bigass_ward_dummy:DeclareFunctions() 
  local funcs = {
    MODIFIER_PROPERTY_ABILITY_LAYOUT,
  }
 
  return funcs
end

function modifier_pathfinder_special_venomancer_bigass_ward_dummy:GetModifierAbilityLayout() 
  return 6
end



