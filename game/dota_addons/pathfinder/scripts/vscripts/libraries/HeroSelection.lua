

SELECTION_DURATION_LIMIT = 6969
SELECTION_SHOWCASE_DURATION = 7
--Class definition
HeroSelection = class({})
require("libraries.timers")
-- require("events")
--Constant parameters


PLAYER_MOVED = {false,false,false,false}



function HeroSelection:Precache( context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_announcer_dlc_bastion.vsndevts", context )
end


function HeroSelection:Start()	
	if IsServer() then		
		GameRules:GetGameModeEntity():EmitSound("pathfinder_selection_music")
		local time = tonumber(string.sub(LocalTime().Hours,1,2))
		if time >= 4 and time < 12 then			
			EmitGlobalSound("announcer_dlc_bastion_announcer_welcome_morning")
		elseif time >= 12 and time < 18 then
			EmitGlobalSound("announcer_dlc_bastion_announcer_welcome_afternoon")
		elseif time >= 18 and time < 22 then
			EmitGlobalSound("announcer_dlc_bastion_announcer_welcome_evening")
		elseif (time >= 22 and time < 25) or (time >= 0 and time < 4) then
			EmitGlobalSound("announcer_dlc_bastion_announcer_welcome_night")
		end
		TimeSound(5, "announcer_dlc_bastion_announcer_choose_hero")		
	end
	--Figure out which players have to pick
	 HeroSelection.playerPicks = {}
	 HeroSelection.numPickers = 0

	for pID = 0, AGHANIM_PLAYERS -1 do
		if PlayerResource:IsValidPlayer( pID ) then			 
			HeroSelection.numPickers = self.numPickers + 1

			local temp = {pid = pID,}
			CAghanim:SpawnWisp( temp)
		end
	end

	--Start the pick timer
	HeroSelection.TimeLeft = SELECTION_DURATION_LIMIT
	Timers:CreateTimer( 0.04, HeroSelection.Tick ) 

	--Keep track of the number of players that have picked
	HeroSelection.playersPicked = 0

	--Listen for the pick event
	HeroSelection.listener = CustomGameEventManager:RegisterListener( "hero_selected", HeroSelection.HeroSelect )

	Timers:CreateTimer(6, function()
		CustomGameEventManager:Send_ServerToAllClients( "remove_cover", {} )	
	end)	
end

--[[
	Tick
	A tick of the pick timer.
	Params:
		- event {table} - A table containing PlayerID and HeroID.
]]
function HeroSelection:Tick() 
	for pID = 0, AGHANIM_PLAYERS -1 do		
		if PlayerResource:IsValidPlayerID( pID ) and PLAYER_MOVED[pID+1] == false then
			if PlayerResource:IsValidPlayer( pID ) and PlayerResource:GetPlayer(pID):GetAssignedHero() then			 			
				if not PlayerResource:GetPlayer(pID):GetAssignedHero():HasModifier("modifier_hero_select")  then
					local temp = { pid = pID,}
					CAghanim:SpawnWisp( temp)
					PLAYER_MOVED[pID+1] = true
				end
			end
		end
	end
	--Send a time update to all clients
	if HeroSelection.TimeLeft >= 0 then
		CustomGameEventManager:Send_ServerToAllClients( "picking_time_update", {time = HeroSelection.TimeLeft} )
	end

	if HeroSelection.TimeLeft < 75 then
		CustomGameEventManager:Send_ServerToAllClients( "remove_cover", {} )	
	end

	if HeroSelection.TimeLeft == 30 then
		if RandomInt(1,100) < 50 then
			EmitGlobalSound("announcer_dlc_bastion_announcer_count_battle_30_01")
		else
			EmitGlobalSound("announcer_dlc_bastion_announcer_count_battle_30_02")
		end
	elseif  HeroSelection.TimeLeft == 10 then
		if RandomInt(1,100) < 50 then
			EmitGlobalSound("announcer_dlc_bastion_announcer_count_battle_10_01")
		else
			EmitGlobalSound("announcer_dlc_bastion_announcer_count_battle_10_02")
		end
	end

	--Tick away a second of time
	HeroSelection.TimeLeft = HeroSelection.TimeLeft - 1
	if HeroSelection.TimeLeft == -1 then
		--End picking phase
		HeroSelection:EndPicking()
		return nil
	elseif HeroSelection.TimeLeft >= 0 then
		return 1
	else
		return nil
	end
end

--[[
	HeroSelect
	A player has selected a hero. This function is caled by the CustomGameEventManager
	once a 'hero_selected' event was seen.
	Params:
		- event {table} - A table containing PlayerID and HeroID.
]]
function HeroSelection:HeroSelect( event )
	local confirmedUnit = PlayerResource:GetPlayer(event.id):GetAssignedHero():FindModifierByName("modifier_hero_select").player_heroes["npc_dota_hero_" .. event.hero]	
	if IsServer() then

		HeroSelection:LockFaceVoiceLine(event.hero)

		local pfx = ParticleManager:CreateParticle( "particles/econ/events/ti10/fountain_regen_ti10_streak.vpcf", PATTACH_ABSORIGIN_FOLLOW, confirmedUnit )
		local pfx2 = ParticleManager:CreateParticle( "particles/econ/events/ti10/fountain_regen_ti10_energy.vpcf", PATTACH_ABSORIGIN_FOLLOW, confirmedUnit )
		ParticleManager:SetParticleControl( pfx, 1, Vector(HeroSelection.TimeLeft, 0, 0) ) 		
		ParticleManager:SetParticleControl( pfx2, 1, Vector(HeroSelection.TimeLeft, 0, 0) ) 		

		Timers:CreateTimer(HeroSelection.TimeLeft, function()
			ParticleManager:DestroyParticle(pfx, false)
			ParticleManager:ReleaseParticleIndex(pfx)

			ParticleManager:DestroyParticle(pfx2, false)
			ParticleManager:ReleaseParticleIndex(pfx2)
		end)
	end
	

	HeroSelection.playersPicked = HeroSelection.playersPicked + 1

	--Check if all heroes have been picked
	if HeroSelection.playersPicked >= HeroSelection.numPickers then
		--End picking		
		HeroSelection.TimeLeft = SELECTION_SHOWCASE_DURATION		
		HeroSelection:Tick()
	end
end

--[[
	EndPicking
	The final function of hero selection which is called once the selection is done.
	This function spawns the heroes for the players and signals the picking screen
	to disappear.
]]
function HeroSelection:EndPicking()
	if not IsServer() then return end
	GameRules:GetGameModeEntity():StopSound("pathfinder_selection_music")
	

	local connectedPlayers = GameRules.Aghanim:GetConnectedPlayers()
	local onlyOne = #connectedPlayers < 2
	local onlyTwo = #connectedPlayers < 3

	--Signal the picking screen to disappear
	CustomGameEventManager:Send_ServerToAllClients( "selection_done", {} )

	for pID = 0, AGHANIM_PLAYERS -1 do
		if PlayerResource:IsValidPlayerID( pID ) == true then
			local choice = PlayerResource:GetPlayer(pID):GetAssignedHero():FindModifierByName( "modifier_hero_select" ).current_hero:GetUnitName(  )			

			local spawn_pos = Entities:FindByName(nil, "here_too"):GetAbsOrigin()
			PlayerResource:GetPlayer(pID):GetAssignedHero():SetAbsOrigin( spawn_pos )
			
			if choice == "npc_dota_hero_wisp" then
				choice = HERO_LIST[RandomInt( 1, #HERO_LIST )]			
			end						

			for _,dummy in pairs(PlayerResource:GetPlayer(pID):GetAssignedHero():FindModifierByName( "modifier_hero_select" ).player_heroes) do
				print("KILLING OFF " .. dummy:GetUnitName())
				dummy:SetControllableByPlayer(-1,false)
				dummy:RemoveSelf()
				-- dummy:ForceKill(false)
			end			
			PrecacheUnitByNameAsync(choice, function()
				PlayerResource:ReplaceHeroWith(pID, choice, AGHANIM_STARTING_GOLD, 0)
			end)		
			PlayerResource:SetCameraTarget(pID,  nil)
			
			
							
			Timers:CreateTimer(2, function()
				if PlayerResource:IsValidPlayer( pID ) then			
					local player = PlayerResource:GetPlayer(pID):GetAssignedHero()

				
					if onlyOne then
							GameRules:SendCustomMessage("A Constellation of Midaeum is touched by your lonely spirit, and had lend you a helping hand— eh... foot.",2,0	)
							local midas = GrantItemDropToHero( player, "item_feet_of_midas" )
							if midas ~= nil then
								local charges = 1 + ((AGHANIM_STARTING_GOLD * 2) /midas:GetSpecialValueFor( "bonus_gold" ))
								midas:SetCurrentCharges( charges )
							end
							GrantItemDropToHero( player, "item_panic_button" )
							GrantItemDropToHero( player, "item_mirror_shield" )
							GrantItemDropToHero( player, "item_gem" )	
																	
					elseif onlyTwo then				
							local midas = GrantItemDropToHero( player, "item_feet_of_midas" )
							GameRules:SendCustomMessage("A Constellation of Midaeum takes pity upon your feeble party, and had lend you their helping hands— eh... feet.",2,0)
							if midas ~= nil then
							local charges = 1 + ((AGHANIM_STARTING_GOLD) /midas:GetSpecialValueFor( "bonus_gold" ))
							midas:SetCurrentCharges( charges )
							end
							GrantItemDropToHero( player, "item_panic_button" )					
										
					end

					if player:HasModifier("modifier_hero_select") then
						player:RemoveModifierByName("modifier_hero_select")
					end
					if player:HasModifier("modifier_dummy") then
						player:RemoveModifierByName("modifier_dummy")
					end							
				end				
			end)
		end
	end	
	local bg = Entities:FindByName(nil, "selectionBG")
	if bg then
		bg:SetAbsScale(0.05)
		bg:SetAbsOrigin(Vector(0,0,-2000))
	end
	bg = Entities:FindByName(nil, "selectionBG2")
	if bg then
		bg:SetAbsScale(0.05)
		bg:SetAbsOrigin(Vector(0,0,-2000))
	end
	Timers(function()
		CustomGameEventManager:Send_ServerToAllClients( "remove_cover", {} )
		CustomGameEventManager:Send_ServerToAllClients( "selection_done", {} )
    return 10
  end)
end


function HeroSelection:LockFaceVoiceLine(heroName)	
	local hero = heroName
    if hero == "legion_commander" then 
        hero = "legioncommander"
    elseif hero == "witch_doctor" then 
        hero = "wd"
    
    elseif hero == "templar_assassin" then 
        hero = "ta"
    
    elseif hero == "phantom_assassin" then 
        hero = "pa"
      
    elseif hero == "omniknight" then 
        hero = "omni"
    
    elseif hero == "windrunner" then 
        hero = "wr"
    
    elseif hero == "auroth" then 
        hero = "winter_wyvern"
    
    elseif hero == "venomancer" then 
        hero = "veno"
    
    elseif hero == "queenofpain" then 
        hero = "qop"
    
    elseif hero == "winter_wyvern" then 
		hero = "auroth"
	end
    
	if hero ~= "viper" then 
		EmitGlobalSound("announcer_dlc_bastion_announcer_pick_" .. hero .. "_follow")        
    else 
        if RandomInt(0,100) < 50 then 
            EmitGlobalSound("announcer_dlc_bastion_announcer_pick_" .. hero .. "_follow")        
        
		else 
			EmitGlobalSound("viper_vipe_spawn_05")                    
		end         
	end
    

	if hero == "tusk" then 
		EmitGlobalSound("announcer_dlc_bastion_announcer_pick_tuskkar_follow_02")                
	elseif hero == "mars" then 
		EmitGlobalSound("mars_mars_respawn_08") 					
    elseif hero == "snapfire" then 	
		EmitGlobalSound("snapfire_snapfire_immort_02") 
	end	
end
    