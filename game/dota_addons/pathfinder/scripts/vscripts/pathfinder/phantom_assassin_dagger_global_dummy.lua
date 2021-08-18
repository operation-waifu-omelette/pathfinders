phantom_assassin_dagger_global_dummy = class({})
LinkLuaModifier( "modifier_phantom_assassin_dagger_global_dummy", "pathfinder/phantom_assassin_dagger_global_dummy", LUA_MODIFIER_MOTION_NONE )


------------------------------------------------------------- Passive Modifier
function phantom_assassin_dagger_global_dummy:GetIntrinsicModifierName()
	return "modifier_phantom_assassin_dagger_global_dummy"
end

modifier_phantom_assassin_dagger_global_dummy = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_phantom_assassin_dagger_global_dummy:IsHidden()
	return true
end

function modifier_phantom_assassin_dagger_global_dummy:IsDebuff()
	return false
end

function modifier_phantom_assassin_dagger_global_dummy:IsPurgable()
	return false
end

function modifier_phantom_assassin_dagger_global_dummy:DestroyOnExpire()
	return false
end

function modifier_phantom_assassin_dagger_global_dummy:DeclareFunctions() 
  local funcs = {
    MODIFIER_PROPERTY_ABILITY_LAYOUT,
  }
 
  return funcs
end

function modifier_phantom_assassin_dagger_global_dummy:GetModifierAbilityLayout() 
  return 6
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_phantom_assassin_dagger_global_dummy:OnCreated( kv )
		local caster = self:GetAbility():GetCaster()	
		if IsServer() then			
			caster:AddAbility("phantom_assassin_dagger_global"):SetLevel(1)
			caster:SwapAbilities("phantom_assassin_dagger_global", "phantom_assassin_coup_de_grace_lua", true, true)
		end				
end

