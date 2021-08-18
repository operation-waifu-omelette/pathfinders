pathfinder_healing_ward_passive = class({})
LinkLuaModifier( "modifier_pathfinder_healing_ward_passive", "pathfinder/modifier_pathfinder_healing_ward_passive", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pathfinder_healing_ward_effect", "pathfinder/modifier_pathfinder_healing_ward_effect", LUA_MODIFIER_MOTION_NONE )

------------------------------------------------------------- Passive Modifier
function pathfinder_healing_ward_passive:GetIntrinsicModifierName()
	return "modifier_pathfinder_healing_ward_passive"
end