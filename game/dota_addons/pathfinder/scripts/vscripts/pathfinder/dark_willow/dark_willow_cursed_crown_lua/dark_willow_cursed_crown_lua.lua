-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
dark_willow_cursed_crown_lua = class({})
LinkLuaModifier( "modifier_generic_stunned_lua", "pathfinder/generic/modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dark_willow_cursed_crown_lua", "pathfinder/dark_willow/dark_willow_cursed_crown_lua/modifier_dark_willow_cursed_crown_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dark_willow_bramble_maze_lua", "pathfinder/dark_willow/modifier_dark_willow_bramble_maze_lua/modifier_dark_willow_bramble_maze_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function dark_willow_cursed_crown_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- cancel if linken
	if target:TriggerSpellAbsorb( self ) then return end

	-- load data
	local duration = self:GetSpecialValueFor( "delay" )

	-- add debuff
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_dark_willow_cursed_crown_lua", -- modifier name
		{ duration = duration } -- kv
	)
end