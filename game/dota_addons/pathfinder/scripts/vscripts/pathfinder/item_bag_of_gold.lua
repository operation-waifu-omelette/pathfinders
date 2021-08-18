require("libraries.timers")

if item_bag_of_gold == nil then
    item_bag_of_gold = class({})
end

--------------------------------------------------------------------------------

function item_bag_of_gold:OnSpellStart()
    if IsServer() == false then
        return
    end

    if self:GetCurrentCharges() == 0 then
        return
    end

    local nAmount = self:GetCurrentCharges()
    EmitSoundOn("General.Sell", self:GetCaster())

    local nFXShard = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_alchemist/alchemist_lasthit_coins.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(nFXShard, 1, self:GetCaster():GetAbsOrigin())

    local num_players = PlayerResource:GetNumConnectedHumanPlayers()


    for nPlayerID = 0, AGHANIM_PLAYERS - 1 do
        if PlayerResource:GetSelectedHeroEntity(nPlayerID) then
            PlayerResource:GetSelectedHeroEntity(nPlayerID):ModifyGold(math.floor(nAmount / num_players), true, 0)
        end
    end

    self:SetCurrentCharges(1)
    self:SpendCharge()

    UTIL_Remove( self )
end

--------------------------------------------------------------------------------

function item_bag_of_gold:SetLifeTime(time)
    local bag = self
    Timers:CreateTimer(time, function()
        if bag and IsValidEntity(bag) then
            print("removing")     
            UTIL_Remove(bag:GetContainer())       
            UTIL_Remove(bag)
        end
	end)	
end

function item_bag_of_gold:CanUnitPickUp(hUnit)
    if hUnit ~= nil and hUnit:IsNull() == false and hUnit:IsAlive() and
        (hUnit:IsRealHero() or (hUnit:IsOwnedByAnyPlayer() and hUnit:IsCreepHero()) or hUnit:GetUnitName() == "npc_aghsfort_morty") then
        return true
    end

    return false
end

--------------------------------------------------------------------------------
