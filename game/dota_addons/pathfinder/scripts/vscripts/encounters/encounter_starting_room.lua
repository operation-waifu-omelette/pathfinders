require("map_encounter")
require("aghanim_utility_functions")
require("spawner")
require("libraries.timers")
require("libraries.has_shard")
require("pathfinder.database_codes")
--------------------------------------------------------------------------------

if CMapEncounter_StartingRoom == nil then
    CMapEncounter_StartingRoom = class({}, {}, CMapEncounter)
end

LinkLuaModifier("modifier_generic_talent_handler", "pathfinder/modifier_generic_talent_handler",
    LUA_MODIFIER_MOTION_NONE)

function CMapEncounter_StartingRoom:Precache(context)
    PrecacheItemByNameSync("item_blink_bootleg", context)
    PrecacheItemByNameSync("item_panic_button", context)
    PrecacheItemByNameSync("item_mirror_shield", context)
    PrecacheItemByNameSync("item_feet_of_midas", context)
    PrecacheItemByNameSync("item_gem", context)
    PrecacheItemByNameSync("item_tome_of_greater_knowledge", context)
end

--------------------------------------------------------------------------------

function CMapEncounter_StartingRoom:constructor(hRoom, szEncounterName)

    CMapEncounter.constructor(self, hRoom, szEncounterName)
    self:GetRoom().hSpawnGroupHandle = GetActiveSpawnGroupHandle()
    self.bRewardsSelected = false
    self.bSpokenGameStartLine = false
    self.bAllButtonsReady = false
end

--------------------------------------------------------------------------------

function CMapEncounter_StartingRoom:Start()
    local nTriggerStartTouchEvent = ListenToGameEvent("trigger_start_touch",
        Dynamic_Wrap(getclass(self), "OnTriggerStartTouch"), self)
    table.insert(self.EventListeners, nTriggerStartTouchEvent)
    local nTriggerEndTouchEvent = ListenToGameEvent("trigger_end_touch",
        Dynamic_Wrap(getclass(self), "OnTriggerEndTouch"), self)
    table.insert(self.EventListeners, nTriggerEndTouchEvent)
    self.nPlayersReady = 0
    local nAscensionSelectedEvent = ListenToGameEvent("aghsfort_ascension_level_selected",
        Dynamic_Wrap(getclass(self), "OnAscensionLevelSelected"), self)
    table.insert(self.EventListeners, nAscensionSelectedEvent)

    self.flStartTime = GameRules:GetGameTime()
    GameRules:GetGameModeEntity():EmitSoundParams("pathfinder_selection_music", 0, 0.55, 0)

    if GameRules.Aghanim:HasSetAscensionLevel() == false then

        -- Default the ascension level now in case we do any developer shit, and juke the system to think we haven't set it yet
        GameRules.Aghanim:SetAscensionLevel(1)
        GameRules.Aghanim.bHasSetAscensionLevel = false

        local nMaxOption = GameRules.Aghanim:GetMaxAllowedAscensionLevel()
        local nOption = 0
        while nOption <= nMaxOption + 1 do
            local hAscensionLocator = Entities:FindByName(nil, "ascension_picker_locator_" .. (nOption)) -- was option+1
            if hAscensionLocator == nil then
                break
            end

            local vOrigin = hAscensionLocator:GetAbsOrigin()
            local vAngles = hAscensionLocator:GetAnglesAsVector()
            local pickerTable = {
                MapUnitName = "npc_dota_aghsfort_watch_tower_option_1",
                origin = tostring(vOrigin.x) .. " " .. tostring(vOrigin.y) .. " " .. tostring(vOrigin.z),
                angles = tostring(vAngles.x) .. " " .. tostring(vAngles.y) .. " " .. tostring(vAngles.z),
                OptionNumber = tostring(nOption),
                teamnumber = DOTA_TEAM_NEUTRALS,
                AscensionLevelPicker = 1
            }

            local picker = CreateUnitFromTable(pickerTable, vOrigin)
            local nFxIndex = ParticleManager:CreateParticle(
                "particles/units/heroes/hero_abaddon/abaddon_curse_counter_stack.vpcf", PATTACH_CUSTOMORIGIN, picker)
            ParticleManager:SetParticleControl(nFxIndex, 0, picker:GetAbsOrigin() + Vector(0, -150, 55))

            -- if nOption == 0 then
            ParticleManager:SetParticleControl(nFxIndex, 1, Vector(nOption + 1, nOption + 1, nOption + 1))
            -- else
            -- 	ParticleManager:SetParticleControl( nFxIndex, 1, Vector(nOption + 2,nOption + 2,nOption + 2))
            -- end
            ParticleManager:ReleaseParticleIndex(nFxIndex)
            nOption = nOption + 1
        end

        if nOption <= 0 then
            print("Unable to find ascension_picker_locator_ entities!\n")
            self:OnAscensionLevelSelected({
                level = 1
            })
            return
        end
    end

    -- Use encounter name to display "select ascension level"
    self:Introduce()
    GameRules:SetItemStockCount(0, DOTA_TEAM_GOODGUYS,"item_life_rune",-1)
