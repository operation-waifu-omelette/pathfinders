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
modifier_hero_select = class({})
LinkLuaModifier( "modifier_dummy", "pathfinder/modifier_dummy", LUA_MODIFIER_MOTION_NONE )
require("libraries.timers")
function modifier_hero_select:GetOffset(num)
	local pos = {Vector(-190,185,-645),
				Vector(-450,100,-370),
				Vector(85,465,-362),
				Vector(-220,400,-135)}	--bot to top, left to right
	
	return pos[num]
end

function modifier_hero_select:ApplyOffset(playerID)
		local unit = self:GetParent()
		local p = Entities:FindByName(nil, "anchor")						
		local pNum = playerID + 1	
		self.pos = p:GetAbsOrigin() + self:GetOffset(pNum)
		unit:SetAbsOrigin(self.pos)
		unit:FaceTowards(p:GetAbsOrigin())
		PlayerResource:SetCameraTarget( playerID, p )
		self:GetParent():ClearActivityModifiers()						
		self:GetParent():AddActivityModifier("loadout")
		self:GetParent():StartGestureWithFade(ACT_DOTA_SPAWN, 0.25, 1)

		local spawnBlendDelay = 1
		if self:GetParent():GetUnitName() == "npc_dota_hero_snapfire" then
			spawnBlendDelay = 4.5
		end

		Timers:CreateTimer(self:GetParent():ActiveSequenceDuration() - spawnBlendDelay, function()
			self:GetParent():StartGestureWithFade(ACT_DOTA_LOADOUT, 0.5, 0.5)
		end)
end

--------------------------------------------------------------------------------
-- Classifications
function modifier_hero_select:IsHidden()
	return false
end

function modifier_hero_select:RemoveOnDeath(  )
-- True/false if this modifier is removed when the parent dies.()
	return false
end

function modifier_hero_select:GetPriority()
	return MODIFIER_PRIORITY_ULTRA + 1000001
end


-- Initializations
function modifier_hero_select:OnCreated( kv )
	self.player_heroes = {}
	self.current_hero = self:GetParent()
	if IsServer() then				
		local p = Entities:FindByName(nil, "anchor")		
		if not p then
			Timers:CreateTimer(0.4, function()
				self:OnCreated(kv)
				return nil
			end)
			return
		end		
		local pNum = self:GetParent():GetPlayerOwnerID() + 1		
		self.pos = p:GetAbsOrigin() + self:GetOffset(pNum)
		self:GetParent():SetAbsOrigin(self.pos)
		self:GetParent():FaceTowards(p:GetAbsOrigin())
		PlayerResource:SetCameraTarget( self:GetParent():GetPlayerOwnerID(), p )				
		--self:StartIntervalThink(1)
		self:GetParent():AddActivityModifier("loadout")
		self:GetParent():StartGestureWithFade(ACT_DOTA_SPAWN, 0.25, 1)

		local spawnBlendDelay = 1
		if self:GetParent():GetUnitName() == "npc_dota_hero_snapfire" then
			spawnBlendDelay = 4.5
		end

		Timers:CreateTimer(self:GetParent():ActiveSequenceDuration() - spawnBlendDelay, function()
			self:GetParent():StartGestureWithFade(ACT_DOTA_LOADOUT, 0.5, 0.5)
		end)

		if self:GetParent():GetUnitName() == "npc_dota_hero_wisp" then
			self.player_heroes = {}			
			self:PreloadHeroes()
			if self:GetParent():GetPlayerOwnerID() == 0 then 
				AddFOWViewer(DOTA_TEAM_GOODGUYS, self:GetParent():GetAbsOrigin(), 800, 100, false)				
			end
		end
	end
end

function modifier_hero_select:PreloadHeroes()
	
	if not IsServer() then return end
	
	local spawn_pos = Entities:FindByName(nil, "spawn_here"):GetAbsOrigin()
	
	local heroPrecache = HERO_LIST
	for _,hero in pairs(heroPrecache) do
		local nPlayerID = self:GetParent():GetPlayerID()
		self.player_heroes[hero] = CreateHeroForPlayer(hero, PlayerResource:GetPlayer(nPlayerID))
		self.player_heroes[hero]:SetAbsOrigin(spawn_pos)
		self.player_heroes[hero]:AddNewModifier( nil, nil, "modifier_dummy", {})		
		
	end

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_hero_select:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,			
	}
	return funcs
end

function modifier_hero_select:GetOverrideAnimation()	
  	return ACT_DOTA_LOADOUT
end



--------------------------------------------------------------------------------
-- Status Effects
function modifier_hero_select:CheckState()
	local state = {	}
	if IsServer() then
		state = {[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
				[MODIFIER_STATE_FLYING]	= true,
				[MODIFIER_STATE_NO_HEALTH_BAR]	= true,
				[MODIFIER_STATE_UNSELECTABLE ]=true,
				}
	end
	return state
end


function modifier_hero_select:OnDestroy()
	
	PlayerResource:SetCameraTarget( self:GetParent():GetPlayerOwnerID(), self:GetParent() )	
	self:GetParent():ClearActivityModifiers()	
	PlayerResource:SetCameraTarget( self:GetParent():GetPlayerOwnerID(), nil )
	CenterCameraOnUnit( self:GetParent():GetPlayerID(), self:GetParent() )				
	self:GetParent():FadeGesture(ACT_DOTA_LOADOUT)
end