

function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	thisEntity.Encounter = nil


	Nova = thisEntity:FindAbilityByName( "frost_boss_nova" )
	Pull = thisEntity:FindAbilityByName( "frost_boss_pull" )
	-- Creeper = thisEntity:FindAbilityByName( "frost_boss_creeper" )
	MassiveNova= thisEntity:FindAbilityByName( "frost_boss_massive_nova" )


	thisEntity:SetContextThink( "FrostBossThink", FrostBossThink, 1 )
	
	local hCurrentEncounter = GameRules.Aghanim:GetCurrentRoom():GetEncounter()
	if hCurrentEncounter.activeTargets == nil then
		hCurrentEncounter.activeTargets = {}
	end
	thisEntity.nextTargetTime = GameRules:GetGameTime()
end

--------------------------------------------------------------------------------

function FrostBossThink()
	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if thisEntity.Encounter == nil then
		return 1
	end

	if GameRules:IsGamePaused() == true then
		return 0.1
	end

	if thisEntity:IsChanneling() == true then
		return 0.1
	end


	if MassiveNova ~= nil and MassiveNova:IsCooldownReady() and thisEntity:GetHealthPercent() <= 50 then
		return DoMassiveNova()
	end

	-- if Creeper ~= nil and Creeper:IsCooldownReady() and thisEntity:GetHealthPercent() <= 90 then
	-- 	local allies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 18000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
	-- 	local creep_count = 0
	-- 	for _,ally in pairs(allies) do
	-- 		if ally:GetUnitName() == "frost_boss_summon" then
	-- 			creep_count = creep_count + 1
	-- 		end
	-- 	end
	-- 	if PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) > 1 and creep_count < 1 then
	-- 		return DoCreeper()
	-- 	end
	-- end

	local hEnemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, thisEntity:GetAcquisitionRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
	if #hEnemies == 0 then
		return 0.1
	end

	if Pull ~= nil and Pull:IsCooldownReady() and thisEntity:GetHealthPercent() < 95 then
		local hFarthestEnemy = hEnemies[ #hEnemies ]
		if hFarthestEnemy ~= nil then
			local flDist = (hFarthestEnemy:GetOrigin() - thisEntity:GetOrigin()):Length2D()
			if flDist > 400 then
				return DoPull( hFarthestEnemy )
			end
		end
	end


	if Nova ~= nil and Nova:IsCooldownReady() then		
		return DoNova()
	end

	-- Acquire a new target if necessary
	if thisEntity.hTarget == nil or ( thisEntity.nextTargetTime <= GameRules:GetGameTime() ) or
		not thisEntity.hTarget:IsAlive() then
			SelectNewTarget()
	end


	return 0.1
end

--------------------------------------------------------------------------------

function DoMassiveNova()	
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = MassiveNova:entindex(),
		Queue = false,
	})
	-- local szLines = 
	-- {
	-- 	"night_stalker_nstalk_ability_dark_07",
	-- 	"night_stalker_nstalk_respawn_01",
	-- 	"night_stalker_nstalk_respawn_02",
	-- 	"night_stalker_nstalk_respawn_05",
	-- 	"night_stalker_nstalk_respawn_07",
	-- 	"night_stalker_nstalk_respawn_08",
	-- }
	-- EmitGlobalSound(szLines[ RandomInt( 1, #szLines ) ])

	local fReturnTime = MassiveNova:GetCastPoint() + MassiveNova:GetChannelTime() + 0.5
	return fReturnTime
end

--------------------------------------------------------------------------------

function DoPull( enemy )
	--print( "temple_guardian - Pull" )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = Pull:entindex(),
		Position = enemy:GetOrigin(),
		Queue = false,
	})
	-- local szLines = 
	-- {
	-- 	"night_stalker_nstalk_ability_dark_08",
	-- 	"night_stalker_nstalk_ability_dark_09",
	-- 	"night_stalker_nstalk_ability_dark_10",
	-- 	"night_stalker_nstalk_ability_dark_11",
	-- }
	-- EmitGlobalSound(szLines[ RandomInt( 1, #szLines ) ])

	local fReturnTime = Pull:GetCastPoint() 
	return fReturnTime
end

--------------------------------------------------------------------------------
----------------------------------------------------------------

function DoNova( )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = Nova:entindex(),
		Queue = false,
	})

	-- local szLines = 
	-- {
	-- 	"night_stalker_nstalk_ability_dark_05",
	-- 	"night_stalker_nstalk_ability_cripfear_02",
	-- 	"night_stalker_nstalk_ability_dark_01",
	-- 	"night_stalker_nstalk_ability_dark_02",
	-- }
	-- EmitGlobalSound(szLines[ RandomInt( 1, #szLines ) ])


	local fReturnTime = Nova:GetCastPoint()
	return fReturnTime
end

--------------------------------------------------------------------------------

-- function DoCreeper( )
-- 	ExecuteOrderFromTable({
-- 		UnitIndex = thisEntity:entindex(),
-- 		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
-- 		AbilityIndex = Creeper:entindex(),
-- 		Queue = false,
-- 	})
-- 	-- local szLines = 
-- 	-- {
-- 	-- 	"night_stalker_nstalk_respawn_10",
-- 	-- 	"night_stalker_nstalk_spawn_05",
-- 	-- 	"night_stalker_nstalk_spawn_02",
-- 	-- 	"night_stalker_nstalk_ability_cripfear_01",
-- 	-- 	"night_stalker_nstalk_ability_cripfear_03",
-- 	-- 	"night_stalker_nstalk_move_08",
-- 	-- 	"night_stalker_nstalk_move_13",
-- 	-- }
-- 	-- EmitGlobalSound(szLines[ RandomInt( 1, #szLines ) ])


-- 	local fReturnTime = Creeper:GetCastPoint()
-- 	return fReturnTime
-- end

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

function RemoveAvailableTarget( availableHeroes, nEntIndexToRemove )

	if #availableHeroes == 1 then
		return
	end
	
	for i=1,#availableHeroes do
		if availableHeroes[i]:entindex() == nEntIndexToRemove then
			table.remove( availableHeroes, i )
			break
		end
	end

end

--------------------------------------------------------------------------------------------------------


function SelectNewTarget( )

	local hCurrentEncounter = GameRules.Aghanim:GetCurrentRoom():GetEncounter()

	-- Mark current target as not active any more
	-- Important to do prior to the code that grab a target which is not already being chased
	local nEntIndex = -1
	if thisEntity.hTarget ~= nil then
		nEntIndex = thisEntity.hTarget:entindex()
		hCurrentEncounter.activeTargets[ tostring( nEntIndex ) ] = nil
	end

	local availableHeroes = GetAliveHeroesInRoom()

	-- Prefer to pick a different target from last time
	RemoveAvailableTarget( availableHeroes, nEntIndex )

	-- Select a random target from the available ones
	local hNewTarget = nil
	if #availableHeroes > 0 then		
		hNewTarget = availableHeroes[ math.random( 1, #availableHeroes ) ]
		for _,hero in pairs(availableHeroes) do
			if hero:GetHealth() < hNewTarget:GetHealth() then
				hNewTarget = hero
			end
		end
	end

	thisEntity.hTarget = hNewTarget
	thisEntity.nextTargetTime = GameRules:GetGameTime() + 5	-- Keep on this target for 8 seconds at least

	if thisEntity.hTarget ~= nil then
		hCurrentEncounter.activeTargets[ tostring( thisEntity.hTarget:entindex() ) ] = true
	end

end