end

--------------------------------------------------------------------------------

function CMapEncounter_StartingRoom:OnAscensionLevelSelected(event)
    print("Ascension Level " .. event.level .. " selected")
    if event.level == 0 or event.level == 1 then
        -- GameRules.Aghanim:SetAscensionLevel( event.level - 1)
        Timers:CreateTimer(6, function()
            if RandomInt(1, 100) < 50 then
                EmitGlobalSound("announcer_dlc_bastion_announcer_type_easy_mode_01")
            else
                EmitGlobalSound("announcer_dlc_bastion_announcer_type_easy_mode_02")
            end
        end)
    end

    GameRules.Aghanim:SetAscensionLevel(event.level)
    GameRules:GetGameModeEntity():StopSound("pathfinder_selection_music")
end

--------------------------------------------------------------------------------

function CMapEncounter_StartingRoom:OnThink()
    CMapEncounter.OnThink(self)

    -- Don't speak until all players are connected
    if self.bSpokenGameStartLine == false then

        local nConnectedPlayerCount = 0
        local nPlayerCount = 0
        for nPlayerID = 0, AGHANIM_PLAYERS - 1 do
            if PlayerResource:GetTeam(nPlayerID) == DOTA_TEAM_GOODGUYS and PlayerResource:IsValidPlayerID(nPlayerID) then
                nPlayerCount = nPlayerCount + 1
                if PlayerResource:GetConnectionState(nPlayerID) == DOTA_CONNECTION_STATE_CONNECTED then
                    nConnectedPlayerCount = nConnectedPlayerCount + 1
                end
                -- PlayerResource:GetPlayer(nPlayerID):SetMusicStatus( 0, 0 )
            end
        end

        if nConnectedPlayerCount == nPlayerCount then
            GameRules.Aghanim:GetAnnouncer():OnGameStarted()
            self.bSpokenGameStartLine = true
        end

    end

    -- Update UI indicating who has picked their reward
    local vecRewardState = GameRules.Aghanim:DetermineRewardSelectionState()
    if vecRewardState ~= nil then
        local nNumSelected = 0
        local vecPlayers = GameRules.Aghanim:GetConnectedPlayers()
        for i = 1, #vecPlayers do
            if vecRewardState[tostring(vecPlayers[i])] == true then
                nNumSelected = nNumSelected + 1
            end
        end
        self:UpdateEncounterObjective("objective_select_aghanims_fragmants", nNumSelected, nil)

        if #vecPlayers > 0 and nNumSelected == #vecPlayers then
            self:GetRoom().bSpawnGroupReady = true
            self.bRewardsSelected = true
        end
    end

end

--------------------------------------------------------------------------------

function CMapEncounter_StartingRoom:InitializeObjectives()
    -- CMapEncounter.InitializeObjectives( self )

    self:AddEncounterObjective("objective_stand_on_buttons", 0, 0)
    self:AddEncounterObjective("objective_select_aghanims_fragmants", 0, 0)

end

--------------------------------------------------------------------------------

function CMapEncounter_StartingRoom:OnTriggerStartTouch(event)

    if self.bAllButtonsReady == true then
        return
    end
    -- CustomGameEventManager:Send_ServerToAllClients( "remove_cover", {} )
    -- CustomGameEventManager:Send_ServerToAllClients( "selection_done", {} )

    -- Get the trigger that activates the room
    local szTriggerName = event.trigger_name
    local hUnit = EntIndexToHScript(event.activator_entindex)
    local hTriggerEntity = EntIndexToHScript(event.caller_entindex)
    if szTriggerName == "trigger_player_1" or szTriggerName == "trigger_player_2" or szTriggerName == "trigger_player_3" or
        szTriggerName == "trigger_player_4" then
        -- printf( "szTriggerName: %s, hUnit:GetUnitName(): %s, hTriggerEntity:GetName(): %s", szTriggerName, hUnit:GetUnitName(), hTriggerEntity:GetName() )

        self.nPlayersReady = self.nPlayersReady + 1
        self:UpdateEncounterObjective("objective_stand_on_buttons", self.nPlayersReady, nil)

        local vecPlayers = GameRules.Aghanim:GetConnectedPlayers()
        if #vecPlayers > 0 then
            if self.nPlayersReady >= #vecPlayers then

                self.bAllButtonsReady = true
                GameRules.Aghanim:SetExpeditionStartTime(GameRules:GetGameTime())

                self:GenerateRewards()

                -- We want to announce rewards during the starting room
                GameRules.Aghanim:GetAnnouncer():OnSelectRewards()

                -- Open the main gate
                local hRelays = self:GetRoom():FindAllEntitiesInRoomByName("main_gate_open_relay", false)
                for _, hRelay in pairs(hRelays) do
                    hRelay:Trigger(nil, nil)
                end
            end
        end
    end
end

