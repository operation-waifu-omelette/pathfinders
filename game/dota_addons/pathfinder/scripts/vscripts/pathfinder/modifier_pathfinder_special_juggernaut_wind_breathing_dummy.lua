modifier_pathfinder_special_juggernaut_wind_breathing_dummy = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_special_juggernaut_wind_breathing_dummy:IsHidden()
	return true
end

function modifier_pathfinder_special_juggernaut_wind_breathing_dummy:IsDebuff()
	return false
end

function modifier_pathfinder_special_juggernaut_wind_breathing_dummy:IsPurgable()
	return false
end

function modifier_pathfinder_special_juggernaut_wind_breathing_dummy:DestroyOnExpire()
	return false
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_pathfinder_special_juggernaut_wind_breathing_dummy:OnCreated( kv )
		local caster = self:GetAbility():GetCaster()	
		if IsServer() then			
			caster:AddAbility("pathfinder_juggernaut_wind_breathing"):SetLevel(1)
			caster:SwapAbilities("pathfinder_juggernaut_wind_breathing", "pathfinder_juggernaut_blade_dance", true, true)
		end				
end

function modifier_pathfinder_special_juggernaut_wind_breathing_dummy:DeclareFunctions() 
  local funcs = {
    MODIFIER_PROPERTY_ABILITY_LAYOUT,
  }
 
  return funcs
end

function modifier_pathfinder_special_juggernaut_wind_breathing_dummy:GetModifierAbilityLayout() 
  return 6
end

