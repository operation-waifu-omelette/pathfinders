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
dark_willow_bramble_maze_lua = class({})

LinkLuaModifier( "modifier_generic_custom_indicator", "pathfinder/generic/modifier_generic_custom_indicator", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "dark_willow_bramble_maze_lua", "pathfinder/dark_willow/dark_willow_bramble_maze_lua/dark_willow_bramble_maze_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dark_willow_bramble_maze_lua_thinker", "pathfinder/dark_willow/dark_willow_bramble_maze_lua/modifier_dark_willow_bramble_maze_lua_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dark_willow_bramble_maze_lua_bramble", "pathfinder/dark_willow/dark_willow_bramble_maze_lua/modifier_dark_willow_bramble_maze_lua_bramble", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dark_willow_bramble_maze_lua_debuff", "pathfinder/dark_willow/dark_willow_bramble_maze_lua/modifier_dark_willow_bramble_maze_lua_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dark_willow_bramble_maze_lua_thinker_healing", "pathfinder/dark_willow/dark_willow_bramble_maze_lua/modifier_dark_willow_bramble_maze_lua_thinker_healing", LUA_MODIFIER_MOTION_NONE )


--------------------------------------------------------------------------------
-- init standard bramble locations
local locations = {}
local inner = Vector( 200, 0, 0 )
local outer = Vector( 500, 0, 0 )
outer = RotatePosition( Vector(0,0,0), QAngle( 0, 45, 0 ), outer )

-- real men use 0-based
for i=0,3 do
	locations[i] = RotatePosition( Vector(0,0,0), QAngle( 0, 90*i, 0 ), inner )
	locations[i+4] = RotatePosition( Vector(0,0,0), QAngle( 0, 90*i, 0 ), outer )
end

dark_willow_bramble_maze_lua.locations = locations

-- init alt bramble locations
local locations_thicket = {}

local ring1 = Vector( 200, 0, 0 )
local ring2 = Vector( 300, 0, 0 )
ring2 = RotatePosition( Vector(0,0,0), QAngle( 0, 45, 0 ), ring2 )
local ring3 = Vector( 400, 0, 0 )
local ring4 = Vector( 500, 0, 0 )
ring4 = RotatePosition( Vector(0,0,0), QAngle( 0, 45, 0 ), ring4 )

locations_thicket[0] = RotatePosition( Vector(0,0,0), QAngle( 0, 0, 0 ), Vector(0,0,0) )

for i=1,4 do
	locations_thicket[i] = RotatePosition( Vector(0,0,0), QAngle( 0, 90*i, 0 ), ring1 )
	locations_thicket[i+4] = RotatePosition( Vector(0,0,0), QAngle( 0, 90*i, 0 ), ring2 )
	locations_thicket[i+8] = RotatePosition( Vector(0,0,0), QAngle( 0, 90*i, 0 ), ring3 )
	locations_thicket[i+12] = RotatePosition( Vector(0,0,0), QAngle( 0, 90*i, 0 ), ring4 )
end



dark_willow_bramble_maze_lua.locations_thicket = locations_thicket

dark_willow_bramble_maze_lua.use_thicket = false

--------------------------------------------------------------------------------
-- Passive Modifier
function dark_willow_bramble_maze_lua:GetIntrinsicModifierName()
	return "modifier_generic_custom_indicator"
end

--------------------------------------------------------------------------------
-- Ability Cast Filter (For custom indicator)
function dark_willow_bramble_maze_lua:CastFilterResultLocation( vLoc )
	-- Custom indicator block start
	if IsClient() then
		-- check custom indicator
		if self.custom_indicator then
			-- register cursor position
			self.custom_indicator:Register( vLoc )
		end
	end
	-- Custom indicator block end

	return UF_SUCCESS
end

--------------------------------------------------------------------------------
-- Ability Custom Indicator
function dark_willow_bramble_maze_lua:CreateCustomIndicator()
	-- references
	local particle_cast = "particles/units/heroes/hero_dark_willow/dark_willow_bramble_range_finder_aoe.vpcf"

	-- get data
	local radius = self:GetSpecialValueFor( "placement_range" )

	-- create particle
	self.effect_indicator = ParticleManager:CreateParticle( particle_cast, PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl( self.effect_indicator, 1, Vector( radius, radius, radius ) )
end

function dark_willow_bramble_maze_lua:UpdateCustomIndicator( loc )
	
	-- update particle position
	ParticleManager:SetParticleControl( self.effect_indicator, 0, loc )
	
	for i=0,7 do
		ParticleManager:SetParticleControl( self.effect_indicator, 2 + i, loc + self.locations[i] )
	end
end

function dark_willow_bramble_maze_lua:DestroyCustomIndicator()
	-- destroy particle
	ParticleManager:DestroyParticle( self.effect_indicator, false )
	ParticleManager:ReleaseParticleIndex( self.effect_indicator )
end

--------------------------------------------------------------------------------
-- Ability Start
function dark_willow_bramble_maze_lua:OnSpellStart()
	-- unit identifier
	
	local point = self:GetCursorPosition()
	self:CastBrambles(point)	
end

function dark_willow_bramble_maze_lua:CastBrambles( loc )
	local caster = self:GetCaster()
	local quantity = 8

	if caster:HasAbility("dark_willow_bramble_maze_lua_thicket") then
		dark_willow_bramble_maze_lua.use_thicket = true
		dark_willow_bramble_maze_lua.locations = dark_willow_bramble_maze_lua.locations_thicket
		quantity = 17
	end

	if caster:HasAbility("dark_willow_bramble_maze_lua_healing") then
		healing = true
	end
	
	-- create thinker
	CreateModifierThinker(
		caster, -- player source
		self, -- ability source
		"modifier_dark_willow_bramble_maze_lua_thinker", -- modifier name
		{
			bq = quantity,
			healing = healing,
		}, -- kv
		loc,
		self:GetCaster():GetTeamNumber(),
		false
	)

	if healing then
		CreateModifierThinker(
			caster, -- player source
			self, -- ability source
			"modifier_dark_willow_bramble_maze_lua_thinker_healing", -- modifier name
			{
				bq = quantity,
				healing = false,
				location = loc,
			}, -- kv
			loc,
			self:GetCaster():GetTeamNumber(),
			false
		)
	end
end

function dark_willow_bramble_maze_lua:PlaceSingleBramble( loc )
	local caster = self:GetCaster()

	dur = self:GetCaster():FindAbilityByName("dark_willow_bramble_maze_lua"):GetSpecialValueFor( "duration" )
	roo = self:GetCaster():FindAbilityByName("dark_willow_bramble_maze_lua"):GetSpecialValueFor( "latch_duration" )
	rad = self:GetCaster():FindAbilityByName("dark_willow_bramble_maze_lua"):GetSpecialValueFor( "latch_radius" )
	dmg = self:GetCaster():FindAbilityByName("dark_willow_bramble_maze_lua"):GetSpecialValueFor( "latch_damage" )
	del = self:GetCaster():FindAbilityByName("dark_willow_bramble_maze_lua"):GetSpecialValueFor( "latch_delay" )

	-- create bramble
	CreateModifierThinker(
		caster, -- player source
		self, -- ability source
		"modifier_dark_willow_bramble_maze_lua_bramble", -- modifier name
		{
			duration = dur,
			root = roo,
			radius = rad,
			damage = dmg,
			delay = del,
		}, -- kv
		loc,
		self:GetCaster():GetTeamNumber(),
		false
	)
end