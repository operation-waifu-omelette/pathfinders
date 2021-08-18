
require( "map_encounter" )
require( "aghanim_utility_functions" )
require( "spawner" )
require( "encounters/encounter_boss_base" )
require("libraries.has_shard")


LinkLuaModifier("modifier_drop_potion_on_death", "pathfinder/pf_items", LUA_MODIFIER_MOTION_NONE)


--------------------------------------------------------------------------------

if CMapEncounter_PathfinderFrostBoss == nil then
	CMapEncounter_PathfinderFrostBoss = class( {}, {}, CMapEncounter_BossBase )	
end


function CMapEncounter_PathfinderFrostBoss:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_vo_night_stalker.vsndevts", context )
end
--------------------------------------------------------------------------------

function CMapEncounter_PathfinderFrostBoss:constructor( hRoom, szEncounterName )

	CMapEncounter_BossBase.constructor( self, hRoom, szEncounterName )

	self.szBossSpawner = "spawner_boss"

	self:AddSpawner( CDotaSpawner( self.szBossSpawner, self.szBossSpawner,
		{ 
			{
				EntityName = "pathfinder_frost_boss",
				Team = DOTA_TEAM_BADGUYS,
				Count = 1,
				PositionNoise = 0.0,
			},
		} ) )	
end


function CMapEncounter_PathfinderFrostBoss:OnBossSpawned( hBoss )
	CMapEncounter_BossBase.OnBossSpawned( self, hBoss )
	
	local frost_boss_sound = {	"frost_boss_name",
								"frost_boss_follow"}

	EmitManySounds(frost_boss_sound, 2.15)

	local crate_mult = 1.1
	if GameRules.Aghanim:GetAscensionLevel() < 2 then
		crate_mult = 3
	end

	local crate_count = RandomInt( DEFAULT_MIN_CRATES_BOSS_ENC * crate_mult, DEFAULT_MAX_CRATES_BOSS_ENC * crate_mult)
	local room_origin = GameRules.Aghanim:GetCurrentRoom():GetOrigin() + Vector(250,250,0)
	room_origin.z = 0
	
	for i=1,crate_count do
		local loc = FindPathablePositionNearby(room_origin, 200, 20000 )					
		local crate = CreateUnitByName( "pf_crate", loc, true, nil, nil, DOTA_TEAM_BADGUYS )
		crate:AddNewModifier(nil, nil, "modifier_drop_potion_on_death", {})		
	end	
	--welcome back, im in the middle of making crate actually drop something, then it's debuffing rooms for lower difficulty, then add Isupport into the patron list
end


function CMapEncounter_PathfinderFrostBoss:OnThink()
	CMapEncounter_BossBase.OnThink( self )
end


--------------------------------------------------------------------------------

function CMapEncounter_PathfinderFrostBoss:GetPreviewUnit()
	return "pathfinder_frost_boss"
end

--------------------------------------------------------------------------------

function CMapEncounter_PathfinderFrostBoss:GetBossIntroGesture()
	return ACT_DOTA_VICTORY
end

--------------------------------------------------------------------------------

function CMapEncounter_PathfinderFrostBoss:GetBossIntroCameraPitch()
	return 40
end

--------------------------------------------------------------------------------

function CMapEncounter_PathfinderFrostBoss:GetBossIntroCameraDistance()
	return 700
end

--------------------------------------------------------------------------------

function CMapEncounter_PathfinderFrostBoss:GetBossIntroCameraHeight()
	return 100
end

--------------------------------------------------------------------------------

function CMapEncounter_PathfinderFrostBoss:GetBossIntroCameraYawRotateSpeed()
	return 0.1
end

--------------------------------------------------------------------------------

function CMapEncounter_PathfinderFrostBoss:GetBossIntroCameraInitialYaw()
	return 120
end

--------------------------------------------------------------------------------

function CMapEncounter_PathfinderFrostBoss:GetBossIntroDuration()
	return 3.5
end

--------------------------------------------------------------------------------