--------------------------------------------------------------------------------
LinkLuaModifier("modifier_pathfinder_patron", "pathfinder/modifier_pathfinder_patron", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_speaker", "pathfinder/modifier_speaker", LUA_MODIFIER_MOTION_NONE)

function CMapEncounter_StartingRoom:OnTriggerEndTouch(event)

    for nPlayerID = 0, AGHANIM_PLAYERS - 1 do
        PlayerResource:SetCustomIntParam(nPlayerID, self.hRoom:GetDepth() - 1)
    end

    if self.bAllButtonsReady == true then
        return
    end

    -- Get the trigger that activates the room
    local szTriggerName = event.trigger_name
    local hUnit = EntIndexToHScript(event.activator_entindex)
    local hTriggerEntity = EntIndexToHScript(event.caller_entindex)
    if szTriggerName == "trigger_player_1" or szTriggerName == "trigger_player_2" or szTriggerName == "trigger_player_3" or
        szTriggerName == "trigger_player_4" then
        -- printf( "szTriggerName: %s, hUnit:GetUnitName(): %s, hTriggerEntity:GetName(): %s", szTriggerName, hUnit:GetUnitName(), hTriggerEntity:GetName() )

        self.nPlayersReady = self.nPlayersReady - 1
        self:UpdateEncounterObjective("objective_stand_on_buttons", self.nPlayersReady, nil)
    end
end

--------------------------------------------------------------------------------

function CMapEncounter_StartingRoom:CheckForCompletion()
    for nPlayerID = 0, AGHANIM_PLAYERS - 1 do
        if PlayerResource:GetSelectedHeroEntity(nPlayerID) then
            if not PlayerResource:GetSelectedHeroEntity(nPlayerID):HasAbility("ability_aghsfort_capture") then
                PlayerResource:GetSelectedHeroEntity(nPlayerID):AddAbility("ability_aghsfort_capture")
            end
            PlayerResource:GetSelectedHeroEntity(nPlayerID):FindAbilityByName("ability_aghsfort_capture"):SetLevel(1)

        end
    end

    return self.bRewardsSelected == true and GameRules.Aghanim:HasSetAscensionLevel() == true
end

--------------------------------------------------------------------------------

function CMapEncounter_StartingRoom:OnComplete()

    GameRules:GetGameModeEntity():SetPauseEnabled(true)

    CMapEncounter.OnComplete(self)

    -- local allHeroes = HeroList:GetAllHeroes()
    -- for _,hero in pairs(allHeroes) do
    -- 	if hero ~= nil and hero:GetUnitName() == "npc_dota_hero_wisp" then
    -- 		hero:RemoveSelf()
    -- 	end
    -- end

    CustomGameEventManager:Send_ServerToAllClients("show_wiki_button", {})

    for nPlayerID = 0, AGHANIM_PLAYERS - 1 do

        local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)

        local playerID = tostring(PlayerResource:GetSteamID(nPlayerID))
        for id, table in pairs(patron_id) do
            if playerID == id and playerID ~= "76561198053098358" then -- exclude admiralbulldog
                GameRules:SendCustomMessageToTeam("Big thanks to " .. PlayerResource:GetPlayerName(nPlayerID) ..
                                                      " for supporting Pathfinders on Patreon!", 1, 1, 1)
            end
            if playerID == id and playerID == "76561198053098358" then -- admiralbulldog
                GameRules:SendCustomMessageToTeam("Big thanks to " .. PlayerResource:GetPlayerName(nPlayerID) ..
                                                      " for playing Aghanim Pathfinders! I'm a big fan! -Friday", 1, 1,
                    1)
            end
        end

        if hHero then
            -- PlayerResource:GetPlayer(nPlayerID):SetMusicStatus( 0, 1 )
            hHero:SetAbilityPoints(1)
            SendToConsole("dota_unit_sink_delay 20")
            cvar_setf("dota_unit_sink_delay", 20)
            EmitSoundOnClient("General.LevelUp", hHero:GetPlayerOwner())
            ParticleManager:ReleaseParticleIndex(ParticleManager:CreateParticle(
                "particles/generic_hero_status/hero_levelup.vpcf", PATTACH_ABSORIGIN_FOLLOW, nil))
        end

        if hHero then

            Timers:CreateTimer(13, function()
                if not hHero:HasModifier("modifier_speaker") then
                    hHero:AddNewModifier(hHero, nil, "modifier_speaker", {})
                end
            end)

            Timers:CreateTimer(9, function()
                if not hHero:HasModifier("modifier_generic_talent_handler") then
                    print("talent handler added to player " .. nPlayerID)
                    hHero:AddNewModifier(hHero, nil, "modifier_generic_talent_handler", {})
                end
            end)

            Timers:CreateTimer(5, function()
                if not hHero:HasModifier("modifier_pathfinder_patron") and patron_id then
                    local playerID = tostring(PlayerResource:GetSteamID(nPlayerID))
                    for id, table in pairs(patron_id) do
                        if playerID == id then
                            hHero:AddNewModifier(hHero, nil, "modifier_pathfinder_patron", {})
                        end
                    end
                end
            end)
        end
    end
end

--------------------------------------------------------------------------------

return CMapEncounter_StartingRoom
