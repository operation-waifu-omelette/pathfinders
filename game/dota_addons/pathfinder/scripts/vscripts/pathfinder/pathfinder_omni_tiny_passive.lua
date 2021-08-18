
--------------------------------------------------------------------------------
pathfinder_omni_tiny_passive = class({})
LinkLuaModifier( "modifier_omni_tiny_passive", "pathfinder/modifier_omni_tiny_passive", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function pathfinder_omni_tiny_passive:GetIntrinsicModifierName()
	return "modifier_omni_tiny_passive"
end