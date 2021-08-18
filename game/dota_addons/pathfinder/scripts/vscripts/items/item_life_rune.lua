item_life_rune = class({})

require("libraries.has_shard")
--------------------------------------------------------------------------------

function item_life_rune:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function item_life_rune:Precache( context )	
	PrecacheResource( "soundfile", "soundevents/game_sounds.vsndevts", context )
end

--------------------------------------------------------------------------------

function item_life_rune:OnSpellStart()
	if IsServer() then
		if self:GetCaster() ~= nil and self:GetCaster():IsRealHero() then
			local playerMaxLife = AGHANIM_MAX_LIVES

			local playerID = tostring(PlayerResource:GetSteamID(self:GetParent():GetPlayerOwnerID()))

			for id,table in pairs(patron_id) do
				if playerID == id then
					if table.tier > 0 then								
						playerMaxLife = playerMaxLife + 1												
					end
				end
			end

			if self:GetCaster().nRespawnsRemaining >= playerMaxLife then
				self:GetCaster():EmitSoundParams("soundboard.patience", 0.2,0.4,0)				
				local newItem = CreateItem( "item_life_rune", nil, nil )
				newItem:SetPurchaseTime( 0 )
				local drop = CreateItemOnPositionSync( self:GetCaster():GetAbsOrigin(), newItem )
				local dropTarget = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * -400
				newItem:LaunchLoot( false, 50, 1, dropTarget )
				self:SpendCharge()
				return
			else
				self:GetCaster():EmitSoundParams("soundboard.ti3.kor_immortality", 0.2,0.3,0)
			end

			self:GetCaster().nRespawnsRemaining = math.min( self:GetCaster().nRespawnsRemaining + 1, playerMaxLife )
			local hPlayer = self:GetCaster():GetPlayerOwner()
			if hPlayer then
				PlayerResource:SetCustomBuybackCooldown( hPlayer:GetPlayerID(), 0 )
				PlayerResource:SetCustomBuybackCost( hPlayer:GetPlayerID(), 0 )
			end
			
			local netTable = {}
			CustomGameEventManager:Send_ServerToPlayer( self:GetCaster():GetPlayerOwner(), "gained_life", netTable )
			CustomNetTables:SetTableValue( "respawns_remaining", string.format( "%d", self:GetCaster():entindex() ), { respawns = self:GetCaster().nRespawnsRemaining } )

			local gameEvent = {}
			if hPlayer then
				gameEvent["player_id"] = hPlayer:GetPlayerID()
				gameEvent["team_number"] = DOTA_TEAM_GOODGUYS
				gameEvent["locstring_value"] = "#DOTA_Tooltip_Ability_item_life_rune"
				gameEvent["message"] = "#Dungeon_FoundLifeRune"
				FireGameEvent( "dota_combat_event_message", gameEvent )
			end
		end
		self:SpendCharge()
	end
end

--------------------------------------------------------------------------------