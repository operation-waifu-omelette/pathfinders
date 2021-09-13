LinkLuaModifier( "dark_willow_terror_shot_lua", "pathfinder/dark_willow/dark_willow_misc_lua/dark_willow_terror_shot_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_dark_willow_terror_shot_lua", "pathfinder/dark_willow/dark_willow_misc_lua/modifier_dark_willow_terror_shot_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_dark_willow_terrorize_lua_skeleton", "pathfinder/dark_willow/dark_willow_terrorize_lua/modifier_dark_willow_terrorize_lua_skeleton", LUA_MODIFIER_MOTION_NONE )


dark_willow_terror_shot_lua = class({})

function dark_willow_terror_shot_lua:GetIntrinsicModifierName()
	return "modifier_dark_willow_terror_shot_lua"
end