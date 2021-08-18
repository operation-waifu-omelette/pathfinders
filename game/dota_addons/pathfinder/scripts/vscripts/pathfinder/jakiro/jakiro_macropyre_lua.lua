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
jakiro_macropyre_lua = class({})
LinkLuaModifier( "modifier_jakiro_macropyre_lua", "pathfinder/jakiro/modifier_jakiro_macropyre_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_jakiro_macropyre_lua_thinker", "pathfinder/jakiro/modifier_jakiro_macropyre_lua_thinker", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Custom KV
-- Cast Range
function jakiro_macropyre_lua:GetCastRange( vLocation, hTarget )
	return self:GetSpecialValueFor( "cast_range" )
end

function jakiro_macropyre_lua:MakeMacropyreAt(start,point, duration)
	if not IsServer() then return end	

	local caster = self:GetCaster()
	local dir = point - start
	dir.z = 0
	dir = dir:Normalized()		

	-- create thinker
	local thinker = CreateModifierThinker(
		caster, -- player source
		self, -- ability source
		"modifier_jakiro_macropyre_lua_thinker", -- modifier name
		{
			duration = duration,
			-- x = dir.x,
			-- y = dir.y,
			fromx = start.x,
			fromy = start.y,
			fromz = start.z,
			tox = point.x,
			toy = point.y,
			toz = point.z,			
		}, -- kv
		start,
		caster:GetTeamNumber(),
		false
	)	
	table.insert(self.all_pyres, thinker:FindModifierByName("modifier_jakiro_macropyre_lua_thinker"))
end

function jakiro_macropyre_lua:RefreshPyres()	
	if not IsServer() then return end
	-- if not self:IsCooldownReady() and (not self.last_refresh_time or  (GameRules:GetGameTime() - self.last_refresh_time) < self:GetLevelSpecialValueFor("burn_interval", self:GetLevel() -1)) then
	-- 	local current_cooldown = self:GetCooldownTimeRemaining()
	-- 	local extra_cd = self:GetCaster():FindAbilityByName("pathfinder_jakiro_macropyre_eternal"):GetLevelSpecialValueFor("cd_increase",1) * self:GetLevelSpecialValueFor("burn_interval", self:GetLevel() -1)
	-- 	self:EndCooldown()
	-- 	-- self:StartCooldown(current_cooldown + self:GetLevelSpecialValueFor("burn_interval", self:GetLevel() -1) + extra_cd) 
	-- 	self:StartCooldown(current_cooldown + self:GetLevelSpecialValueFor("burn_interval", self:GetLevel() -1)) 
	-- 	self.last_refresh_time = GameRules:GetGameTime()
	-- 	print(GameRules:GetGameTime() - self.last_refresh_time)
	-- end
	for _,pyre in pairs(self.all_pyres) do
		if pyre:GetRemainingTime() < self:GetLevelSpecialValueFor( "burn_interval", self:GetLevel() - 1) * 1.5 then
			pyre:SetDuration(pyre:GetRemainingTime() + self:GetLevelSpecialValueFor( "burn_interval", self:GetLevel() - 1), true)
		end
	end
end



--------------------------------------------------------------------------------
function jakiro_macropyre_lua:Spawn()
	if not self.all_pyres then self.all_pyres = {} end
end

-- Ability Start
function jakiro_macropyre_lua:OnSpellStart()
	self.duration = self:GetSpecialValueFor( "linger_duration" )	
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local range = self:GetCastRange( point, nil ) + caster:GetCastRangeBonus()
	local dir = (point - caster:GetAbsOrigin()):Normalized()
	dir.z = 0
	point = caster:GetAbsOrigin() + dir * range

	local startpoint = caster:GetOrigin() + dir * self:GetLevelSpecialValueFor( "start_distance", self:GetLevel() - 1)	

	self.path_duration = self:GetSpecialValueFor( "duration" )

	self:MakeMacropyreAt(startpoint, point, self.path_duration)

	if caster:HasAbility("pathfinder_jakiro_macropyre_burning_man") then

		local midpoint = caster:GetAbsOrigin() + (point - caster:GetAbsOrigin()):Normalized() * ((point - caster:GetAbsOrigin()):Length2D() / 2)
		local thirdpoint = caster:GetAbsOrigin() + (point - caster:GetAbsOrigin()):Normalized() * ((point - caster:GetAbsOrigin()):Length2D() * 0.6)
		local lastpoint = caster:GetAbsOrigin() + (point - caster:GetAbsOrigin()):Normalized() * ((point - caster:GetAbsOrigin()):Length2D() * 0.9)

		local left = QAngle(0, 90, 0)
		local right = QAngle(0, -90, 0)
		local left_hand = RotatePosition(thirdpoint, left, point)
		local right_hand = RotatePosition(thirdpoint, right, point)
		self:MakeMacropyreAt(left_hand, right_hand, self.path_duration)

		local from = lastpoint
		for i = 1,4 do 
			local qangle = QAngle(0, 90, 0)		
			local left = RotatePosition(point, qangle, from)
			self:MakeMacropyreAt(left, from, self.path_duration)
			from = left
		end

		left = QAngle(0, 130, 0)
		right = QAngle(0, -155, 0)
		local left_leg = RotatePosition(caster:GetAbsOrigin(), left, thirdpoint)
		local right_leg = RotatePosition(caster:GetAbsOrigin(), right, thirdpoint)

		self:MakeMacropyreAt(caster:GetAbsOrigin(), left_leg, self.path_duration)
		self:MakeMacropyreAt(caster:GetAbsOrigin(), right_leg, self.path_duration)
	end

	-- play effects
	local sound_cast = "Hero_Jakiro.Macropyre.Cast"	
	caster:EmitSoundParams(sound_cast, 0, 0.55, 0)
end