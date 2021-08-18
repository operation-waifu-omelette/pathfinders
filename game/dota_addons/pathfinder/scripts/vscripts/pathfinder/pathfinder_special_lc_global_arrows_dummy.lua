pathfinder_special_lc_global_arrows_dummy = class({})
LinkLuaModifier("modifier_pathfinder_special_lc_global_arrows_dummy", "pathfinder/pathfinder_special_lc_global_arrows_dummy", LUA_MODIFIER_MOTION_NONE)
function pathfinder_special_lc_global_arrows_dummy:GetIntrinsicModifierName()
	return "modifier_pathfinder_special_lc_global_arrows_dummy"
end
--------------------------------------------------------------------------------
modifier_pathfinder_special_lc_global_arrows_dummy = class({})
-- Classifications
function modifier_pathfinder_special_lc_global_arrows_dummy:IsHidden()
	return true
end

function modifier_pathfinder_special_lc_global_arrows_dummy:IsDebuff()
	return false
end

function modifier_pathfinder_special_lc_global_arrows_dummy:IsPurgable()
	return false
end

function modifier_pathfinder_special_lc_global_arrows_dummy:DestroyOnExpire()
	return false
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_pathfinder_special_lc_global_arrows_dummy:OnCreated( kv )
		local caster = self:GetAbility():GetCaster()	
		if IsServer() then			
			caster:AddAbility("pathfinder_special_lc_global_arrows"):SetLevel(1)
			caster:SwapAbilities("pathfinder_special_lc_global_arrows", "pathfinder_lc_moment", true, true)
		end				
end

function modifier_pathfinder_special_lc_global_arrows_dummy:DeclareFunctions() 
  local funcs = {
    MODIFIER_PROPERTY_ABILITY_LAYOUT,
  }
 
  return funcs
end

function modifier_pathfinder_special_lc_global_arrows_dummy:GetModifierAbilityLayout() 
  return 6
end



