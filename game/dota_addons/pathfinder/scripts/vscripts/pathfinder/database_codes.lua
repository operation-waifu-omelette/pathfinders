function AddMatchField(heroTable, pID, tier)
    if not IsServer() then return end

    local encoded = json.encode(heroTable)

    local request = CreateHTTPRequestScriptVM( 
        "PUT",
        SERVER_LOCATION.. "ascension_" .. tier .. "/" .. "match_" .. tostring(GameRules:Script_GetMatchID()).. "/" .. "player_" .. tostring(pID) .. '.json'
    )
    
    request:SetHTTPRequestRawPostBody("application/json", encoded)

    request:Send( 
        function( result )
            -- Do nothing
        end
    )

end



function SetupDatabaseTable(depth)
    if not IsServer() then return end
    for nPlayerID = 0, AGHANIM_PLAYERS - 1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			if PlayerResource:IsValidPlayerID( nPlayerID ) then
				local hHero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if hHero ~= nil then
                    local table_name = "TABLEP" .. nPlayerID
                    		
					local hero_name = string.sub(hHero:GetUnitName(), 15)					
                    _G[table_name]["hero"] = hero_name					
                    
                    local upgrades = {}

                    for _,upgrade in pairs(SPECIAL_ABILITY_UPGRADES[hHero:GetUnitName()]) do
                        if hHero:HasAbility(upgrade) then
                            table.insert(upgrades, upgrade)
                        end
                    end

                    _G[table_name]["upgrades"] = upgrades		
                    _G[table_name]["depth"] = depth

                    -- _G[table_name]["damage_dealt"] = PlayerResource:GetRawPlayerDamage(nPlayerID)
                    _G[table_name]["damage_taken"] = PlayerResource:GetHeroDamageTaken(nPlayerID, true) + PlayerResource:GetCreepDamageTaken(nPlayerID, true)
                    -- _G[table_name]["healing"] = PlayerResource:GetHealing(nPlayerID)                    

                    _G[table_name]["deaths"] = 0

                    local items = {}
                    for slot=0,8 do
                        local item = hHero:GetItemInSlot(slot)
                        if item then
                            table.insert(items, item:GetAbilityName())
                        end
                    end
                    local item = hHero:GetItemInSlot(16)
                    if item then
                        table.insert(items, item:GetAbilityName())
                    end
                    _G[table_name]["items"] = items
                end
            else
                local table_name = "TABLEP" .. nPlayerID                    											
                _G[table_name]["hero"] = "invalid"
			end
		end
    end	
end

function SetupRoomDatabaseTable(signoutTable)
    local depth_list = signoutTable["team_depth_list"]
    for num,depth in pairs(depth_list) do
        _G["TABLEROOM"]["victory"] = false
        if signoutTable["won_game"] then
            _G["TABLEROOM"]["victory"] = signoutTable["won_game"]
        end
        _G["TABLEROOM"][num] = {}

        _G["TABLEROOM"][num]["picked_name"] = depth["selected_encounter"]
        _G["TABLEROOM"][num]["picked_elite"] = depth["selected_elite"]

        if depth["unselected_encounter"] then
            _G["TABLEROOM"][num]["unpicked_name"] = depth["unselected_encounter"]
        else
            _G["TABLEROOM"][num]["unpicked_name"] = "nil"
        end

        if depth["unselected_elite"] then
            _G["TABLEROOM"][num]["unpicked_elite"] = depth["unselected_elite"]
        else
            _G["TABLEROOM"][num]["unpicked_elite"] = "nil"
        end

        _G["TABLEROOM"][num]["modifiers"] = {}

        if depth["ascension_abilities"] then
            for mod,_ in pairs(depth["ascension_abilities"]) do
                table.insert(_G["TABLEROOM"][num]["modifiers"], mod)
            end
        end

        _G["TABLEROOM"][num]["lives_lost"] = 0
        for nPlayerID = 0, AGHANIM_PLAYERS - 1 do
		    if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
                if PlayerResource:IsValidPlayerID( nPlayerID ) then                    
                    if signoutTable["player_list"][nPlayerID]["depth_list"][tostring(num)]["death_count"] then
                        _G["TABLEROOM"][num]["lives_lost"] = _G["TABLEROOM"][num]["lives_lost"] + signoutTable["player_list"][nPlayerID]["depth_list"][tostring(num)]["death_count"]
                    end
                end
            end
        end
    end
end