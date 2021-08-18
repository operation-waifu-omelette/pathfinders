
--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	thisEntity.boss = thisEntity
	local allies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 20000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
	for _,ally in pairs(allies) do
		if ally:GetUnitName() == "pathfinder_frost_boss" then
			thisEntity.boss = ally
			break
		end
	end
	thisEntity.PreviousOrder = "no_order"

	thisEntity:SetContextThink( "CreeperThink", CreeperThink, 0.5 )
end

--------------------------------------------------------------------------------

function CreeperThink()
	if not IsServer() then
		return
	end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end


	if GameRules:IsGamePaused() == true then
		return 0.1
	end	
	local hEnemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity.boss:GetOrigin(), nil, 8000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
	if #hEnemies == 0 then
		return 0.1
	end

	local fHealthPct = 5
	if thisEntity:GetHealthPercent() <= fHealthPct then
		return Retreat( hEnemies )
	end


	local hAttackTarget = hEnemies[1]
	
	fHealthPct = 15
	if thisEntity:GetHealthPercent() <= fHealthPct and thisEntity.PreviousOrder == "retreat" then
		return Retreat( hEnemies )
	elseif hAttackTarget then
		return Attack(hAttackTarget)
	end

	

	return 0.1
end


-------------------------------------------------------------------------------

--------------------------------------------------------------------------------
function Attack(unit)
	thisEntity.PreviousOrder = "attack"
	thisEntity:MoveToTargetToAttack( unit )			
	return 1.5
end

function Retreat(enemies)	
	thisEntity.PreviousOrder = "retreat"
	local vAwayFromEnemy = thisEntity:GetOrigin() - enemies[1]:GetOrigin()

	for _,enemy in pairs(enemies) do
		if (thisEntity:GetOrigin() - enemy:GetOrigin()):Length2D() < vAwayFromEnemy:Length2D() then
			vAwayFromEnemy =  (thisEntity:GetOrigin() - enemy:GetOrigin())
		end
	end

	vAwayFromEnemy = vAwayFromEnemy:Normalized()
	local vMoveToPos = thisEntity:GetOrigin() + vAwayFromEnemy * thisEntity:GetIdealSpeed()

	-- if away from enemy is an unpathable area, find a new direction to run to
	local nAttempts = 0
	while ( ( not GridNav:CanFindPath( thisEntity:GetOrigin(), vMoveToPos ) ) and ( nAttempts < 5 ) ) do
		vMoveToPos = thisEntity:GetOrigin() + RandomVector( thisEntity:GetIdealSpeed() )
		nAttempts = nAttempts + 1
	end

	thisEntity.fTimeOfLastRetreat = GameRules:GetGameTime()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position = vMoveToPos,
	})

	return 0.5
end

--------------------------------------------------------------------------------