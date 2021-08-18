modifier_pathfinder_special_snapfire_gobble = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_special_snapfire_gobble:IsHidden()
	return true
end

function modifier_pathfinder_special_snapfire_gobble:IsDebuff()
	return false
end

function modifier_pathfinder_special_snapfire_gobble:IsPurgable()
	return false
end

function modifier_pathfinder_special_snapfire_gobble:DestroyOnExpire()
	return false
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_pathfinder_special_snapfire_gobble:OnCreated( kv )
		local caster = self:GetAbility():GetCaster()	
		if IsServer() then			
			caster:AddAbility("aghsfort_snapfire_gobble_up"):SetLevel(1)
			--caster:AddAbility("aghsfort_snapfire_spit_creep"):SetLevel(1)			
		end				
end

function modifier_pathfinder_special_snapfire_gobble:DeclareFunctions() 
  local funcs = {
    MODIFIER_PROPERTY_ABILITY_LAYOUT,
  }
 
  return funcs
end

function modifier_pathfinder_special_snapfire_gobble:GetModifierAbilityLayout() 
  return 6
end

