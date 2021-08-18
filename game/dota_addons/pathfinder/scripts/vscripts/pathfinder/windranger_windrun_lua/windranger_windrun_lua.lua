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
windranger_windrun_lua = class({})
LinkLuaModifier( "modifier_windranger_windrun_lua", "pathfinder/windranger_windrun_lua/modifier_windranger_windrun_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_windranger_windrun_lua_invis", "pathfinder/windranger_windrun_lua/modifier_windranger_windrun_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_windranger_windrun_lua_debuff", "pathfinder/windranger_windrun_lua/modifier_windranger_windrun_lua_debuff", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function windranger_windrun_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local duration = self:GetSpecialValueFor( "duration" )

	-- add modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_windranger_windrun_lua", -- modifier name
		{ duration = duration } -- kv
	)

	if IsServer() and caster:HasAbility("pathfinder_special_windranger_windrun_aoe") then
		local radius = caster:FindAbilityByName("pathfinder_special_windranger_windrun_aoe"):GetSpecialValueFor("radius")
		local friendlies = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false )

		for _,ally in pairs(friendlies) do
			ally:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_windranger_windrun_lua", -- modifier name
			{ duration = duration } -- kv
			)
		end
	end

	if IsServer() and caster:HasAbility("pathfinder_special_windranger_windrun_invis") then		
		caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_windranger_windrun_lua_invis", -- modifier name
		{ duration = duration } -- kv
		)		
	end

	-- Play effects
	local sound_cast = "Ability.Windrun"
	EmitSoundOn( sound_cast, caster )
end