pathfinder_healing_ward_burning_aura = class({})
LinkLuaModifier( "modifier_burning_aura", "pathfinder/modifier_burning_aura", LUA_MODIFIER_MOTION_NONE )

------------------------------------------------------------- Passive Modifier
function pathfinder_healing_ward_burning_aura:GetIntrinsicModifierName()
	return "modifier_burning_aura"
end


	