function CMapEncounter_PathfinderFrostBoss:IntroduceBoss( hEncounteredBoss )
	CMapEncounter_BossBase.IntroduceBoss( self, hEncounteredBoss )

	EmitGlobalSound( "night_stalker_nstalk_battlebegins_01" )
end

--------------------------------------------------------------------------------
function CMapEncounter_PathfinderFrostBoss:GetLaughLine()

	local szLines = 
	{
		"night_stalker_nstalk_deny_03",				
		"night_stalker_nstalk_laugh_05",
		"night_stalker_nstalk_laugh_09",
		"night_stalker_nstalk_level_01",

		"night_stalker_nstalk_attack_02",
		"night_stalker_nstalk_attack_03",
		"night_stalker_nstalk_attack_04",
		"night_stalker_nstalk_attack_05",
		"night_stalker_nstalk_attack_06",
		"night_stalker_nstalk_attack_07",
		"night_stalker_nstalk_attack_08",
		"night_stalker_nstalk_attack_09",
		"night_stalker_nstalk_attack_11",
		"night_stalker_nstalk_attack_12",

		"night_stalker_nstalk_rare_01",
		"night_stalker_nstalk_rare_02",

		"night_stalker_nstalk_ability_cripfear_02",

		"night_stalker_nstalk_respawn_01",
		"night_stalker_nstalk_respawn_02",
		"night_stalker_nstalk_respawn_05",
		"night_stalker_nstalk_respawn_07",
		"night_stalker_nstalk_respawn_08",
		"night_stalker_nstalk_respawn_10",

		"night_stalker_nstalk_spawn_02",

		"night_stalker_nstalk_move_08",
		"night_stalker_nstalk_move_13",	
	}

	return szLines[ RandomInt( 1, #szLines ) ]
end

---------------------------------------------------------- ----------------------

function CMapEncounter_PathfinderFrostBoss:GetKillTauntLine(victim)
	local szLines = 
	{
		"night_stalker_nstalk_inthebag_01",
		"night_stalker_nstalk_kill_02",
		"night_stalker_nstalk_kill_03",
		"night_stalker_nstalk_kill_04",
		"night_stalker_nstalk_kill_05",
		"night_stalker_nstalk_kill_07",
		"night_stalker_nstalk_kill_08",
		"night_stalker_nstalk_kill_09",
		"night_stalker_nstalk_kill_10",
		"night_stalker_nstalk_kill_11",
		"night_stalker_nstalk_kill_12",		
		"night_stalker_nstalk_killspecial_02",	
		"night_stalker_nstalk_ability_dark_01",	
		"night_stalker_nstalk_ability_dark_07",

		"night_stalker_nstalk_ability_dark_11",	
	}

	return szLines[ RandomInt( 1, #szLines ) ]
end

--------------------------------------------------------------------------------

function CMapEncounter_PathfinderFrostBoss:GetAbilityUseLine( szAbilityName )
	local szLineToUse = self:GetLaughLine()
	if szAbilityName == "frost_boss_nova" then
		local szLines = 
		{
			"night_stalker_nstalk_ability_dark_05",												
		}
		szLineToUse = szLines[ RandomInt( 1, #szLines ) ]
	end

	if szAbilityName == "frost_boss_pull" then
		local szLines = 
		{
			"night_stalker_nstalk_ability_dark_08",
			"night_stalker_nstalk_ability_dark_09",						
		}
		szLineToUse = szLines[ RandomInt( 1, #szLines ) ]
	end

	if szAbilityName == "frost_boss_massive_nova" then
		local szLines = 
		{					
			"night_stalker_nstalk_ability_dark_10",
		}
		szLineToUse = szLines[ RandomInt( 1, #szLines ) ]
	end

	if szAbilityName == "frost_boss_creeper" then
		local szLines = 
		{			
			"night_stalker_nstalk_spawn_05",										
		}
		szLineToUse = szLines[ RandomInt( 1, #szLines ) ]
	end
	return szLineToUse
end


return CMapEncounter_PathfinderFrostBoss
