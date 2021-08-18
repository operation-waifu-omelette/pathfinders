
--------------------------------------------------------------------------------
pathfinder_trap_catapult_passive = class({})
LinkLuaModifier( "modifier_pathfinder_trap_catapult_passive", "pathfinder/modifier_pathfinder_trap_catapult_passive", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function pathfinder_trap_catapult_passive:GetIntrinsicModifierName()
	return "modifier_pathfinder_trap_catapult_passive"
end