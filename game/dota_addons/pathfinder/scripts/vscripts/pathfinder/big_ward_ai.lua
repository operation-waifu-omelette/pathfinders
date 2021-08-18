
--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	FireAbility = thisEntity:FindAbilityByName( "pathfinder_fire_breath" )	

	thisEntity:SetContextThink( "BigWardThink", BigWardThink, 1 )
end

--------------------------------------------------------------------------------

function BigWardThink()
	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 1
	end


	if FireAbility ~= nil and FireAbility:IsCooldownReady() then
		local enemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 900, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false )
		if #enemies > 0 then
			return Fire(enemies[1]:GetOrigin())
		end
	end

	return 0.5
end

--------------------------------------------------------------------------------

function Fire( location )
	thisEntity:AddNewModifier( thisEntity, nil, "modifier_provide_vision", { duration = 1.3 } ) 	
	
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = location,
		AbilityIndex = FireAbility:entindex(),		
	})

	return 1.5 -- was 1.2
end

--------------------------------------------------------------------------------