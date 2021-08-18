require( "map_encounter" )
require( "aghanim_utility_functions" )
require( "spawner" )
require( "portalspawnerv2" )
--------------------------------------------------------------------------------

if CMapEncounter_Smol_Bears == nil then
	CMapEncounter_Smol_Bears = class( {}, {}, CMapEncounter )
end

function CMapEncounter_Smol_Bears:constructor( hRoom, szEncounterName )
	CMapEncounter.constructor( self, hRoom, szEncounterName )

	self:SetCalculateRewardsFromUnitCount( true )

	-- Initial Spawns
	self:AddSpawner( CDotaSpawner( "spawner_peon", "spawner_peon",
		{
			{
				EntityName = "pathfinders_big_boi_bear",
				Team = DOTA_TEAM_BADGUYS,
				Count = 3,
				PositionNoise = 500.0,
			}
		} ) )

	-- Wave Spawns
	local vPeonSchedule =
	{
		{
			Time = 1,
			Count = 2,
		},
		{
			Time = 4,
			Count = 2,
		},
		{
			Time = 7,
			Count = 2,
		},
		{
			Time = 10,
			Count = 2,
		},
		{
			Time = 13,
			Count = 2,
		},
		{
			Time = 16,
			Count = 2,
		},
		{
			Time = 19,
			Count = 2,
		},
		{
			Time = 21,
			Count = 2,
		},
	}

	local nPeonPortalHealth = 25 * hRoom:GetDepth()

	self:AddPortalSpawnerV2( CPortalSpawnerV2( "portal_v2_peon", "portal_v2_peon", nPeonPortalHealth, 10, 0.7,
		{
			{
				EntityName = "pathfinders_smol_bear",
				Team = DOTA_TEAM_BADGUYS,
				Count = 3,
				PositionNoise = 150.0,
			},
		} ), vPeonSchedule )



	self:SetSpawnerSchedule( "spawner_peon", { { Time = 0, Count = 1 } } ) 
	self:SetSpawnerSchedule( "portal_v2_peon", vPeonSchedule )	

end

--------------------------------------------------------------------------------

function CMapEncounter_Smol_Bears:GetPreviewUnit()
	return "pathfinders_big_boi_bear"
end

--------------------------------------------------------------------------------

function CMapEncounter_Smol_Bears:Start()
	CMapEncounter.Start( self )

	self:StartSpawnerSchedule( "spawner_peon", 0 )	
	self:StartSpawnerSchedule( "portal_v2_peon", 3 )	

end

--------------------------------------------------------------------------------

function CMapEncounter_Smol_Bears:OnSpawnerFinished( hSpawner, hSpawnedUnits )
	CMapEncounter.OnSpawnerFinished( self, hSpawner, hSpawnedUnits )

	--print( "CMapEncounter_Hellbears:OnSpawnerFinished " )
	local heroes = FindRealLivingEnemyHeroesInRadius( DOTA_TEAM_BADGUYS, self.hRoom:GetOrigin(), FIND_UNITS_EVERYWHERE )

	for _, hSpawnedUnit in pairs ( hSpawnedUnits ) do
		local hero = heroes[RandomInt(1, #heroes)]
		if hero ~= nil then
			--printf( "Set initial goal entity for unit \"%s\" to \"%s\"", hSpawnedUnit:GetUnitName(), hero:GetUnitName() )
			hSpawnedUnit:SetInitialGoalEntity( hero )
		else
			print( "WARNING: Can't find a living hero and the objective entitiy is missing!" ) 
		end
	end

end

--------------------------------------------------------------------------------

return CMapEncounter_Smol_Bears
