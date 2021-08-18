modifier_speaker = class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,
	RemoveOnDeath 			= function(self) return false end,
	AllowIllusionDuplicate	= function(self) return false end
})

require("utility_functions")
require("libraries.has_shard")
require("libraries.timers")
--------------------------------------------------------------------------------
function modifier_speaker:split(s, sep)
    local fields = {}
    
    local sep = sep or " "
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)
    
    return fields
end

function modifier_speaker:OnCreated(table)
	if not IsServer() then return end
	ListenToGameEvent("dota_player_begin_cast", Dynamic_Wrap(modifier_speaker, 'OnAbilityUsed'), self)

	self.lines = {
		jakiro_dual_breath_lua = {
			"jakiro_jak_ability_dual_01",
			"jakiro_jak_ability_dual_02",
			"jakiro_jak_ability_dual_03",
			"jakiro_jak_ability_dual_04",
			"jakiro_jak_ability_dual_05",
			"jakiro_jak_ability_dual_06",
			"jakiro_jak_ability_dual_07",
		},		
		jakiro_ice_path_lua = {
			"jakiro_jak_ability_icepath_01",
			"jakiro_jak_ability_icepath_02",
			"jakiro_jak_ability_icepath_03",

		},
		jakiro_liquid_fire_lua = {
			"jakiro_jak_ability_liquid_01",
			"jakiro_jak_ability_liquid_02",
			"jakiro_jak_ability_liquid_03",
			"jakiro_jak_ability_liquid_04",

		},
		jakiro_macropyre_lua = {
			"jakiro_jak_ability_macro_01",
			"jakiro_jak_ability_macro_02",
			"jakiro_jak_ability_macro_03",
			"jakiro_jak_ability_macro_04",

		},
		pathfinder_nevermore_shadowraze_near = {
			"nevermore_nev_ability_shadow_01",
			"nevermore_nev_ability_shadow_02",
			"nevermore_nev_ability_shadow_03",
			"nevermore_nev_ability_shadow_04",
			"nevermore_nev_ability_shadow_05",
			"nevermore_nev_ability_shadow_06",
			"nevermore_nev_ability_shadow_07",
			"nevermore_nev_ability_shadow_08",
			"nevermore_nev_ability_shadow_09",
			"nevermore_nev_ability_shadow_10",
			"nevermore_nev_ability_shadow_11",
			"nevermore_nev_ability_shadow_12",
			"nevermore_nev_ability_shadow_13",
			"nevermore_nev_ability_shadow_14",
			"nevermore_nev_ability_shadow_15",
			"nevermore_nev_ability_shadow_16",
			"nevermore_nev_ability_shadow_17",
			"nevermore_nev_ability_shadow_18",
			"nevermore_nev_ability_shadow_19",
			"nevermore_nev_ability_shadow_20",
			"nevermore_nev_ability_shadow_21",
			"nevermore_nev_ability_shadow_22",
			"nevermore_nev_ability_shadow_23",
			"nevermore_nev_ability_shadow_24",
			"nevermore_nev_ability_shadow_25",
		},
		pathfinder_nevermore_shadowraze_medium = {
			"nevermore_nev_ability_shadow_01",
			"nevermore_nev_ability_shadow_02",
			"nevermore_nev_ability_shadow_03",
			"nevermore_nev_ability_shadow_04",
			"nevermore_nev_ability_shadow_05",
			"nevermore_nev_ability_shadow_06",
			"nevermore_nev_ability_shadow_07",
			"nevermore_nev_ability_shadow_08",
			"nevermore_nev_ability_shadow_09",
			"nevermore_nev_ability_shadow_10",
			"nevermore_nev_ability_shadow_11",
			"nevermore_nev_ability_shadow_12",
			"nevermore_nev_ability_shadow_13",
			"nevermore_nev_ability_shadow_14",
			"nevermore_nev_ability_shadow_15",
			"nevermore_nev_ability_shadow_16",
			"nevermore_nev_ability_shadow_17",
			"nevermore_nev_ability_shadow_18",
			"nevermore_nev_ability_shadow_19",
			"nevermore_nev_ability_shadow_20",
			"nevermore_nev_ability_shadow_21",
			"nevermore_nev_ability_shadow_22",
			"nevermore_nev_ability_shadow_23",
			"nevermore_nev_ability_shadow_24",
			"nevermore_nev_ability_shadow_25",
		},
		pathfinder_nevermore_shadowraze_far = {
			"nevermore_nev_ability_shadow_01",
			"nevermore_nev_ability_shadow_02",
			"nevermore_nev_ability_shadow_03",
			"nevermore_nev_ability_shadow_04",
			"nevermore_nev_ability_shadow_05",
			"nevermore_nev_ability_shadow_06",
			"nevermore_nev_ability_shadow_07",
			"nevermore_nev_ability_shadow_08",
			"nevermore_nev_ability_shadow_09",
			"nevermore_nev_ability_shadow_10",
			"nevermore_nev_ability_shadow_11",
			"nevermore_nev_ability_shadow_12",
			"nevermore_nev_ability_shadow_13",
			"nevermore_nev_ability_shadow_14",
			"nevermore_nev_ability_shadow_15",
			"nevermore_nev_ability_shadow_16",
			"nevermore_nev_ability_shadow_17",
			"nevermore_nev_ability_shadow_18",
			"nevermore_nev_ability_shadow_19",
			"nevermore_nev_ability_shadow_20",
			"nevermore_nev_ability_shadow_21",
			"nevermore_nev_ability_shadow_22",
			"nevermore_nev_ability_shadow_23",
			"nevermore_nev_ability_shadow_24",
			"nevermore_nev_ability_shadow_25",
		},
		pathfinder_nevermore_necromastery = {
			"nevermore_nev_ability_mastery_01",			
		},
		pathfinder_nevermore_dark_lord = {
			"nevermore_nev_ability_presence_01",	
			"nevermore_nev_ability_presence_02",		
			"nevermore_nev_ability_presence_03",
		},
		pathfinder_nevermore_requiem = {
			"nevermore_nev_ability_requiem_01",	
			"nevermore_nev_ability_requiem_02",		
			"nevermore_nev_ability_requiem_03",
			"nevermore_nev_ability_requiem_04",
			"nevermore_nev_ability_requiem_05",
			"nevermore_nev_ability_requiem_06",
			"nevermore_nev_ability_requiem_07",
			"nevermore_nev_ability_requiem_08",

			"nevermore_nev_ability_requiem_11",
			"nevermore_nev_ability_requiem_12",
			"nevermore_nev_ability_requiem_13",
			"nevermore_nev_ability_requiem_14",
		},
		axe_berserkers_call_lua = {
			"axe_axe_ability_berserk_01",	
			"axe_axe_ability_berserk_02",		
			"axe_axe_ability_berserk_03",
			"axe_axe_ability_berserk_04",
			"axe_axe_ability_berserk_05",
			"axe_axe_ability_berserk_06",
			"axe_axe_ability_berserk_07",
			"axe_axe_ability_berserk_08",
			"axe_axe_ability_berserk_09",
		},
		axe_battle_hunger_lua = {
			"axe_axe_ability_battlehunger_01",
			"axe_axe_ability_battlehunger_02",
			"axe_axe_ability_battlehunger_03",
		},
		axe_culling_blade_lua = {
			"axe_axe_ability_cullingblade_01",
			"axe_axe_ability_cullingblade_02",			
		},
		ogre_magi_fireblast_lua = {
			"ogre_magi_ogmag_ability_firebl_01",
			"ogre_magi_ogmag_ability_firebl_02",
			"ogre_magi_ogmag_ability_firebl_03",		
		},
		ogre_magi_ignite_lua = {
			"ogre_magi_ogmag_ability_ignite_01",
			"ogre_magi_ogmag_ability_ignite_02",
			"ogre_magi_ogmag_ability_ignite_03",						
		},
		ogre_magi_bloodlust_lua = {
			"ogre_magi_ogmag_ability_bloodlust_01",
			"ogre_magi_ogmag_ability_bloodlust_02",
			"ogre_magi_ogmag_ability_bloodlust_03",
			"ogre_magi_ogmag_ability_bloodlust_04",
		},
		ogre_magi_multicast_lua = {
			"ogre_magi_ogmag_ability_multi_hit_01",
			"ogre_magi_ogmag_ability_multi_hit_02",
			"ogre_magi_ogmag_ability_multi_hit_03",
			"ogre_magi_ogmag_ability_multi_hit_04",
			"ogre_magi_ogmag_ability_multi_hit_05",
			"ogre_magi_ogmag_ability_multi_hit_06",
			"ogre_magi_ogmag_ability_multi_hit_07",
			"ogre_magi_ogmag_ability_multi_hit_08",
			"ogre_magi_ogmag_ability_multi_hit_09",
			"ogre_magi_ogmag_ability_multi_hit_10",
			"ogre_magi_ogmag_ability_multi_hit_11",
			"ogre_magi_ogmag_ability_multi_hit_12",
			"ogre_magi_ogmag_ability_multi_hit_13",
			"ogre_magi_ogmag_ability_multi_hit_14",
			"ogre_magi_ogmag_ability_multi_hit_15",
			"ogre_magi_ogmag_ability_multi_hit_16",
			"ogre_magi_ogmag_ability_multi_hit_17",
			"ogre_magi_ogmag_ability_multi_hit_18",
			"ogre_magi_ogmag_ability_multi_hit_19",
			"ogre_magi_ogmag_ability_multi_hit_20",
		},
		pathfinder_lc_arrows = {
			"legion_commander_legcom_overwhelmingodds_01",
			"legion_commander_legcom_overwhelmingodds_02",
			"legion_commander_legcom_overwhelmingodds_03",
			"legion_commander_legcom_overwhelmingodds_04",
		},
		pathfinder_lc_press = {
			"legion_commander_legcom_presstheattack_01",
			"legion_commander_legcom_presstheattack_02",
			"legion_commander_legcom_presstheattack_03",
			"legion_commander_legcom_presstheattack_04",
			"legion_commander_legcom_presstheattack_05",
			"legion_commander_legcom_presstheattack_06",

			"legion_commander_legcom_presstheattack_08",
			"legion_commander_legcom_presstheattack_09",
		},
		pathfinder_lc_moment = {
			"legion_commander_legcom_momentofcourage_01",
			"legion_commander_legcom_momentofcourage_02",
			"legion_commander_legcom_momentofcourage_03",
		},
		pathfinder_lc_duel = {
			"legion_commander_legcom_duel_01",
			"legion_commander_legcom_duel_02",
			"legion_commander_legcom_duel_03",
			"legion_commander_legcom_duel_04",
			"legion_commander_legcom_duel_05",
			"legion_commander_legcom_duel_06",
			"legion_commander_legcom_duel_07",
			"legion_commander_legcom_duel_08",
			"legion_commander_legcom_duel_09",

			"legion_commander_legcom_duelhero_01",
			"legion_commander_legcom_duelhero_02",
			"legion_commander_legcom_duelhero_03",

			"legion_commander_legcom_duelhero_05",
			"legion_commander_legcom_duelhero_06",
			"legion_commander_legcom_duelhero_07",
			"legion_commander_legcom_duelhero_08",
			"legion_commander_legcom_duelhero_09",
			"legion_commander_legcom_duelhero_10",
			"legion_commander_legcom_duelhero_11",
			"legion_commander_legcom_duelhero_12",
			"legion_commander_legcom_duelhero_13",
			"legion_commander_legcom_duelhero_14",
			"legion_commander_legcom_duelhero_15",
			"legion_commander_legcom_duelhero_16",
			"legion_commander_legcom_duelhero_17",
			"legion_commander_legcom_duelhero_18",

			"legion_commander_legcom_duelhero_20",
			"legion_commander_legcom_duelhero_21",
			"legion_commander_legcom_duelhero_22",
			"legion_commander_legcom_duelhero_23",
			"legion_commander_legcom_duelhero_24",
			"legion_commander_legcom_duelhero_25",
			"legion_commander_legcom_duelhero_26",

			"legion_commander_legcom_duelhero_28",
			"legion_commander_legcom_duelhero_29",

			"legion_commander_legcom_duelhero_30",

			"legion_commander_legcom_duelhero_32",
			"legion_commander_legcom_duelhero_33",

			"legion_commander_legcom_duelhero_35",
			"legion_commander_legcom_duelhero_36",
		},
		windranger_shackleshot_lua = {
			"windrunner_wind_ability_shackleshot_01",
			"windrunner_wind_ability_shackleshot_02",
			"windrunner_wind_ability_shackleshot_03",
			"windrunner_wind_ability_shackleshot_04",
			"windrunner_wind_ability_shackleshot_05",
			"windrunner_wind_ability_shackleshot_06",
			"windrunner_wind_ability_shackleshot_07",
			"windrunner_wind_ability_shackleshot_08",
			"windrunner_wind_ability_shackleshot_09",
			"windrunner_wind_ability_shackleshot_10",
		},
		windranger_powershot_lua = {
			"windrunner_wind_ability_powershot_01",
			"windrunner_wind_ability_powershot_02",
			"windrunner_wind_ability_powershot_03",
			"windrunner_wind_ability_powershot_04",

			"windrunner_wind_ability_powershot_06",
			"windrunner_wind_ability_powershot_07",			
		},
		windranger_windrun_lua = {
			"windrunner_wind_ability_windrun_01",
			"windrunner_wind_ability_windrun_02",
			"windrunner_wind_ability_windrun_03",
		},
		windranger_focus_fire_lua = {
			"windrunner_wind_ability_focusfire_01",
			"windrunner_wind_ability_focusfire_02",
			"windrunner_wind_ability_focusfire_03",
			"windrunner_wind_ability_focusfire_04",
		},

		phantom_assassin_stifling_dagger_lua = {
			"phantom_assassin_phass_ability_stiflingdagger_01",
			"phantom_assassin_phass_ability_stiflingdagger_02",
			"phantom_assassin_phass_ability_stiflingdagger_03",
			"phantom_assassin_phass_ability_stiflingdagger_04",
		},
		phantom_assassin_phantom_strike_lua = {
			"phantom_assassin_phass_ability_phantomstrike_01",
			"phantom_assassin_phass_ability_phantomstrike_02",
			"phantom_assassin_phass_ability_phantomstrike_03",
			"phantom_assassin_phass_ability_phantomstrike_04",
		},
		phantom_assassin_blur_lua = {
			"phantom_assassin_phass_ability_blur_01",
			"phantom_assassin_phass_ability_blur_02",
			"phantom_assassin_phass_ability_blur_03",
		},
		phantom_assassin_coup_de_grace_lua = {
			"phantom_assassin_phass_ability_coupdegrace_01",
			"phantom_assassin_phass_ability_coupdegrace_02",
			"phantom_assassin_phass_ability_coupdegrace_03",
			"phantom_assassin_phass_ability_coupdegrace_04",
		},

		pathfinder_juggernaut_blade_fury = {
			"juggernaut_jug_ability_bladefury_02",
			"juggernaut_jug_ability_bladefury_03",

			"juggernaut_jug_ability_bladefury_05",
			"juggernaut_jug_ability_bladefury_06",
			"juggernaut_jug_ability_bladefury_07",
			"juggernaut_jug_ability_bladefury_08",
			"juggernaut_jug_ability_bladefury_09",

			"juggernaut_jugsc_arc_ability_immunity_01",
			"juggernaut_jugsc_arc_ability_immunity_02",
			"juggernaut_jugsc_arc_ability_immunity_03",
		},
		pathfinder_juggernaut_omni_slash = {
			"juggernaut_jug_ability_omnislash_01",
			"juggernaut_jug_ability_omnislash_02",
			"juggernaut_jug_ability_omnislash_03",
			"juggernaut_jug_ability_omnislash_04",
			"juggernaut_jug_ability_omnislash_05",
			"juggernaut_jug_ability_omnislash_06",
			"juggernaut_jug_ability_omnislash_07",
			"juggernaut_jug_ability_omnislash_08",
			"juggernaut_jug_ability_omnislash_09",

			"juggernaut_jug_ability_omnislash_10",
			"juggernaut_jug_ability_omnislash_11",
			"juggernaut_jug_ability_omnislash_12",
			"juggernaut_jug_ability_omnislash_13",
			"juggernaut_jug_ability_omnislash_14",
			"juggernaut_jug_ability_omnislash_15",
			"juggernaut_jug_ability_omnislash_16",
			"juggernaut_jug_ability_omnislash_17",
			"juggernaut_jug_ability_omnislash_18",
			"juggernaut_jug_ability_omnislash_19",

			"juggernaut_jug_ability_omnislash_20",
			"juggernaut_jug_ability_omnislash_21",
			"juggernaut_jug_ability_omnislash_22",
			"juggernaut_jug_ability_omnislash_23",
			"juggernaut_jug_ability_omnislash_24",
			"juggernaut_jug_ability_omnislash_25",
			"juggernaut_jug_ability_omnislash_26",
			"juggernaut_jug_ability_omnislash_27",
			"juggernaut_jug_ability_omnislash_28",
			"juggernaut_jug_ability_omnislash_29",

			"juggernaut_jug_ability_omnislash_30",
			"juggernaut_jug_ability_omnislash_31",
			"juggernaut_jug_ability_omnislash_32",
			"juggernaut_jug_ability_omnislash_33",
			"juggernaut_jug_ability_omnislash_34",

		},
		venomancer_venomous_gale_datadriven = {
			"Hero_Venomancer.VenomousGale" --we have to play the sound effect here because this is a shitty datadriven ability
		},

		venomancer_plague_ward_datadriven = {
			"venomancer_venm_ability_ward_01",
			"venomancer_venm_ability_ward_02",
			"venomancer_venm_ability_ward_03",
			"venomancer_venm_ability_ward_04",
			"venomancer_venm_ability_ward_05",
			"venomancer_venm_ability_ward_06",
		},
		venomancer_poison_nova_datadriven = {
			"venomancer_venm_ability_nova_01",
			"venomancer_venm_ability_nova_02",
			"venomancer_venm_ability_nova_03",
			"venomancer_venm_ability_nova_04",
			"venomancer_venm_ability_nova_05",
			"venomancer_venm_ability_nova_06",
			"venomancer_venm_ability_nova_07",
			"venomancer_venm_ability_nova_08",
			"venomancer_venm_ability_nova_09",

			"venomancer_venm_ability_nova_10",
			"venomancer_venm_ability_nova_11",
			"venomancer_venm_ability_nova_12",
			"venomancer_venm_ability_nova_13",
			"venomancer_venm_ability_nova_14",
			"venomancer_venm_ability_nova_15",
			"venomancer_venm_ability_nova_16",
			"venomancer_venm_ability_nova_17",
			"venomancer_venm_ability_nova_18",
			"venomancer_venm_ability_nova_19",

			"venomancer_venm_ability_nova_20",
			"venomancer_venm_ability_nova_21",
		},
		tidehunter_gush_pf = {
			"tidehunter_tide_ability_gush_01",
			"tidehunter_tide_ability_gush_02",
			"tidehunter_tide_cast_01",
			"tidehunter_tide_cast_02",
		},
		tidehunter_anchor_smash_pf = {
			"tidehunter_tide_attack_01",
			"tidehunter_tide_attack_02",
			"tidehunter_tide_attack_03",
			"tidehunter_tide_attack_04",
			"tidehunter_tide_attack_05",
			"tidehunter_tide_attack_06",
			"tidehunter_tide_attack_07",
			"tidehunter_tide_attack_08",
			"tidehunter_tide_attack_09",
			"tidehunter_tide_attack_10",
			"tidehunter_tide_attack_11",
		},
		tidehunter_ravage_pf = {
			"tidehunter_tide_ability_ravage_01",
			"tidehunter_tide_ability_ravage_02",
		},
		tidehunter_pf_crunch = {
			"tidehunter_tide_deny_05",
			"tidehunter_tide_deny_06",
			"tidehunter_tide_firstblood_01",			
			"tidehunter_tide_kill_04",
			"tidehunter_tide_kill_07",
			"tidehunter_tide_kill_08",
			"tidehunter_tide_kill_12",

			"tidehunter_tide_level_01",
			"tidehunter_tide_level_02",
			"tidehunter_tide_level_03",
			"tidehunter_tide_level_04",
			"tidehunter_tide_level_05",
			"tidehunter_tide_level_06",
			"tidehunter_tide_level_07",
			"tidehunter_tide_level_08",
			"tidehunter_tide_level_09",

			"tidehunter_tide_level_10",
			"tidehunter_tide_level_11",
			"tidehunter_tide_level_12",
			"tidehunter_tide_level_13",
			"tidehunter_tide_level_14",
			"tidehunter_tide_level_15",
			"tidehunter_tide_level_16",
			"tidehunter_tide_level_17",
			"tidehunter_tide_level_18",
			"tidehunter_tide_level_19",

			"tidehunter_tide_level_20",
			"tidehunter_tide_level_21",
			"tidehunter_tide_level_22",
			"tidehunter_tide_level_23",
			"tidehunter_tide_level_24",
		},
		pathfinder_dk_breathe_fire = {
			"dragon_knight_drag_ability_eldrag_03",
			"dragon_knight_drag_ability_eldrag_05",
			"dragon_knight_drag_anger_02",
			"dragon_knight_drag_anger_03",
			"dragon_knight_drag_anger_04",
			"dragon_knight_dragon_kill_07",
		},
		pathfinder_dk_dragon_tail = {
			"dragon_knight_drag_ability_eldrag_04",
			"dragon_knight_drag_ability_eldrag_06",

			"dragon_knight_dragon_cast_01",
			"dragon_knight_dragon_cast_02",
			"dragon_knight_dragon_kill_02",
			"dragon_knight_dragon_kill_03",
			"dragon_knight_dragon_kill_05",
		},
		pathfinder_dk_elder_dragon_form = {
			"dragon_knight_dragon_ability_eldrag_01",
			"dragon_knight_dragon_ability_eldrag_03",
			"dragon_knight_dragon_ability_eldrag_04",
			"dragon_knight_dragon_ability_eldrag_05",
			"dragon_knight_dragon_ability_eldrag_06",
		},

		dawnbreaker_starbreaker_lua = {
			"dawnbreaker_valora_hammer_01",
			"dawnbreaker_valora_hammer_02_02",
			"dawnbreaker_valora_hammer_03",
			"dawnbreaker_valora_hammer_04",
			"dawnbreaker_valora_hammer_05",
			"dawnbreaker_valora_hammer_06",
			"dawnbreaker_valora_hammer_07",
			"dawnbreaker_valora_hammer_08",
			"dawnbreaker_valora_hammer_09",
			"dawnbreaker_valora_hammer_10",
			"dawnbreaker_valora_hammer_11",
			"dawnbreaker_valora_hammer_12",
		},

		dawnbreaker_celestial_hammer_lua = {
			"dawnbreaker_valora_punch_03",
			"dawnbreaker_valora_punch_04",
			"dawnbreaker_valora_throw_01",
			"dawnbreaker_valora_throw_02",
			"dawnbreaker_valora_throw_03",
			"dawnbreaker_valora_throw_04",
			"dawnbreaker_valora_throw_05",
			"dawnbreaker_valora_throw_06",
			"dawnbreaker_valora_throw_07",
			"dawnbreaker_valora_throw_08",
			"dawnbreaker_valora_throw_09",
			"dawnbreaker_valora_throw_10",
		},

		dawnbreaker_luminosity_lua = {
			"dawnbreaker_valora_punch_04",
			"dawnbreaker_valora_punch_05",
			"dawnbreaker_valora_punch_06",
			"dawnbreaker_valora_punch_07",
		},

		dawnbreaker_solar_guardian_lua_permanent = {
			"dawnbreaker_valora_intro_01_02",
			"dawnbreaker_valora_spawn_24",
			"dawnbreaker_valora_intro_11",
			"dawnbreaker_valora_spawn_20",
		},

		pf_poison_touch = {
			"dazzle_dazz_ability_poistouch_01",
			"dazzle_dazz_ability_poistouch_02",
			"dazzle_dazz_ability_poistouch_03",
			"dazzle_dazz_cast_01",
			"dazzle_dazz_cast_02",
			"dazzle_dazz_cast_03",
		},
		pf_shallow_grave = {
			"dazzle_dazz_ability_shalgrave_01",
			"dazzle_dazz_ability_shalgrave_02",
			"dazzle_dazz_ability_shalgrave_03",
			"dazzle_dazz_ability_shalgrave_04",
			"dazzle_dazz_ability_shalgrave_05",
			"dazzle_dazz_ability_shalgrave_06",
			"dazzle_dazz_ability_shalgrave_07",
			"dazzle_dazz_ability_shalgrave_08",
			"dazzle_dazz_ability_shalgrave_09",
			"dazzle_dazz_ability_shalgrave_10",
		},
		pf_shadow_wave = {
			"dazzle_dazz_ability_shadowave_01",
			"dazzle_dazz_ability_shadowave_02",
			"dazzle_dazz_ability_shadowave_03",
			"dazzle_dazz_ability_shadowave_04",
			"dazzle_dazz_ability_shadowave_05",
			"dazzle_dazz_ability_shadowave_06",
			"dazzle_dazz_ability_shadowave_07",
			"dazzle_dazz_ability_shadowave_08",
			"dazzle_dazz_ability_shadowave_09",
			"dazzle_dazz_ability_shadowave_10",
			"dazzle_dazz_ability_shadowave_11",
			"dazzle_dazz_ability_shadowave_12",
		},

		
	}
end

function modifier_speaker:OnAbilityUsed(kv)
	if not IsServer() then return end
	if self:GetParent():GetPlayerOwnerID() == kv.PlayerID then
		local sounds = self.lines[kv.abilityname]
		if sounds then
			-- Timers:CreateTimer(2, function()
				-- self:GetParent():EmitSoundParams(sounds[RandomInt(1, #sounds)],100,10.0,0.0)				
				self:GetParent():EmitSound(sounds[RandomInt(1, #sounds)])				
			-- end)
		end
	end	
end


