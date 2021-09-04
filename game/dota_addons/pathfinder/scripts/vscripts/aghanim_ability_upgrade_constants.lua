LinkLuaModifier( "modifier_minor_ability_upgrades", "modifiers/modifier_minor_ability_upgrades", LUA_MODIFIER_MOTION_NONE )

_G.MINOR_ABILITY_UPGRADE_OP_ADD = 1
_G.MINOR_ABILITY_UPGRADE_OP_MUL = 2

_G.MINOR_ABILITY_UPGRADES =
{
   npc_dota_hero_magnataur = require( "minor_ability_upgrades/minor_ability_upgrades_magnataur" ),
   npc_dota_hero_phantom_assassin = require( "minor_ability_upgrades/minor_ability_upgrades_phantom_assassin" ),
   npc_dota_hero_snapfire = require( "minor_ability_upgrades/minor_ability_upgrades_snapfire" ),
   npc_dota_hero_disruptor = require( "minor_ability_upgrades/minor_ability_upgrades_disruptor" ),
   npc_dota_hero_winter_wyvern = require( "minor_ability_upgrades/minor_ability_upgrades_winter_wyvern" ),
   npc_dota_hero_tusk = require( "minor_ability_upgrades/minor_ability_upgrades_tusk" ),
   npc_dota_hero_ursa = require( "minor_ability_upgrades/minor_ability_upgrades_ursa" ),
   npc_dota_hero_sniper = require( "minor_ability_upgrades/minor_ability_upgrades_sniper" ),
   npc_dota_hero_mars = require( "minor_ability_upgrades/minor_ability_upgrades_mars" ),
   npc_dota_hero_viper = require( "minor_ability_upgrades/minor_ability_upgrades_viper" ),
   npc_dota_hero_weaver = require( "minor_ability_upgrades/minor_ability_upgrades_weaver" ),
   npc_dota_hero_omniknight = require( "minor_ability_upgrades/minor_ability_upgrades_omniknight" ),
   npc_dota_hero_witch_doctor = require( "minor_ability_upgrades/minor_ability_upgrades_witch_doctor" ),
   npc_dota_hero_templar_assassin = require( "minor_ability_upgrades/minor_ability_upgrades_templar_assassin" ),
   npc_dota_hero_slark = require( "minor_ability_upgrades/minor_ability_upgrades_slark" ),
   npc_dota_hero_queenofpain = require( "minor_ability_upgrades/minor_ability_upgrades_queenofpain" ),
   npc_dota_hero_juggernaut = require( "minor_ability_upgrades/minor_ability_upgrades_juggernaut" ),
   npc_dota_hero_venomancer = require( "minor_ability_upgrades/minor_ability_upgrades_venomancer" ),
   npc_dota_hero_windrunner = require( "minor_ability_upgrades/minor_ability_upgrades_windrunner" ),
   npc_dota_hero_legion_commander = require( "minor_ability_upgrades/minor_ability_upgrades_legion_commander" ),
   npc_dota_hero_ogre_magi = require( "minor_ability_upgrades/minor_ability_upgrades_ogre_magi" ),
   npc_dota_hero_nevermore = require( "minor_ability_upgrades/minor_ability_upgrades_nevermore" ),
   npc_dota_hero_axe = require( "minor_ability_upgrades/minor_ability_upgrades_axe" ),
   npc_dota_hero_jakiro = require( "minor_ability_upgrades/minor_ability_upgrades_jakiro" ),
   npc_dota_hero_tidehunter = require( "minor_ability_upgrades/minor_ability_upgrades_tidehunter" ),
   npc_dota_hero_hoodwink = require( "minor_ability_upgrades/minor_ability_upgrades_hoodwink" ),
   npc_dota_hero_phoenix = require( "minor_ability_upgrades/minor_ability_upgrades_phoenix" ),
   npc_dota_hero_dragon_knight = require( "minor_ability_upgrades/minor_ability_upgrades_dragon_knight" ),
   npc_dota_hero_dawnbreaker = require( "minor_ability_upgrades/minor_ability_upgrades_dawnbreaker" ),
   npc_dota_hero_dazzle = require( "minor_ability_upgrades/minor_ability_upgrades_dazzle" ),
   npc_dota_hero_pangolier = require( "minor_ability_upgrades/minor_ability_upgrades_pangolier" ),
   --non hero specific upgrades (bonus HP/mana/damage/etc.)
   base_stats_upgrades = require( "minor_ability_upgrades/base_minor_stats_upgrades" ),
}

_G.STAT_UPGRADE_EXCLUDES =
{
   npc_dota_hero_omniknight =
   {
      "aghsfort_minor_stat_upgrade_bonus_attack_speed",
   },

   npc_dota_hero_magnataur = 
   {
      "aghsfort_minor_stat_upgrade_bonus_health",
   },
   
   npc_dota_hero_winter_wyvern = 
   {
      "aghsfort_minor_stat_upgrade_bonus_evasion",
   },

   npc_dota_hero_disruptor =
   {
      "aghsfort_minor_stat_upgrade_bonus_evasion",
   },

   npc_dota_hero_snapfire = 
   {
      "aghsfort_minor_stat_upgrade_bonus_evasion",
   },

   npc_dota_hero_tusk = 
   {
      "aghsfort_minor_stat_upgrade_bonus_health",
   },

   npc_dota_hero_ursa = 
   {
      "aghsfort_minor_stat_upgrade_bonus_spell_amp",
   },

   npc_dota_hero_sniper = 
   {
      "aghsfort_minor_stat_upgrade_bonus_evasion",
   },

   npc_dota_hero_mars = 
   {
      "aghsfort_minor_stat_upgrade_bonus_health",
   },

   npc_dota_hero_viper = 
   {
      "aghsfort_minor_stat_upgrade_bonus_magic_resist",
   },

   npc_dota_hero_weaver = 
   {
      "aghsfort_minor_stat_upgrade_bonus_spell_amp",
   },

   npc_dota_hero_witch_doctor = 
   {
      "aghsfort_minor_stat_upgrade_bonus_attack_damage",
      "aghsfort_minor_stat_upgrade_bonus_evasion",
      "aghsfort_minor_stat_upgrade_bonus_attack_speed",
   },

   npc_dota_hero_queenofpain = 
   {
   },

   npc_dota_hero_templar_assassin = 
   {
   },

   npc_dota_hero_slark = 
   {
   },
   
   npc_dota_hero_juggernaut = 
   {
      "aghsfort_minor_stat_upgrade_bonus_spell_amp",
   },
   npc_dota_hero_venomancer= 
   {
      "aghsfort_minor_stat_upgrade_bonus_evasion",
   },
   npc_dota_hero_windrunner= 
   {
      "aghsfort_minor_stat_upgrade_bonus_evasion",
   },
   npc_dota_hero_phantom_assassin= 
   {
      "aghsfort_minor_stat_upgrade_bonus_evasion",
      "aghsfort_minor_stat_upgrade_bonus_spell_amp",
   },
   npc_dota_hero_legion_commander= 
   {      
      "aghsfort_minor_stat_upgrade_bonus_spell_amp",
   },
   npc_dota_hero_ogre_magi=
   {
      "aghsfort_minor_stat_upgrade_bonus_evasion",      
      "aghsfort_minor_stat_upgrade_bonus_attack_speed",
   },
   npc_dota_hero_nevermore=
   {
      
   },
   npc_dota_hero_axe=
   {
      "aghsfort_minor_stat_upgrade_bonus_attack_damage",
      "aghsfort_minor_stat_upgrade_bonus_evasion",
      "aghsfort_minor_stat_upgrade_bonus_attack_speed",
   },
    npc_dota_hero_jakiro=
   {
      "aghsfort_minor_stat_upgrade_bonus_attack_damage",      
      "aghsfort_minor_stat_upgrade_bonus_attack_speed",
   },
   npc_dota_hero_tidehunter=
   {      
      "aghsfort_minor_stat_upgrade_bonus_evasion",
   },
   npc_dota_hero_hoodwink=
   {      
      
   },

   npc_dota_hero_phoenix=
   {      
      "aghsfort_minor_stat_upgrade_bonus_attack_speed",
   },

   npc_dota_hero_dragon_knight =
   {      
      "aghsfort_minor_stat_upgrade_bonus_evasion",
   },

   npc_dota_hero_dawnbreaker =
   {      
      "aghsfort_minor_stat_upgrade_bonus_evasion",
   },

   npc_dota_hero_dazzle=
   {      
      
   },

   npc_dota_hero_pangolier=
   {      
      
   },

   npc_dota_hero_dark_willow=
   {      
      
   },
}

-- NOTE: These are substrings to search for in SPECIAL_ABILITY_UPGRADES
_G.ULTIMATE_ABILITY_NAMES =
{
   npc_dota_hero_omniknight = "omniknight_guardian_angel",
   npc_dota_hero_magnataur = "magnataur_reverse_polarity",
   npc_dota_hero_phantom_assassin = "phantom_assassin_coup_de_grace",
   npc_dota_hero_winter_wyvern = "winter_wyvern_winters_curse",
   npc_dota_hero_disruptor = "disruptor_static_storm",
   npc_dota_hero_snapfire = "snapfire_mortimer_kisses", 
   npc_dota_hero_tusk = "tusk_walrus_punch",
   npc_dota_hero_ursa = "ursa_enrage",
   npc_dota_hero_sniper = "sniper_assassinate",
   npc_dota_hero_mars = "mars_arena_of_blood",
   npc_dota_hero_viper = "_strike", -- Not "viper_viper_strike" because the viper strike names in SPECIAL_ABILITY_UPGRADES are wierd
   npc_dota_hero_weaver = "weaver_time_lapse",
   npc_dota_hero_witch_doctor = "witch_doctor_death_ward",
   npc_dota_hero_queenofpain = "queenofpain_sonic_wave",
   npc_dota_hero_templar_assassin = "templar_assassin_psionic_trap",
   npc_dota_hero_slark = "slark_shadow_dance",
   npc_dota_hero_juggernaut = "juggernaut_omni_slash",
   npc_dota_hero_venomancer = "venomancer_poison_nova",
   npc_dota_hero_windrunner = "windrunner_focusfire",
   npc_dota_hero_legion_commander = "legion_commander_duel",
   npc_dota_hero_ogre_magi = "ogre_magi_multicast",
   npc_dota_hero_nevermore = "nevermore_requiem",
   npc_dota_hero_axe = "axe_culling_blade",
   npc_dota_hero_jakiro = "jakiro_macropyre",
   npc_dota_hero_tidehunter = "tidehunter_ravage",
   npc_dota_hero_hoodwink = "hoodwink_sharpshooter",
   npc_dota_hero_phoenix = "phoenix_supernova",
   npc_dota_hero_dragon_knight = "dragon_knight_elder_dragon_form",
   npc_dota_hero_dawnbreaker = "dawnbreaker_solar_guardian",
   npc_dota_hero_dazzle = "dazzle_bad_juju",
   npc_dota_hero_pangolier = "pangolier_rolling_thunder",
   npc_dota_hero_dark_willow = "dark_willow_terrorize",
}

-- Lists for ability upgrades go here
_G.SPECIAL_ABILITY_UPGRADES = {}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_dark_willow"] =
{         
   --"dark_willow_bramble_maze_lua_thicket",
   --"dark_willow_bramble_maze_lua_healing",

   "dark_willow_shadow_realm_lua_phase",
   "dark_willow_shadow_realm_lua_assault",
   "dark_willow_shadow_realm_lua_blast",

   --"dark_willow_cursed_crown_lua_thorns",

   --"dark_willow_bedlam_lua_snare",
   --"dark_willow_bedlam_lua_blitz",

   "dark_willow_terrorize_lua_skeletons",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_dazzle"] =
{         
   "pf_poison_touch_spread",
   "pf_poison_touch_ward",
   "pf_poison_touch_chain",

   "pf_shallow_grave_invis",
   "pf_shallow_grave_aoe",
   "pf_shallow_grave_ground",

   "pf_shadow_wave_enemy",
   "pf_shadow_wave_proc",
   "pf_shadow_wave_dispel",

   "pf_bad_juju_attacks",
   "pf_bad_juju_heal",
   "pf_bad_juju_raze",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_dawnbreaker"] =
{         
   "dawnbreaker_starbreaker_lua_solar_pulse",
   "dawnbreaker_starbreaker_lua_max_luminosity",
   "dawnbreaker_starbreaker_lua_smash_sleep",
   "dawnbreaker_celestial_hammer_lua_skewer",
   "dawnbreaker_celestial_hammer_lua_illusion",
   "dawnbreaker_celestial_hammer_lua_trail_heal",
   "dawnbreaker_luminosity_lua_charge",
   "dawnbreaker_luminosity_lua_stacking",
   "dawnbreaker_luminosity_lua_explosion",
   "dawnbreaker_solar_guardian_lua_charges",
   "dawnbreaker_solar_guardian_lua_permanent_dummy",
   "dawnbreaker_solar_guardian_lua_capture",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_dragon_knight"] =
{         
   "pathfinder_dk_breathe_fire_stun",
   "pathfinder_dk_breathe_fire_macropyre",
   "pathfinder_dk_breathe_fire_crit_lifesteal",

   "pathfinder_dk_dragon_tail_passive",
   "pathfinder_dk_dragon_tail_bounce",
   "pathfinder_dk_dragon_tail_chain",

   "pathfinder_dk_dragon_blood_damage",
   "pathfinder_dk_dragon_blood_gold",
   "pathfinder_dk_dragon_blood_active",

   "pathfinder_dk_elder_dragon_form_attack",
   "pathfinder_dk_elder_dragon_form_fear",   
   "pathfinder_dk_elder_dragon_form_cdr",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_phoenix"] =
{         
   "pathfinder_icarus_dive_loop",
   "pathfinder_icarus_dive_flyby",
   "pathfinder_icarus_dive_bkb",

   "pathfinder_fire_spirit_sun_strike",
   "pathfinder_fire_spirit_shell",
   "pathfinder_fire_spirit_baby",

   "pathfinder_sun_ray_star",
   "pathfinder_sun_ray_infinite",

   "pathfinder_supernova_allies",
   "pathfinder_supernova_blackhole",   
   "pathfinder_supernova_heal_bkb",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_hoodwink"] =
{   
   "pathfinder_acorn_shot_attack",
   "pathfinder_acorn_shot_stun",
   "pathfinder_acorn_shot_tree",

   "pathfinder_bushwhack_ground",
   "pathfinder_bushwhack_multi_attack",
   "pathfinder_bushwhack_scurry",

   "pathfinder_scurry_canadian",
   "pathfinder_scurry_allies",
   "pathfinder_scurry_leap",

   "pathfinder_sharpshooter_reset",
   -- "pathfinder_sharpshooter_pierce",
   "pathfinder_sharpshooter_spread",
   "pathfinder_sharpshooter_moving",   
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_tidehunter"] =
{
   "tidehunter_gush_pf_ravage",   
   "tidehunter_gush_pf_bounce",
   "tidehunter_kraken_shell_pf_gush",
   "tidehunter_kraken_shell_pf_ravage_cdr",
   "tidehunter_anchor_smash_pf_allies",
   "tidehunter_ravage_pf_puddle",
   "tidehunter_anchor_smash_pf_karate",
   "tidehunter_pf_crunch",
   "tidehunter_anchor_smash_pf_whack",
   "tidehunter_kraken_shell_pf_heal",
   "tidehunter_gush_pf_miss",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_jakiro"] =
{
	"pathfinder_jakiro_dual_breath_fart",   
   "pathfinder_jakiro_duel_breath_liquid_fire",
   "pathfinder_jakiro_duel_breath_ice_blob",
   
   "pathfinder_jakiro_ice_path_barrier",
   "pathfinder_jakiro_ice_path_armour",
   "pathfinder_jakiro_ice_path_repeat",
   "pathfinder_jakiro_ice_path_fast",

   -- "pathfinder_jakiro_liquid_fire_splinter",
   "pathfinder_jakiro_liquid_fire_allies",
   "pathfinder_jakiro_liquid_fire_macropyre",
   "pathfinder_jakiro_liquid_fire_burst",

   "pathfinder_jakiro_macropyre_burning_man",
   "pathfinder_jakiro_macropyre_cooldown_reduction",
   "pathfinder_jakiro_macropyre_eternal",
   "pathfinder_jakiro_macropyre_heal",

}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_axe"] =
{
	"pathfinder_axe_special_culling_blade_leap",   
   "pathfinder_axe_special_culling_blade_omnislash",
   "pathfinder_axe_special_culling_blade_heal",
   "pathfinder_axe_special_culling_blade_delay",

   "pathfinder_axe_special_counter_helix_reduce_damage",
   "pathfinder_axe_special_counter_helix_allies",
   "pathfinder_axe_special_counter_helix_fury",

   "pathfinder_axe_special_battle_hunger_lifesteal",
   "pathfinder_axe_special_battle_hunger_culling_cdr",
   "pathfinder_axe_special_battle_hunger_refresh",

   "pathfinder_axe_special_berseker_call_health",
   "pathfinder_axe_special_berseker_call_battle_hunger",
   "pathfinder_axe_special_berseker_call_allies",
   "pathfinder_axe_special_berseker_call_blink",

}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_nevermore"] =
{
	"pathfinder_nevermore_special_raze_multi",   
   "pathfinder_nevermore_special_dark_lord_raze",

   "pathfinder_nevermore_special_requiem_attack",
   "pathfinder_nevermore_special_requiem_soul_projectile",
   "pathfinder_nevermore_special_requiem_sleep",

   "pathfinder_nevermore_special_necromastery_revenant",   
   "pathfinder_nevermore_special_necromastery_attack_soul",   
   "pathfinder_nevermore_special_necromastery_lifesteal",

   "pathfinder_nevermore_special_dark_lord_friendly",
   "pathfinder_nevermore_special_dark_lord_split_attack",

}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_ogre_magi"] =
{
   "pathfinder_special_ignite_fireblast",
   "pathfinder_special_friendly_ignite",
   "pathfinder_special_ignite_multismash",
   
   "pathfinder_special_om_shield_bloodlust",
   "pathfinder_special_bloodlust_fear",

   "pathfinder_special_om_aoe_fireblast",
   "pathfinder_special_om_summoming",   
   "pathfinder_special_om_gold_fireblast",
   
   "pathfinder_special_om_aoe_multicast",
   "pathfinder_special_om_multi_multicast",
   "pathfinder_special_om_alive_multicast",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_phantom_assassin"] =
{
	"pathfinder_special_pa_dagger_bouncing",
   --"pathfinder_special_pa_dagger_freeze",   
   "pathfinder_special_pa_blur_cdr",
   "pathfinder_special_pa_blink_illusion",
   "pathfinder_special_pa_blink_aoe",
   "pathfinder_special_pa_blur_block",
   "pathfinder_special_pa_blur_aoe",
   "pathfinder_special_pa_crit_lifesteal",
   "pathfinder_special_pa_crit_fear",
   "phantom_assassin_dagger_global_dummy",
   "pathfinder_special_pa_crit_dagger",
   "pathfinder_special_pa_blur_regen",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_legion_commander"] =
{
   "pathfinder_special_lc_global_arrows_dummy",
   "pathfinder_special_lc_duel_arrows",
   "pathfinder_special_lc_arrows_meteor"
   ,
   "pathfinder_special_lc_arrows_reset",

   "pathfinder_special_lc_duel_legion",
   "pathfinder_special_lc_duel_purge",

   
   "pathfinder_special_lc_moment_aoe",

   "pathfinder_special_lc_press_blademail",
   "pathfinder_special_lc_press_bkb",
   --"pathfinder_special_lc_moment_aura",

}


SPECIAL_ABILITY_UPGRADES["npc_dota_hero_windrunner"] =
{
   "pathfinder_special_windranger_windrun_cyclone",
   "pathfinder_special_windranger_windrun_invis",
   "pathfinder_special_windranger_powershot_multishot",
   --"pathfinder_special_windranger_powershot_ricochet",
   "pathfinder_special_windranger_powershot_attacks",
   "pathfinder_special_windranger_powershot_repeating",
   "pathfinder_special_windranger_windrun_aoe",   

   "pathfinder_special_windranger_focusfire_trueshot",
   "pathfinder_special_windranger_focusfire_global",
   "pathfinder_special_windranger_focusfire_lifesteal",

   "pathfinder_special_windranger_shackleshot_aoe",
   "pathfinder_special_windranger_shackleshot_sleep",
   "pathfinder_special_windranger_shackleshot_armor",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_juggernaut"] =
{
   "pathfinder_special_juggernaut_blade_fury_ward",   
   "pathfinder_special_juggernaut_blade_fury_flying",
   "pathfinder_special_juggernaut_blade_fury_strength",

   "pathfinder_special_juggernaut_blade_dance_illusion",
   "pathfinder_special_juggernaut_blade_dance_reduce_omnislash_cooldown",

   "pathfinder_special_juggernaut_healing_ward_earthshock",
   "pathfinder_special_juggernaut_healing_ward_allies",
   "pathfinder_special_juggernaut_healing_ward_creep",
   -- "pathfinder_special_juggernaut_healing_ward_radiance",
   
   "pathfinder_special_juggernaut_wind_breathing_dummy",
   --"pathfinder_special_juggernaut_omni_tiny_slash",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_venomancer"] =
{
   "pathfinder_special_venomancer_ward_global_attack",
   "pathfinder_special_venomancer_ward_lifesteal",
   "pathfinder_special_venomancer_ward_nova",   
   "pathfinder_special_venomancer_bigass_ward_dummy",   
   "pathfinder_special_venomancer_ward_corpse",
   "pathfinder_special_venomancer_gale_attack",
   "pathfinder_special_venomancer_banana_bomb",
   "pathfinder_special_venomancer_gale_bkb",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_omniknight"] =
{
	"aghsfort_special_omniknight_purification_cast_radius",
	"aghsfort_special_omniknight_purification_charges",
	-- "aghsfort_special_omniknight_purification_cooldown_reduction",
	"aghsfort_special_omniknight_purification_multicast",

   "aghsfort_special_omniknight_repel_procs_purification",
   "aghsfort_special_omniknight_repel_outgoing_damage",
   --"aghsfort_special_omniknight_repel_applies_degen_aura", --needs some re-write to make it work in all cases and doesn't seem interesting anyway
   "aghsfort_special_omniknight_repel_damage_instance_refraction",
   "aghsfort_special_omniknight_repel_knockback_on_cast",

   "aghsfort_special_omniknight_degen_aura_toggle",
   "aghsfort_special_omniknight_degen_aura_damage",
   "aghsfort_special_omniknight_degen_aura_restoration",

   "aghsfort_special_omniknight_guardian_angel_purification",
   "aghsfort_special_omniknight_guardian_angel_immune_flight",
   --"aghsfort_special_omniknight_guardian_angel_single_target",
   "aghsfort_special_omniknight_guardian_angel_single_target_dummy",

}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_magnataur"] =
{
   "aghsfort_special_magnataur_shockwave_multishot",
	"aghsfort_special_magnataur_shockwave_damage_reduction",
   "aghsfort_special_magnataur_shockwave_boomerang",

	"aghsfort_special_magnataur_empower_all_allies",
   "aghsfort_special_magnataur_empower_lifesteal",
   "aghsfort_special_magnataur_empower_shockwave_on_attack",

   --"aghsfort_special_magnataur_skewer_original_scepter",
   --"aghsfort_special_magnataur_friendly_skewer",
   "aghsfort_special_magnataur_skewer_bonus_strength",
   "aghsfort_special_magnataur_skewer_heal",
   "aghsfort_special_magnataur_skewer_shockwave",

   --"aghsfort_special_magnataur_reverse_polarity_radius",
   "aghsfort_special_magnataur_reverse_polarity_polarity_dummy",
   "aghsfort_special_magnataur_reverse_polarity_allies_crit",
   "aghsfort_special_magnataur_reverse_polarity_steroid",
}
-- SPECIAL_ABILITY_UPGRADES["npc_dota_hero_luna"] =
-- {
-- 	"omniknight_guardian_angel",
-- 	"aghsfort_special_omniknight_purification_cast_radius",
-- 	"omniknight_purification",
-- }


SPECIAL_ABILITY_UPGRADES["npc_dota_hero_winter_wyvern"] =
{
   "aghsfort_special_winter_wyvern_arctic_burn_splitshot",
   "aghsfort_special_winter_wyvern_arctic_burn_doubleattack",
   --"aghsfort_special_winter_wyvern_arctic_burn_nomana",
   "aghsfort_special_winter_wyvern_arctic_burn_splash_damage",

   "aghsfort_special_winter_wyvern_splinter_blast_main_target_hit",
   "aghsfort_special_winter_wyvern_splinter_blast_vacuum",
   "aghsfort_special_winter_wyvern_splinter_blast_heal",

   "aghsfort_special_winter_wyvern_cold_embrace_charges",
   "aghsfort_special_winter_wyvern_cold_embrace_blast_on_end",
   "aghsfort_special_winter_wyvern_cold_embrace_magic_damage_block",

   "aghsfort_special_winter_wyvern_winters_curse_transfer",
   "aghsfort_special_winter_wyvern_winters_curse_damage_amp",
   "aghsfort_special_winter_wyvern_winters_curse_heal_on_death",
}


SPECIAL_ABILITY_UPGRADES["npc_dota_hero_disruptor"] =
{
	"aghsfort_special_disruptor_thunder_strike_interval_upgrade",
	"aghsfort_special_disruptor_thunder_strike_mana_restore",
	"aghsfort_special_disruptor_thunder_strike_crit_chance",
	"aghsfort_special_disruptor_thunder_strike_on_attack",

--	"aghsfort_special_disruptor_glimpse_cast_aoe",
	"aghsfort_special_disruptor_glimpse_hit_on_arrival",
	"aghsfort_special_disruptor_glimpse_travel_damage",

	--"aghsfort_special_disruptor_kinetic_field_instant_setup",
	"aghsfort_special_disruptor_kinetic_field_damage",
	"aghsfort_special_disruptor_kinetic_field_allied_heal",
	"aghsfort_special_disruptor_kinetic_field_allied_attack_buff",
   "aghsfort_special_disruptor_kinetic_field_double_ring",

	"aghsfort_special_disruptor_static_storm_kinetic_field_on_cast",
	"aghsfort_special_disruptor_static_storm_crits_on_attacks",
	"aghsfort_special_disruptor_static_storm_damage_reduction",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_snapfire"] =
{
   --"pathfinder_special_snapfire_gobble",
   "aghsfort_special_snapfire_scatterblast_double_barrel",
   "aghsfort_special_snapfire_scatterblast_knockback",
  -- "aghsfort_special_snapfire_scatterblast_fullrange_pointblank",
   "aghsfort_special_snapfire_scatterblast_barrage",

   "aghsfort_special_snapfire_firesnap_cookie_multicookie",
   "aghsfort_special_snapfire_firesnap_cookie_enemytarget",
   "aghsfort_special_snapfire_firesnap_cookie_allied_buff",

   "aghsfort_special_snapfire_lil_shredder_explosives",
   "aghsfort_special_snapfire_lil_shredder_ally_cast",
   "aghsfort_special_snapfire_lil_shredder_bouncing_bullets",

   "aghsfort_special_snapfire_mortimer_kisses_fragmentation",
--   "aghsfort_special_snapfire_mortimer_kisses_fire_trail",
   "aghsfort_special_snapfire_mortimer_kisses_autoattack",
   "aghsfort_special_snapfire_mortimer_kisses_incoming_damage_reduction",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_tusk"] =
{
   --"aghsfort_special_tusk_ice_shards_circle",
   "aghsfort_special_tusk_ice_shards_secondary",
   "aghsfort_special_tusk_ice_shards_explode",
   "aghsfort_special_tusk_ice_shards_stun",

   "aghsfort_special_tusk_snowball_heal",
   "aghsfort_special_tusk_snowball_end_damage",
   "aghsfort_special_tusk_snowball_global",

   "aghsfort_special_tusk_tag_team_lifesteal",
   "aghsfort_special_tusk_tag_team_toggle",
   "aghsfort_special_tusk_tag_team_global",

   "tusk_frozen_sigil_pf",

   "aghsfort_special_tusk_walrus_punch_reset",
   "aghsfort_special_tusk_walrus_punch_land_damage",
   "aghsfort_special_tusk_walrus_punch_wallop",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_ursa"] =
{
   "aghsfort_special_ursa_earthshock_invis",
   "aghsfort_special_ursa_earthshock_knockback",
   "aghsfort_special_ursa_earthshock_apply_fury_swipes", 
   "aghsfort_special_ursa_earthshock_overpower_stack",
   --"aghsfort_special_ursa_earthshock_miss_chance",

   "aghsfort_special_ursa_overpower_crit",
   "aghsfort_special_ursa_overpower_evasion",
   "aghsfort_special_ursa_overpower_cleave",
  -- "aghsfort_special_ursa_overpower_taunt",

   "aghsfort_special_ursa_fury_swipes_armor_reduction",
   "aghsfort_special_ursa_fury_swipes_lifesteal",
   "aghsfort_special_ursa_fury_swipes_ursa_minor",

   --"aghsfort_special_ursa_enrage_magic_immunity",
   "aghsfort_special_ursa_enrage_allies",
   "aghsfort_special_ursa_enrage_fear",
   --"aghsfort_special_ursa_enrage_armor",
   "aghsfort_special_ursa_enrage_earthshock",
   "aghsfort_special_ursa_enrage_attack_speed",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_sniper"] =
{
   "aghsfort_special_sniper_shrapnel_bombs",
   "aghsfort_special_sniper_shrapnel_attack_speed",
   "aghsfort_special_sniper_shrapnel_miss_chance",
   "aghsfort_special_sniper_shrapnel_move_speed",

   "aghsfort_special_sniper_headshot_crits",
   "aghsfort_special_sniper_headshot_stuns",

   "aghsfort_special_sniper_take_aim_self_purge",
   --"aghsfort_special_sniper_take_aim_aoe", -- bugged
   "aghsfort_special_sniper_take_aim_hop_backwards",
   "aghsfort_special_sniper_take_aim_armor_reduction",
   "aghsfort_special_sniper_take_aim_rapid_fire",

   "aghsfort_special_sniper_assassinate_buckshot",
   "aghsfort_special_sniper_assassinate_original_scepter",
   "aghsfort_special_sniper_assassinate_killshot",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_mars"] = 
{
   "aghsfort_special_mars_spear_multiskewer",
   "aghsfort_special_mars_spear_impale_explosion",
   "aghsfort_special_mars_spear_burning_trail",

   "aghsfort_special_mars_gods_rebuke_full_circle",
   "aghsfort_special_mars_gods_rebuke_stun",
   "aghsfort_special_mars_gods_rebuke_strength_buff",

   "aghsfort_special_mars_bulwark_counter_rebuke",
   --"aghsfort_special_mars_bulwark_healing",
   --"aghsfort_special_mars_bulwark_return",
   "aghsfort_special_mars_bulwark_spears",
   "aghsfort_special_mars_bulwark_soldiers",

   "aghsfort_special_mars_arena_of_blood_outside_perimeter",
   --"aghsfort_special_mars_arena_of_blood_fear",
   "aghsfort_special_mars_arena_of_blood_global",
   "aghsfort_special_mars_arena_of_blood_attack_buff",
}
SPECIAL_ABILITY_UPGRADES["npc_dota_hero_viper"] = 
{
   "aghsfort_special_viper_poison_attack_spread",
   "aghsfort_special_viper_poison_attack_explode",
   "aghsfort_special_viper_poison_snap",

   "aghsfort_special_viper_nethertoxin_lifesteal",
   "aghsfort_special_viper_nethertoxin_charges",
   "aghsfort_special_viper_nethertoxin_persist",

   "aghsfort_special_viper_corrosive_skin_speed_steal",
   "aghsfort_special_viper_corrosive_skin_flying",
   "aghsfort_special_viper_corrosive_skin_aura",

   "aghsfort_special_viper_viper_strike_allies",
   --"aghsfort_special_viper_channeled_viper_strike",
   "aghsfort_special_viper_periodic_strike",
   "aghsfort_special_viper_chain_viper_strike",
}


SPECIAL_ABILITY_UPGRADES["npc_dota_hero_weaver"] = 
{
   "aghsfort_special_weaver_swarm_allies",
   "aghsfort_special_weaver_swarm_explosion",
   "aghsfort_special_weaver_swarm_damage_transfer",

   "aghsfort_special_weaver_geminate_attack_splitshot",
   "aghsfort_special_weaver_geminate_attack_applies_swarm",  
   "aghsfort_special_weaver_geminate_attack_lifesteal",
  -- "aghsfort_special_weaver_geminate_attack_knockback",



  -- "aghsfort_special_weaver_shukuchi_pull",
  "aghsfort_special_weaver_shukuchi_trail",
  "aghsfort_special_weaver_shukuchi_heal",
  "aghsfort_special_weaver_shukuchi_attack_on_completion",
  "aghsfort_special_weaver_shukuchi_swarm",
  --"aghsfort_special_weaver_shukuchi_greater_invisibility",

  "aghsfort_special_weaver_time_lapse_allies",
  "aghsfort_special_weaver_time_lapse_restoration",
  "aghsfort_special_weaver_time_lapse_explosion",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_witch_doctor"] = 
{

   "aghsfort_special_witch_doctor_paralyzing_cask_multicask",
   "aghsfort_special_witch_doctor_paralyzing_cask_applies_maledict",
   "aghsfort_special_witch_doctor_paralyzing_cask_aoe_damage",
   "aghsfort_special_witch_doctor_paralyzing_cask_attack_procs",
   
   --"aghsfort_special_witch_doctor_maledict_ground_curse",
   "aghsfort_special_witch_doctor_maledict_aoe_procs",
   "aghsfort_special_witch_doctor_maledict_death_restoration",
   "aghsfort_special_witch_doctor_maledict_affects_allies",
   "aghsfort_special_witch_doctor_maledict_infectious",
   
   "aghsfort_special_witch_doctor_voodoo_restoration_enemy_damage",
   "aghsfort_special_witch_doctor_voodoo_restoration_lifesteal",
   "aghsfort_special_witch_doctor_voodoo_restoration_damage_amp",
   "aghsfort_special_witch_doctor_voodoo_restoration_mana_restore",
   
   "aghsfort_special_witch_doctor_death_ward_no_channel",
   "aghsfort_special_witch_doctor_death_ward_splitshot",
   "aghsfort_special_witch_doctor_death_ward_damage_resist",
   --"aghsfort_special_witch_doctor_death_ward_bounce",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_queenofpain"] =
{
   "aghsfort_special_queenofpain_shadow_strike_on_attack",
   "aghsfort_special_queenofpain_shadow_strike_chain",
   "aghsfort_special_queenofpain_shadow_strike_scream",

   "aghsfort_special_queenofpain_blink_generates_scream",
   "aghsfort_special_queenofpain_blink_attack_speed",
   "aghsfort_special_queenofpain_blink_shadow_strike",

   "aghsfort_special_queenofpain_scream_of_pain_resets_blink",
   "aghsfort_special_queenofpain_scream_of_pain_restores_caster",
   "aghsfort_special_queenofpain_scream_of_pain_knockback",

   "aghsfort_special_queenofpain_sonic_wave_trail",
   "aghsfort_special_queenofpain_sonic_wave_circle",
   "aghsfort_special_queenofpain_sonic_wave_attack_buff",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_templar_assassin"] = 
{

   "aghsfort_special_templar_assassin_refraction_allies",
   "aghsfort_special_templar_assassin_refraction_kill_refresh",
  -- "aghsfort_special_templar_assassin_refraction_counter_attack",
   "aghsfort_special_templar_assassin_refraction_detonate_trap",


   "aghsfort_special_templar_assassin_meld_attack_on_activation",
   "aghsfort_special_templar_assassin_meld_teleport",
   "aghsfort_special_templar_assassin_meld_refraction_on_kill", 
   

   --"aghsfort_special_templar_assassin_psi_blades_autoattack",
   "aghsfort_special_templar_assassin_psi_blades_trap",
   "aghsfort_special_templar_assassin_psi_blades_splash", 

   "aghsfort_special_templar_assassin_psionic_trap_area_attack",
   "aghsfort_special_templar_assassin_psionic_trap_damage_heals",
   "aghsfort_special_templar_assassin_psionic_trap_multipulse",
   
}


SPECIAL_ABILITY_UPGRADES["npc_dota_hero_slark"] =
{
   "aghsfort_special_slark_dark_pact_essence_shift",
   "aghsfort_special_slark_dark_pact_push_stun",
   --"aghsfort_special_slark_dark_pact_dispells_allies",
   "aghsfort_special_slark_dark_pact_unit_target",

   "aghsfort_special_slark_pounce_attack_all",
   "aghsfort_special_slark_pounce_projectiles",
   "aghsfort_special_slark_pounce_leashed_bonus",

   "aghsfort_special_slark_essence_shift_aoe_attack",
   "aghsfort_special_slark_essence_shift_leash_chance",
   "aghsfort_special_slark_essence_shift_allied_buff",

   "aghsfort_special_slark_shadow_dance_essence_shift_bonus",
   "aghsfort_special_slark_shadow_dance_dark_pact_pulses",
   "aghsfort_special_slark_shadow_dance_leash",

}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_pangolier"] =
{
   "pangolier_swashbuckle_uses_attack",
   "pangolier_shield_crash_stuns",
   "pangolier_lucky_shot_breaks",
   "pangolier_rolling_thunder_ricochet"
}

require( "items/item_small_scepter_fragment" )

_G.PURCHASABLE_SHARDS = {}

item_pangolier_swashbuckle_lua_pct_cooldown = item_small_scepter_fragment
item_pangolier_swashbuckle_lua_damage = item_small_scepter_fragment

item_pangolier_shield_crash_lua_pct_cooldown = item_small_scepter_fragment
item_pangolier_shield_crash_lua_damage = item_small_scepter_fragment

item_pangolier_rolling_thunder_lua_pct_cooldown = item_small_scepter_fragment
item_pangolier_rolling_thunder_lua_damage = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_pangolier" ] =
{
   "item_pangolier_swashbuckle_lua_pct_cooldown",
   "item_pangolier_swashbuckle_lua_damage",
  
   "item_pangolier_shield_crash_lua_damage",
   "item_pangolier_shield_crash_lua_pct_cooldown",
   
   "item_pangolier_rolling_thunder_lua_pct_cooldown",
   "item_pangolier_rolling_thunder_lua_damage"
}

item_pf_poison_touch_end_distance = item_small_scepter_fragment
item_pf_poison_touch_targets = item_small_scepter_fragment
item_pf_poison_touch_damage = item_small_scepter_fragment
item_pf_poison_touch_slow = item_small_scepter_fragment
item_pf_poison_touch_duration = item_small_scepter_fragment
item_pf_poison_touch_pct_cooldown = item_small_scepter_fragment

item_pf_shadow_wave_damage_radius = item_small_scepter_fragment
item_pf_shadow_wave_damage = item_small_scepter_fragment
item_pf_shadow_wave_mana = item_small_scepter_fragment
item_pf_shadow_wave_pct_cooldown = item_small_scepter_fragment

item_pf_shallow_grave_duration = item_small_scepter_fragment
item_pf_shallow_grave_cast_range = item_small_scepter_fragment
item_pf_shallow_grave_pct_cooldown = item_small_scepter_fragment

item_pf_bad_juju_cooldown_reduction = item_small_scepter_fragment
item_pf_bad_juju_armor_reduction = item_small_scepter_fragment
item_pf_bad_juju_max_reduction = item_small_scepter_fragment
item_pf_bad_juju_radius = item_small_scepter_fragment
item_pf_bad_juju_duration = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_dazzle" ] =
{
   "item_pf_poison_touch_end_distance",
   "item_pf_poison_touch_targets",
   "item_pf_poison_touch_damage",
   "item_pf_poison_touch_slow",
   "item_pf_poison_touch_duration",
   "item_pf_poison_touch_pct_cooldown",

   "item_pf_shadow_wave_damage_radius",
   "item_pf_shadow_wave_damage",
   "item_pf_shadow_wave_mana",
   "item_pf_shadow_wave_pct_cooldown",

   "item_pf_shallow_grave_duration",
   "item_pf_shallow_grave_cast_range",
   "item_pf_shallow_grave_pct_cooldown",

   "item_pf_bad_juju_cooldown_reduction",
   "item_pf_bad_juju_armor_reduction",
   "item_pf_bad_juju_max_reduction",
   "item_pf_bad_juju_radius",
   "item_pf_bad_juju_duration",
   
}


item_dawnbreaker_starbreaker_lua_swipe_damage = item_small_scepter_fragment
item_dawnbreaker_starbreaker_lua_smash_damage = item_small_scepter_fragment
item_dawnbreaker_starbreaker_lua_smash_radius = item_small_scepter_fragment
item_dawnbreaker_starbreaker_lua_smash_stun_duration = item_small_scepter_fragment
item_dawnbreaker_starbreaker_lua_smash_pct_cooldown = item_small_scepter_fragment

item_dawnbreaker_celestial_hammer_lua_hammer_damage = item_small_scepter_fragment
item_dawnbreaker_celestial_hammer_lua_flare_burn_damage = item_small_scepter_fragment
item_dawnbreaker_celestial_hammer_lua_range = item_small_scepter_fragment
item_dawnbreaker_celestial_hammer_lua_flare_debuff_duration = item_small_scepter_fragment
item_dawnbreaker_celestial_hammer_lua_pct_cooldown = item_small_scepter_fragment

item_dawnbreaker_luminosity_lua_heal_pct = item_small_scepter_fragment
item_dawnbreaker_luminosity_lua_bonus_damage = item_small_scepter_fragment
item_dawnbreaker_luminosity_lua_heal_radius = item_small_scepter_fragment

item_dawnbreaker_solar_guardian_lua_airtime_duration = item_small_scepter_fragment
item_dawnbreaker_solar_guardian_lua_radius = item_small_scepter_fragment
item_dawnbreaker_solar_guardian_lua_base_damage = item_small_scepter_fragment
item_dawnbreaker_solar_guardian_lua_base_heal = item_small_scepter_fragment
item_dawnbreaker_solar_guardian_lua_land_stun_duration = item_small_scepter_fragment
item_dawnbreaker_solar_guardian_lua_pct_cooldown = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_dawnbreaker" ] =
{
   "item_dawnbreaker_starbreaker_lua_swipe_damage",
   "item_dawnbreaker_starbreaker_lua_smash_damage",
   "item_dawnbreaker_starbreaker_lua_smash_radius",
   "item_dawnbreaker_starbreaker_lua_smash_stun_duration",
   "item_dawnbreaker_starbreaker_lua_smash_pct_cooldown",

   "item_dawnbreaker_celestial_hammer_lua_hammer_damage",
   "item_dawnbreaker_celestial_hammer_lua_flare_burn_damage",
   "item_dawnbreaker_celestial_hammer_lua_range",
   "item_dawnbreaker_celestial_hammer_lua_flare_debuff_duration",
   "item_dawnbreaker_celestial_hammer_lua_pct_cooldown",

   "item_dawnbreaker_luminosity_lua_heal_pct",
   "item_dawnbreaker_luminosity_lua_bonus_damage",
   "item_dawnbreaker_luminosity_lua_heal_radius",

   "item_dawnbreaker_solar_guardian_lua_airtime_duration",
   "item_dawnbreaker_solar_guardian_lua_radius",
   "item_dawnbreaker_solar_guardian_lua_base_damage",
   "item_dawnbreaker_solar_guardian_lua_base_heal",
   "item_dawnbreaker_solar_guardian_lua_land_stun_duration",
   "item_dawnbreaker_solar_guardian_lua_pct_cooldown",
}




item_pathfinder_dk_breathe_fire_range = item_small_scepter_fragment
item_pathfinder_dk_breathe_fire_reduction = item_small_scepter_fragment
item_pathfinder_dk_breathe_fire_duration = item_small_scepter_fragment
item_pathfinder_dk_breathe_fire_damage = item_small_scepter_fragment
item_pathfinder_dk_breathe_fire_pct_cooldown = item_small_scepter_fragment

item_pathfinder_dk_dragon_tail_stun_duration = item_small_scepter_fragment
item_pathfinder_dk_dragon_tail_attack_damage = item_small_scepter_fragment
item_pathfinder_dk_dragon_tail_radius = item_small_scepter_fragment
item_pathfinder_dk_dragon_tail_pct_cooldown = item_small_scepter_fragment

item_pathfinder_dk_dragon_blood_bonus_health_regen = item_small_scepter_fragment
item_pathfinder_dk_dragon_blood_bonus_armor = item_small_scepter_fragment

item_pathfinder_dk_elder_dragon_form_duration = item_small_scepter_fragment
item_pathfinder_dk_elder_dragon_form_bonus_movement_speed = item_small_scepter_fragment
item_pathfinder_dk_elder_dragon_form_bonus_attack_range = item_small_scepter_fragment
item_pathfinder_dk_elder_dragon_form_bonus_attack_damage = item_small_scepter_fragment
item_pathfinder_dk_elder_dragon_form_pct_cooldown = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_dragon_knight" ] =
{
   "item_pathfinder_dk_breathe_fire_range",
   "item_pathfinder_dk_breathe_fire_reduction",
   "item_pathfinder_dk_breathe_fire_duration",
   "item_pathfinder_dk_breathe_fire_damage",
   "item_pathfinder_dk_breathe_fire_pct_cooldown",

   "item_pathfinder_dk_dragon_tail_stun_duration",
   "item_pathfinder_dk_dragon_tail_attack_damage",
   "item_pathfinder_dk_dragon_tail_radius",
   "item_pathfinder_dk_dragon_tail_pct_cooldown",

   "item_pathfinder_dk_dragon_blood_bonus_health_regen",
   "item_pathfinder_dk_dragon_blood_bonus_armor",

   "item_pathfinder_dk_elder_dragon_form_duration",
   "item_pathfinder_dk_elder_dragon_form_bonus_movement_speed",
   "item_pathfinder_dk_elder_dragon_form_bonus_attack_range",
   "item_pathfinder_dk_elder_dragon_form_bonus_attack_damage",
   "item_pathfinder_dk_elder_dragon_form_pct_cooldown",
   
}


item_phoenix_icarus_dive_pf_cooldown = item_small_scepter_fragment
item_phoenix_icarus_dive_pf_dash_length = item_small_scepter_fragment
item_phoenix_icarus_dive_pf_burn_duration = item_small_scepter_fragment
item_phoenix_icarus_dive_pf_damage_per_second = item_small_scepter_fragment
item_phoenix_icarus_dive_pf_slow_movement_speed_pct = item_small_scepter_fragment

item_phoenix_fire_spirits_pf_cooldown = item_small_scepter_fragment
item_phoenix_fire_spirits_pf_duration = item_small_scepter_fragment
item_phoenix_fire_spirits_pf_damage_per_second = item_small_scepter_fragment
item_phoenix_fire_spirits_pf_attackspeed_slow = item_small_scepter_fragment

item_phoenix_sun_ray_pf_cooldown = item_small_scepter_fragment
item_phoenix_sun_ray_pf_hp_cost_perc_per_second = item_small_scepter_fragment
item_phoenix_sun_ray_pf_base_damage = item_small_scepter_fragment
item_phoenix_sun_ray_pf_hp_perc_heal = item_small_scepter_fragment
item_phoenix_sun_ray_pf_beam_range = item_small_scepter_fragment

item_phoenix_supernova_pf_cooldown = item_small_scepter_fragment
item_phoenix_supernova_pf_damage_per_sec = item_small_scepter_fragment
item_phoenix_supernova_pf_max_health_for_egg = item_small_scepter_fragment
item_phoenix_supernova_pf_stun_duration = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_phoenix" ] =
{
   "item_phoenix_icarus_dive_pf_cooldown",
   "item_phoenix_icarus_dive_pf_dash_length",
   "item_phoenix_icarus_dive_pf_burn_duration",
   "item_phoenix_icarus_dive_pf_damage_per_second",
   "item_phoenix_icarus_dive_pf_slow_movement_speed_pct",

   "item_phoenix_fire_spirits_pf_cooldown",
   "item_phoenix_fire_spirits_pf_duration",
   "item_phoenix_fire_spirits_pf_damage_per_second",
   "item_phoenix_fire_spirits_pf_attackspeed_slow",

   "item_phoenix_sun_ray_pf_cooldown",
   "item_phoenix_sun_ray_pf_hp_cost_perc_per_second",
   "item_phoenix_sun_ray_pf_base_damage",
   "item_phoenix_sun_ray_pf_hp_perc_heal",
   "item_phoenix_sun_ray_pf_beam_range",

   "item_phoenix_supernova_pf_cooldown",
   "item_phoenix_supernova_pf_damage_per_sec",
   "item_phoenix_supernova_pf_max_health_for_egg",
   "item_phoenix_supernova_pf_stun_duration",
   
}


item_pathfinder_acorn_shot_percent_cooldown = item_small_scepter_fragment
item_pathfinder_acorn_shot_bonus_damage = item_small_scepter_fragment
item_pathfinder_acorn_shot_bounce_count = item_small_scepter_fragment
item_pathfinder_acorn_shot_bounce_range = item_small_scepter_fragment
item_pathfinder_acorn_shot_debuff_duration = item_small_scepter_fragment

item_pathfinder_bushwhack_percent_cooldown = item_small_scepter_fragment
item_pathfinder_bushwhack_trap_radius = item_small_scepter_fragment
item_pathfinder_bushwhack_debuff_duration = item_small_scepter_fragment
item_pathfinder_bushwhack_total_damage = item_small_scepter_fragment

item_pathfinder_scurry_percent_cooldown = item_small_scepter_fragment
item_pathfinder_scurry_movement_speed_pct = item_small_scepter_fragment
item_pathfinder_scurry_duration = item_small_scepter_fragment
item_pathfinder_scurry_movement_evasion = item_small_scepter_fragment

item_pathfinder_sharpshooter_percent_cooldown = item_small_scepter_fragment
item_pathfinder_sharpshooter_max_damage = item_small_scepter_fragment
item_pathfinder_sharpshooter_arrow_range = item_small_scepter_fragment
item_pathfinder_sharpshooter_max_slow_debuff_duration = item_small_scepter_fragment



PURCHASABLE_SHARDS[ "npc_dota_hero_hoodwink" ] =
{
   "item_pathfinder_acorn_shot_percent_cooldown",
   "item_pathfinder_acorn_shot_bonus_damage",
   "item_pathfinder_acorn_shot_bounce_count",
   "item_pathfinder_acorn_shot_bounce_range",
   "item_pathfinder_acorn_shot_debuff_duration",

   "item_pathfinder_bushwhack_percent_cooldown",
   "item_pathfinder_bushwhack_trap_radius",
   "item_pathfinder_bushwhack_debuff_duration",
   "item_pathfinder_bushwhack_total_damage",

   "item_pathfinder_scurry_percent_cooldown",
   "item_pathfinder_scurry_movement_speed_pct",
   "item_pathfinder_scurry_duration",
   "item_pathfinder_scurry_movement_evasion",

   "item_pathfinder_sharpshooter_percent_cooldown",
   "item_pathfinder_sharpshooter_max_damage",
   "item_pathfinder_sharpshooter_arrow_range",
   "item_pathfinder_sharpshooter_max_slow_debuff_duration",
}


item_tidehunter_gush_pf_pct_cooldown = item_small_scepter_fragment
item_tidehunter_gush_pf_gush_damage = item_small_scepter_fragment
item_tidehunter_gush_pf_movement_speed_reduction = item_small_scepter_fragment
item_tidehunter_gush_pf_negative_armor = item_small_scepter_fragment
item_tidehunter_gush_pf_radius = item_small_scepter_fragment
item_tidehunter_gush_pf_debuff_duration = item_small_scepter_fragment

item_tidehunter_kraken_shell_pf_damage_reduction = item_small_scepter_fragment
item_tidehunter_kraken_shell_pf_damage_cleanse = item_small_scepter_fragment

item_tidehunter_anchor_smash_pf_pct_cooldown = item_small_scepter_fragment
-- item_tidehunter_anchor_smash_pf_attack_damage = item_small_scepter_fragment
item_tidehunter_anchor_smash_pf_damage_reduction = item_small_scepter_fragment
item_tidehunter_anchor_smash_pf_radius = item_small_scepter_fragment

item_tidehunter_ravage_pf_pct_cooldown = item_small_scepter_fragment
item_tidehunter_ravage_pf_duration = item_small_scepter_fragment
item_tidehunter_ravage_pf_damage = item_small_scepter_fragment
item_tidehunter_ravage_pf_radius = item_small_scepter_fragment


PURCHASABLE_SHARDS[ "npc_dota_hero_tidehunter" ] =
{
   "item_tidehunter_gush_pf_pct_cooldown",
   "item_tidehunter_gush_pf_gush_damage",
   "item_tidehunter_gush_pf_movement_speed_reduction",
   "item_tidehunter_gush_pf_negative_armor",
   "item_tidehunter_gush_pf_radius",
   "item_tidehunter_gush_pf_debuff_duration",

   "item_tidehunter_kraken_shell_pf_damage_reduction",
   "item_tidehunter_kraken_shell_pf_damage_cleanse",

   "item_tidehunter_anchor_smash_pf_pct_cooldown",
   -- "item_tidehunter_anchor_smash_pf_attack_damage",
   "item_tidehunter_anchor_smash_pf_damage_reduction",
   "item_tidehunter_anchor_smash_pf_radius",

   "item_tidehunter_ravage_pf_pct_cooldown",
   "item_tidehunter_ravage_pf_duration",
   "item_tidehunter_ravage_pf_damage",
   "item_tidehunter_ravage_pf_radius",
}


item_jakiro_dual_breath_lua_range = item_small_scepter_fragment
item_jakiro_dual_breath_lua_burn_damage = item_small_scepter_fragment
item_jakiro_dual_breath_lua_slow_movement_speed_pct = item_small_scepter_fragment
item_jakiro_dual_breath_lua_slow_attack_speed_pct = item_small_scepter_fragment
item_jakiro_dual_breath_lua_duration = item_small_scepter_fragment
item_jakiro_dual_breath_lua_pct_cooldown = item_small_scepter_fragment

item_jakiro_ice_path_lua_duration = item_small_scepter_fragment
item_jakiro_ice_path_lua_damage = item_small_scepter_fragment
item_jakiro_ice_path_lua_range = item_small_scepter_fragment
item_jakiro_ice_path_lua_pct_cooldown = item_small_scepter_fragment

item_jakiro_liquid_fire_lua_slow_attack_speed_pct = item_small_scepter_fragment
item_jakiro_liquid_fire_lua_radius = item_small_scepter_fragment
item_jakiro_liquid_fire_lua_damage = item_small_scepter_fragment
item_jakiro_liquid_fire_lua_duration = item_small_scepter_fragment
-- item_jakiro_liquid_fire_lua_range = item_small_scepter_fragment

item_jakiro_macropyre_lua_damage = item_small_scepter_fragment
item_jakiro_macropyre_lua_cast_range = item_small_scepter_fragment
item_jakiro_macropyre_lua_duration = item_small_scepter_fragment
item_jakiro_macropyre_lua_pct_cooldown = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_jakiro" ] =
{
   "item_jakiro_dual_breath_lua_range",
   "item_jakiro_dual_breath_lua_burn_damage",
   "item_jakiro_dual_breath_lua_slow_movement_speed_pct",
   "item_jakiro_dual_breath_lua_slow_attack_speed_pct",
   "item_jakiro_dual_breath_lua_duration",
   "item_jakiro_dual_breath_lua_pct_cooldown",

   "item_jakiro_ice_path_lua_duration",
   "item_jakiro_ice_path_lua_damage",
   "item_jakiro_ice_path_lua_range",
   "item_jakiro_ice_path_lua_pct_cooldown",

   "item_jakiro_liquid_fire_lua_slow_attack_speed_pct",
   "item_jakiro_liquid_fire_lua_radius",
   "item_jakiro_liquid_fire_lua_damage",
   "item_jakiro_liquid_fire_lua_duration",
   -- "item_jakiro_liquid_fire_lua_range",

   "item_jakiro_macropyre_lua_damage",
   "item_jakiro_macropyre_lua_cast_range",
   "item_jakiro_macropyre_lua_duration",
   "item_jakiro_macropyre_lua_pct_cooldown",

}

item_axe_battle_hunger_lua_duration = item_small_scepter_fragment
item_axe_battle_hunger_lua_slow = item_small_scepter_fragment
item_axe_battle_hunger_lua_speed_bonus = item_small_scepter_fragment
item_axe_battle_hunger_lua_damage_per_second = item_small_scepter_fragment
item_axe_battle_hunger_lua_radius = item_small_scepter_fragment
item_axe_battle_hunger_lua_pct_cooldown = item_small_scepter_fragment   

item_axe_berserkers_call_lua_radius = item_small_scepter_fragment   
item_axe_berserkers_call_lua_bonus_armor = item_small_scepter_fragment   
item_axe_berserkers_call_lua_duration = item_small_scepter_fragment   
item_axe_berserkers_call_lua_pct_cooldown = item_small_scepter_fragment   

item_axe_counter_helix_lua_trigger_chance = item_small_scepter_fragment   
item_axe_counter_helix_lua_damage = item_small_scepter_fragment   

item_axe_culling_blade_lua_kill_threshold = item_small_scepter_fragment   
item_axe_culling_blade_lua_damage = item_small_scepter_fragment   
item_axe_culling_blade_lua_speed_bonus = item_small_scepter_fragment   
item_axe_culling_blade_lua_atk_speed_bonus_tooltip = item_small_scepter_fragment   
item_axe_culling_blade_lua_speed_duration = item_small_scepter_fragment   
item_axe_culling_blade_lua_pct_cooldown = item_small_scepter_fragment   

PURCHASABLE_SHARDS[ "npc_dota_hero_axe" ] =
{
   "item_axe_battle_hunger_lua_duration",
   "item_axe_battle_hunger_lua_slow",
   "item_axe_battle_hunger_lua_speed_bonus",
   "item_axe_battle_hunger_lua_damage_per_second",
   "item_axe_battle_hunger_lua_radius",
   "item_axe_battle_hunger_lua_pct_cooldown",

   "item_axe_berserkers_call_lua_radius",   
   "item_axe_berserkers_call_lua_bonus_armor",
   "item_axe_berserkers_call_lua_duration",   
   "item_axe_berserkers_call_lua_pct_cooldown",

   "item_axe_counter_helix_lua_trigger_chance",
   "item_axe_counter_helix_lua_damage",

   "item_axe_culling_blade_lua_kill_threshold",
   "item_axe_culling_blade_lua_damage",
   "item_axe_culling_blade_lua_speed_bonus",
   "item_axe_culling_blade_lua_atk_speed_bonus_tooltip",
   "item_axe_culling_blade_lua_speed_duration",
   "item_axe_culling_blade_lua_pct_cooldown",
}

-----------------

item_pathfinder_nevermore_shadowraze_damage_value = item_small_scepter_fragment
item_pathfinder_nevermore_shadowraze_stack_damage_value = item_small_scepter_fragment
item_pathfinder_nevermore_shadowraze_cooldown_value = item_small_scepter_fragment

item_pathfinder_nevermore_necromastery_damage_per_soul = item_small_scepter_fragment
item_pathfinder_nevermore_necromastery_max_souls = item_small_scepter_fragment
-- item_pathfinder_nevermore_necromastery_souls_per_kill = item_small_scepter_fragment   

item_pathfinder_nevermore_dark_lord_aura_radius = item_small_scepter_fragment   
item_pathfinder_nevermore_dark_lord_armor_reduction = item_small_scepter_fragment   

item_pathfinder_nevermore_requiem_damage = item_small_scepter_fragment   
item_pathfinder_nevermore_requiem_travel_distance = item_small_scepter_fragment   
item_pathfinder_nevermore_requiem_ms_slow_pct = item_small_scepter_fragment   
-- item_pathfinder_nevermore_requiem_requiem_slow_duration = item_small_scepter_fragment   
item_pathfinder_nevermore_requiem_pct_cooldown = item_small_scepter_fragment   

PURCHASABLE_SHARDS[ "npc_dota_hero_nevermore" ] =
{
   "item_pathfinder_nevermore_shadowraze_damage_value",
   "item_pathfinder_nevermore_shadowraze_stack_damage_value",
   "item_pathfinder_nevermore_shadowraze_cooldown_value",

   "item_pathfinder_nevermore_necromastery_damage_per_soul",
   "item_pathfinder_nevermore_necromastery_max_souls",
   -- "item_pathfinder_nevermore_necromastery_souls_per_kill",

   "item_pathfinder_nevermore_dark_lord_aura_radius",   
   "item_pathfinder_nevermore_dark_lord_armor_reduction",

   "item_pathfinder_nevermore_requiem_damage",   
   "item_pathfinder_nevermore_requiem_travel_distance",
   "item_pathfinder_nevermore_requiem_ms_slow_pct",

   -- "item_pathfinder_nevermore_requiem_requiem_slow_duration",
   "item_pathfinder_nevermore_requiem_pct_cooldown",
}

--LEGION COMMANDA
item_ogre_magi_fireblast_lua_pct_cooldown = item_small_scepter_fragment
item_ogre_magi_fireblast_lua_stun_duration = item_small_scepter_fragment
item_ogre_magi_fireblast_lua_fireblast_damage = item_small_scepter_fragment

item_ogre_magi_ignite_lua_pct_cooldown = item_small_scepter_fragment
item_ogre_magi_ignite_lua_burn_damage = item_small_scepter_fragment
item_ogre_magi_ignite_lua_slow_movement_speed_pct = item_small_scepter_fragment
item_ogre_magi_ignite_lua_duration = item_small_scepter_fragment

item_ogre_magi_bloodlust_lua_pct_cooldown = item_small_scepter_fragment
item_ogre_magi_bloodlust_lua_bonus_movement_speed = item_small_scepter_fragment
item_ogre_magi_bloodlust_lua_bonus_attack_speed = item_small_scepter_fragment
item_ogre_magi_bloodlust_lua_duration = item_small_scepter_fragment

item_ogre_magi_multicast_lua_multicast_3_times = item_small_scepter_fragment
item_ogre_magi_multicast_lua_multicast_4_times = item_small_scepter_fragment
item_ogre_magi_multicast_lua_bonus_cast_range = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_ogre_magi" ] =
{
   "item_ogre_magi_fireblast_lua_pct_cooldown",
   "item_ogre_magi_fireblast_lua_stun_duration",
   "item_ogre_magi_fireblast_lua_fireblast_damage",

   "item_ogre_magi_ignite_lua_pct_cooldown",
   "item_ogre_magi_ignite_lua_burn_damage",
   "item_ogre_magi_ignite_lua_slow_movement_speed_pct",
   "item_ogre_magi_ignite_lua_duration",

   "item_ogre_magi_bloodlust_lua_pct_cooldown",   
   "item_ogre_magi_bloodlust_lua_bonus_movement_speed",

   "item_ogre_magi_bloodlust_lua_bonus_attack_speed",      
   "item_ogre_magi_bloodlust_lua_duration",

   "item_ogre_magi_multicast_lua_multicast_3_times",   
   "item_ogre_magi_multicast_lua_multicast_4_times",
   "item_ogre_magi_multicast_lua_bonus_cast_range",
   
}


--LEGION COMMANDA
item_pathfinder_lc_arrows_arrows_radius = item_small_scepter_fragment
item_pathfinder_lc_arrows_arrows_base_damage = item_small_scepter_fragment
item_pathfinder_lc_arrows_arrows_damage_per_unit = item_small_scepter_fragment
item_pathfinder_lc_arrows_arrows_movespeed_duration = item_small_scepter_fragment
item_pathfinder_lc_arrows_cooldown = item_small_scepter_fragment

item_pathfinder_lc_press_press_regen = item_small_scepter_fragment
item_pathfinder_lc_press_press_attack = item_small_scepter_fragment
item_pathfinder_lc_press_press_duration = item_small_scepter_fragment
item_pathfinder_lc_press_cooldown = item_small_scepter_fragment

item_pathfinder_lc_moment_moment_chance = item_small_scepter_fragment
item_pathfinder_lc_moment_moment_lifesteal = item_small_scepter_fragment

item_pathfinder_lc_duel_duel_duration = item_small_scepter_fragment
item_pathfinder_lc_duel_duel_hero_damage = item_small_scepter_fragment
item_pathfinder_lc_duel_cooldown = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_legion_commander" ] =
{
   "item_pathfinder_lc_arrows_arrows_radius",
   "item_pathfinder_lc_arrows_arrows_base_damage",
   "item_pathfinder_lc_arrows_arrows_damage_per_unit",
   "item_pathfinder_lc_arrows_arrows_movespeed_duration",
   "item_pathfinder_lc_arrows_cooldown",

   "item_pathfinder_lc_press_press_regen",
   "item_pathfinder_lc_press_press_attack",
   "item_pathfinder_lc_press_press_duration",
   "item_pathfinder_lc_press_cooldown",

   "item_pathfinder_lc_moment_moment_chance",   
   "item_pathfinder_lc_moment_moment_lifesteal",

   "item_pathfinder_lc_duel_duel_duration",   
   "item_pathfinder_lc_duel_duel_hero_damage",
   "item_pathfinder_lc_duel_cooldown",
}

--Phantom Ass
item_phantom_assassin_stifling_dagger_lua_attack_factor = item_small_scepter_fragment
item_phantom_assassin_stifling_dagger_lua_duration = item_small_scepter_fragment
item_phantom_assassin_stifling_dagger_lua_base_damage = item_small_scepter_fragment

item_phantom_assassin_coup_de_grace_lua_crit_chance = item_small_scepter_fragment
item_phantom_assassin_coup_de_grace_lua_crit_bonus = item_small_scepter_fragment

item_phantom_assassin_phantom_strike_lua_bonus_attack_speed = item_small_scepter_fragment
item_phantom_assassin_phantom_strike_lua_duration = item_small_scepter_fragment
item_phantom_assassin_phantom_strike_lua_range = item_small_scepter_fragment

item_phantom_assassin_blur_lua_bonus_evasion = item_small_scepter_fragment
item_phantom_assassin_blur_lua_duration = item_small_scepter_fragment
item_phantom_assassin_blur_lua_cooldown = item_small_scepter_fragment



PURCHASABLE_SHARDS[ "npc_dota_hero_phantom_assassin" ] =
{
   "item_phantom_assassin_stifling_dagger_lua_attack_factor",
   "item_phantom_assassin_stifling_dagger_lua_duration",
   "item_phantom_assassin_stifling_dagger_lua_base_damage",

   "item_phantom_assassin_coup_de_grace_lua_crit_chance",
   "item_phantom_assassin_coup_de_grace_lua_crit_bonus",

   "item_phantom_assassin_phantom_strike_lua_bonus_attack_speed",
   "item_phantom_assassin_phantom_strike_lua_duration",
   "item_phantom_assassin_phantom_strike_lua_range",

   "item_phantom_assassin_blur_lua_bonus_evasion",   
   "item_phantom_assassin_blur_lua_duration",
   "item_phantom_assassin_blur_lua_cooldown",
}

--Windranger
item_windranger_shackleshot_lua_stun_duration = item_small_scepter_fragment
item_windranger_shackleshot_lua_shackle_distance = item_small_scepter_fragment
item_windranger_shackleshot_lua_shackle_angle = item_small_scepter_fragment

item_windranger_windrun_lua_duration = item_small_scepter_fragment
item_windranger_windrun_lua_movespeed_bonus_pct = item_small_scepter_fragment

item_windranger_powershot_lua_powershot_damage = item_small_scepter_fragment

item_windranger_focus_fire_lua_bonus_attack_speed = item_small_scepter_fragment
item_windranger_focus_fire_lua_cooldown = item_small_scepter_fragment


PURCHASABLE_SHARDS[ "npc_dota_hero_windrunner" ] =
{
   "item_windranger_shackleshot_lua_stun_duration",
   "item_windranger_shackleshot_lua_shackle_distance",
   "item_windranger_shackleshot_lua_shackle_angle",
   "item_windranger_windrun_lua_duration",
   "item_windranger_windrun_lua_movespeed_bonus_pct",
   "item_windranger_powershot_lua_powershot_damage",
   "item_windranger_focus_fire_lua_bonus_attack_speed",
   "item_windranger_focus_fire_lua_cooldown",
}

--Venomancer
item_venomancer_venomous_gale_datadriven_tick_damage = item_small_scepter_fragment
item_venomancer_venomous_gale_datadriven_distance = item_small_scepter_fragment
item_venomancer_venomous_gale_datadriven_movement_slow = item_small_scepter_fragment
item_venomancer_venomous_gale_datadriven_cooldown = item_small_scepter_fragment
item_venomancer_plague_ward_datadriven_duration = item_small_scepter_fragment
item_venomancer_plague_ward_datadriven_attack_speed = item_small_scepter_fragment
item_venomancer_poison_sting_datadriven_damage = item_small_scepter_fragment
item_venomancer_poison_sting_datadriven_movement_speed = item_small_scepter_fragment
item_venomancer_poison_nova_datadriven_duration = item_small_scepter_fragment
item_venomancer_poison_nova_datadriven_cooldown = item_small_scepter_fragment
item_venomancer_poison_nova_datadriven_radius = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_venomancer" ] =
{
   "item_venomancer_venomous_gale_datadriven_tick_damage",
   "item_venomancer_venomous_gale_datadriven_distance",
   "item_venomancer_venomous_gale_datadriven_movement_slow",
   "item_venomancer_venomous_gale_datadriven_cooldown",   
   "item_venomancer_plague_ward_datadriven_duration",
   "item_venomancer_plague_ward_datadriven_attack_speed",
   "item_venomancer_poison_sting_datadriven_damage",
   "item_venomancer_poison_sting_datadriven_movement_speed",   
   "item_venomancer_poison_nova_datadriven_duration",
   "item_venomancer_poison_nova_datadriven_cooldown",
   "item_venomancer_poison_nova_datadriven_radius",
}

--Juggernaut
item_pathfinder_juggernaut_blade_fury_damage = item_small_scepter_fragment
item_pathfinder_juggernaut_blade_fury_radius = item_small_scepter_fragment
item_pathfinder_juggernaut_blade_fury_percent_cooldown = item_small_scepter_fragment
item_pathfinder_juggernaut_blade_fury_duration = item_small_scepter_fragment
item_pathfinder_juggernaut_summon_healing_ward_percent_cooldown = item_small_scepter_fragment
item_pathfinder_juggernaut_summon_healing_ward_duration = item_small_scepter_fragment
item_pathfinder_juggernaut_summon_healing_ward_max_health_regen = item_small_scepter_fragment
item_pathfinder_juggernaut_summon_healing_ward_radius = item_small_scepter_fragment
item_pathfinder_juggernaut_blade_dance_crit_chance = item_small_scepter_fragment
item_pathfinder_juggernaut_blade_dance_crit_mult = item_small_scepter_fragment
item_pathfinder_juggernaut_omni_slash_cooldown = item_small_scepter_fragment
item_pathfinder_juggernaut_omni_slash_bounce_radius = item_small_scepter_fragment
item_pathfinder_juggernaut_omni_slash_duration = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_juggernaut" ] =
{
   "item_pathfinder_juggernaut_blade_fury_damage",
   "item_pathfinder_juggernaut_blade_fury_radius",
   "item_pathfinder_juggernaut_blade_fury_percent_cooldown",
   "item_pathfinder_juggernaut_blade_fury_duration",
   "item_pathfinder_juggernaut_summon_healing_ward_percent_cooldown",
   "item_pathfinder_juggernaut_summon_healing_ward_duration",
   "item_pathfinder_juggernaut_summon_healing_ward_max_health_regen",
   "item_pathfinder_juggernaut_summon_healing_ward_radius",
   "item_pathfinder_juggernaut_blade_dance_crit_chance",
   "item_pathfinder_juggernaut_blade_dance_crit_mult",
   "item_pathfinder_juggernaut_omni_slash_cooldown",
   "item_pathfinder_juggernaut_omni_slash_bounce_radius",
   "item_pathfinder_juggernaut_omni_slash_duration",
}

--Disruptor
item_aghsfort_disruptor_thunder_strike_flat_strikes = item_small_scepter_fragment
item_aghsfort_disruptor_thunder_strike_flat_strike_damage = item_small_scepter_fragment
item_aghsfort_disruptor_glimpse_flat_bonus_damage = item_small_scepter_fragment
item_aghsfort_disruptor_glimpse_flat_cast_radius = item_small_scepter_fragment
item_aghsfort_disruptor_kinetic_field_flat_duration = item_small_scepter_fragment
item_aghsfort_disruptor_kinetic_field_formation_time = item_small_scepter_fragment
item_aghsfort_disruptor_static_storm_flat_duration = item_small_scepter_fragment
item_aghsfort_disruptor_static_storm_flat_damage_max = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_disruptor" ] =
{
   "item_aghsfort_disruptor_thunder_strike_flat_strikes",
   "item_aghsfort_disruptor_thunder_strike_flat_strike_damage",
   "item_aghsfort_disruptor_glimpse_flat_bonus_damage",
   "item_aghsfort_disruptor_glimpse_flat_cast_radius",
   "item_aghsfort_disruptor_kinetic_field_flat_duration",
   "item_aghsfort_disruptor_kinetic_field_formation_time",
   "item_aghsfort_disruptor_static_storm_flat_duration",
   "item_aghsfort_disruptor_static_storm_flat_damage_max",
}

--Magnus
item_aghsfort_magnataur_shockwave_flat_damage = item_small_scepter_fragment
item_aghsfort_magnataur_shockwave_pct_mana_cost = item_small_scepter_fragment
item_aghsfort_magnataur_empower_flat_damage = item_small_scepter_fragment
item_aghsfort_magnataur_empower_flat_cleave = item_small_scepter_fragment
item_aghsfort_magnataur_skewer_flat_damage = item_small_scepter_fragment
item_aghsfort_magnataur_skewer_pct_cooldown = item_small_scepter_fragment
item_aghsfort_magnataur_reverse_polarity_flat_damage = item_small_scepter_fragment
item_aghsfort_magnataur_reverse_polarity_flat_radius = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_magnataur" ] =
{
   "item_aghsfort_magnataur_shockwave_flat_damage",
   "item_aghsfort_magnataur_shockwave_pct_mana_cost",
   "item_aghsfort_magnataur_empower_flat_damage",
   "item_aghsfort_magnataur_empower_flat_cleave",
   "item_aghsfort_magnataur_skewer_flat_damage",
   "item_aghsfort_magnataur_skewer_pct_cooldown",
   "item_aghsfort_magnataur_reverse_polarity_flat_damage",
   "item_aghsfort_magnataur_reverse_polarity_flat_radius",
}

--Mars
item_aghsfort_mars_spear_flat_damage = item_small_scepter_fragment
item_aghsfort_mars_spear_flat_stun_duration = item_small_scepter_fragment
item_aghsfort_mars_gods_rebuke_percent_cooldown = item_small_scepter_fragment
item_aghsfort_mars_gods_rebuke_flat_crit_mult = item_small_scepter_fragment
item_aghsfort_mars_bulwark_damage_reduction_front = item_small_scepter_fragment
item_aghsfort_mars_bulwark_active_duration = item_small_scepter_fragment
item_aghsfort_mars_arena_of_blood_duration = item_small_scepter_fragment
item_aghsfort_mars_arena_of_blood_spear_damage = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_mars" ] =
{
   "item_aghsfort_mars_spear_flat_damage",
   "item_aghsfort_mars_spear_flat_stun_duration",
   "item_aghsfort_mars_gods_rebuke_percent_cooldown",
   "item_aghsfort_mars_gods_rebuke_flat_crit_mult",
   "item_aghsfort_mars_bulwark_damage_reduction_front",
   "item_aghsfort_mars_bulwark_active_duration",
   "item_aghsfort_mars_arena_of_blood_duration",
   "item_aghsfort_mars_arena_of_blood_spear_damage",
}

--Omni
item_aghsfort_omniknight_purification_manacost = item_small_scepter_fragment
item_aghsfort_omniknight_purification_flat_heal = item_small_scepter_fragment
item_aghsfort_omniknight_repel_flat_duration = item_small_scepter_fragment
item_aghsfort_omniknight_repel_flat_damage_reduction = item_small_scepter_fragment
item_aghsfort_omniknight_degen_aura_flat_radius = item_small_scepter_fragment
item_aghsfort_omniknight_degen_aura_flat_move_speed_bonus = item_small_scepter_fragment
item_aghsfort_omniknight_guardian_angel_flat_duration = item_small_scepter_fragment
item_aghsfort_omniknight_guardian_angel_cooldown = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_omniknight" ] =
{
   "item_aghsfort_omniknight_purification_manacost",
   "item_aghsfort_omniknight_purification_flat_heal",
   "item_aghsfort_omniknight_repel_flat_duration",
   "item_aghsfort_omniknight_repel_flat_damage_reduction",
   "item_aghsfort_omniknight_degen_aura_flat_radius",
   "item_aghsfort_omniknight_degen_aura_flat_move_speed_bonus",
   "item_aghsfort_omniknight_guardian_angel_flat_duration",
   "item_aghsfort_omniknight_guardian_angel_cooldown",
}

-- Queen Of Pain
item_aghsfort_queenofpain_shadow_strike_strike_damage = item_small_scepter_fragment
item_aghsfort_queenofpain_shadow_strike_dot_damage = item_small_scepter_fragment
item_aghsfort_queenofpain_blink_percent_cooldown = item_small_scepter_fragment
item_aghsfort_queenofpain_blink_range = item_small_scepter_fragment
item_aghsfort_queenofpain_scream_of_pain_damage = item_small_scepter_fragment
item_aghsfort_queenofpain_scream_of_pain_radius = item_small_scepter_fragment
item_aghsfort_queenofpain_sonic_wave_percent_cooldown = item_small_scepter_fragment
item_aghsfort_queenofpain_sonic_wave_damage = item_small_scepter_fragment


PURCHASABLE_SHARDS[ "npc_dota_hero_queenofpain" ] =
{
   "item_aghsfort_queenofpain_shadow_strike_strike_damage",
   "item_aghsfort_queenofpain_shadow_strike_dot_damage",
   "item_aghsfort_queenofpain_blink_percent_cooldown",
   "item_aghsfort_queenofpain_blink_range",
   "item_aghsfort_queenofpain_scream_of_pain_damage",
   "item_aghsfort_queenofpain_scream_of_pain_radius",
   "item_aghsfort_queenofpain_sonic_wave_percent_cooldown",
   "item_aghsfort_queenofpain_sonic_wave_damage",
}

--Slark
item_aghsfort_slark_dark_pact_cooldown = item_small_scepter_fragment
item_aghsfort_slark_dark_pact_total_damage = item_small_scepter_fragment
item_aghsfort_slark_pounce_distance = item_small_scepter_fragment
item_aghsfort_slark_pounce_damage = item_small_scepter_fragment
item_aghsfort_slark_essence_shift_agi_gain = item_small_scepter_fragment
item_aghsfort_slark_essence_shift_max_stacks = item_small_scepter_fragment
item_aghsfort_slark_shadow_dance_duration = item_small_scepter_fragment
item_aghsfort_slark_shadow_dance_bonus_bonus_regen_pct = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_slark" ] =
{
   "item_aghsfort_slark_dark_pact_cooldown",
   "item_aghsfort_slark_dark_pact_total_damage",
   "item_aghsfort_slark_pounce_distance",
   "item_aghsfort_slark_pounce_damage",
   "item_aghsfort_slark_essence_shift_agi_gain",
   "item_aghsfort_slark_essence_shift_max_stacks",
   "item_aghsfort_slark_shadow_dance_duration",
   "item_aghsfort_slark_shadow_dance_bonus_bonus_regen_pct",
}

--Snapfire
item_aghsfort_snapfire_scatterblast_flat_damage = item_small_scepter_fragment
item_aghsfort_snapfire_scatterblast_pct_cooldown = item_small_scepter_fragment
item_aghsfort_snapfire_firesnap_cookie_flat_impact_damage = item_small_scepter_fragment
item_aghsfort_snapfire_firesnap_cookie_flat_stun_duration = item_small_scepter_fragment
item_aghsfort_snapfire_lil_shredder_flat_damage = item_small_scepter_fragment
item_aghsfort_snapfire_lil_shredder_flat_attacks = item_small_scepter_fragment
item_aghsfort_snapfire_mortimer_kisses_flat_projectile_count = item_small_scepter_fragment
item_aghsfort_snapfire_mortimer_kisses_flat_burn_damage = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_snapfire" ] =
{
   "item_aghsfort_snapfire_scatterblast_flat_damage",
   "item_aghsfort_snapfire_scatterblast_pct_cooldown",
   "item_aghsfort_snapfire_firesnap_cookie_flat_impact_damage",
   "item_aghsfort_snapfire_firesnap_cookie_flat_stun_duration",
   "item_aghsfort_snapfire_lil_shredder_flat_damage",
   "item_aghsfort_snapfire_lil_shredder_flat_attacks",
   "item_aghsfort_snapfire_mortimer_kisses_flat_projectile_count",
   "item_aghsfort_snapfire_mortimer_kisses_flat_burn_damage",
}

--Sniper
item_aghsfort_sniper_shrapnel_flat_damage = item_small_scepter_fragment
item_aghsfort_sniper_shrapnel_flat_radius = item_small_scepter_fragment
item_aghsfort_sniper_shrapnel_duration = item_small_scepter_fragment
item_aghsfort_sniper_headshot_flat_damage = item_small_scepter_fragment
item_aghsfort_sniper_headshot_proc_chance = item_small_scepter_fragment
item_aghsfort_sniper_take_aim_flat_bonus_attack_range = item_small_scepter_fragment
item_aghsfort_sniper_assassinate_flat_damage = item_small_scepter_fragment
item_aghsfort_sniper_assassinate_percent_cast_point = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_sniper" ] =
{
   "item_aghsfort_sniper_shrapnel_flat_damage",
   "item_aghsfort_sniper_shrapnel_flat_radius",
   "item_aghsfort_sniper_shrapnel_duration",
   "item_aghsfort_sniper_headshot_flat_damage",
   "item_aghsfort_sniper_headshot_proc_chance",
   "item_aghsfort_sniper_take_aim_flat_bonus_attack_range",
   "item_aghsfort_sniper_assassinate_flat_damage",
   "item_aghsfort_sniper_assassinate_percent_cast_point",
}

--Templar Assassin
item_aghsfort_templar_assassin_refraction_instances = item_small_scepter_fragment
item_aghsfort_templar_assassin_refraction_bonus_damage = item_small_scepter_fragment
item_aghsfort_templar_assassin_meld_bonus_damage = item_small_scepter_fragment
item_aghsfort_templar_assassin_meld_bonus_armor = item_small_scepter_fragment
item_aghsfort_templar_assassin_psi_blades_bonus_attack_range = item_small_scepter_fragment
item_aghsfort_templar_assassin_psi_blades_attack_spill_width = item_small_scepter_fragment
item_aghsfort_templar_assassin_psionic_trap_max_traps = item_small_scepter_fragment
item_aghsfort_templar_assassin_psionic_trap_trap_damage = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_templar_assassin" ] =
{
   "item_aghsfort_templar_assassin_refraction_instances",
   "item_aghsfort_templar_assassin_refraction_bonus_damage",
   "item_aghsfort_templar_assassin_meld_bonus_damage",
   "item_aghsfort_templar_assassin_meld_bonus_armor",
   "item_aghsfort_templar_assassin_psi_blades_bonus_attack_range",
   "item_aghsfort_templar_assassin_psi_blades_attack_spill_width",
   "item_aghsfort_templar_assassin_psionic_trap_max_traps",
   "item_aghsfort_templar_assassin_psionic_trap_trap_damage",
}

--Tusk
item_aghsfort_tusk_ice_shards_flat_damage = item_small_scepter_fragment
item_aghsfort_tusk_ice_shards_flat_shard_duration = item_small_scepter_fragment
item_aghsfort_tusk_snowball_flat_snowball_damage = item_small_scepter_fragment
item_aghsfort_tusk_snowball_flat_stun_duration = item_small_scepter_fragment
item_aghsfort_tusk_tag_team_flat_damage = item_small_scepter_fragment
item_aghsfort_tusk_tag_team_pct_cooldown = item_small_scepter_fragment
item_aghsfort_tusk_walrus_punch_pct_cooldown = item_small_scepter_fragment
item_aghsfort_tusk_walrus_punch_flat_crit_multiplier = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_tusk" ] =
{
   "item_aghsfort_tusk_ice_shards_flat_damage",
   "item_aghsfort_tusk_ice_shards_flat_shard_duration",
   "item_aghsfort_tusk_snowball_flat_snowball_damage",
   "item_aghsfort_tusk_snowball_flat_stun_duration",
   "item_aghsfort_tusk_tag_team_flat_damage",
   "item_aghsfort_tusk_tag_team_pct_cooldown",
   "item_aghsfort_tusk_walrus_punch_pct_cooldown",
   "item_aghsfort_tusk_walrus_punch_flat_crit_multiplier",
}

--Ursa
item_aghsfort_ursa_earthshock_flat_damage = item_small_scepter_fragment
item_aghsfort_ursa_earthshock_flat_radius = item_small_scepter_fragment
item_aghsfort_ursa_overpower_flat_max_attacks = item_small_scepter_fragment
item_aghsfort_ursa_overpower_percent_cooldown = item_small_scepter_fragment
item_aghsfort_ursa_fury_swipes_flat_damage_per_stack = item_small_scepter_fragment
item_aghsfort_ursa_fury_swipes_flat_max_swipe_stack = item_small_scepter_fragment
item_aghsfort_ursa_enrage_flat_duration = item_small_scepter_fragment
item_aghsfort_ursa_enrage_percent_cooldown = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_ursa" ] =
{
   "item_aghsfort_ursa_earthshock_flat_damage",
   "item_aghsfort_ursa_earthshock_flat_radius",
   "item_aghsfort_ursa_overpower_flat_max_attacks",
   "item_aghsfort_ursa_overpower_percent_cooldown",
   "item_aghsfort_ursa_fury_swipes_flat_damage_per_stack",
   "item_aghsfort_ursa_fury_swipes_flat_max_swipe_stack",
   "item_aghsfort_ursa_enrage_flat_duration",
   "item_aghsfort_ursa_enrage_percent_cooldown",
}

--Viper
item_aghsfort_viper_poison_attack_damage = item_small_scepter_fragment
item_aghsfort_viper_poison_attack_magic_resistance = item_small_scepter_fragment
item_aghsfort_viper_nethertoxin_max_damage = item_small_scepter_fragment
item_aghsfort_viper_nethertoxin_radius = item_small_scepter_fragment
item_aghsfort_viper_corrosive_skin_bonus_magic_resistance = item_small_scepter_fragment
item_aghsfort_viper_corrosive_skin_damage = item_small_scepter_fragment
item_aghsfort_viper_viper_strike_duration = item_small_scepter_fragment
item_aghsfort_viper_viper_strike_damage = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_viper" ] =
{
   "item_aghsfort_viper_poison_attack_damage",
   "item_aghsfort_viper_poison_attack_magic_resistance",
   "item_aghsfort_viper_nethertoxin_max_damage",
   "item_aghsfort_viper_nethertoxin_radius",
   "item_aghsfort_viper_corrosive_skin_bonus_magic_resistance",
   "item_aghsfort_viper_corrosive_skin_damage",
   "item_aghsfort_viper_viper_strike_duration",
   "item_aghsfort_viper_viper_strike_damage",
}

--Weaver
item_aghsfort_weaver_the_swarm_flat_armor_reduction = item_small_scepter_fragment
item_aghsfort_weaver_the_swarm_flat_damage = item_small_scepter_fragment
item_aghsfort_weaver_the_swarm_percent_cooldown = item_small_scepter_fragment
item_aghsfort_weaver_shukuchi_flat_damage = item_small_scepter_fragment
item_aghsfort_weaver_shukuchi_duration = item_small_scepter_fragment
item_aghsfort_weaver_geminate_attack_cooldown = item_small_scepter_fragment
item_aghsfort_weaver_geminate_attack_flat_bonus_damage = item_small_scepter_fragment
item_aghsfort_weaver_time_lapse_cooldown = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_weaver" ] =
{
   "item_aghsfort_weaver_the_swarm_flat_armor_reduction",
   "item_aghsfort_weaver_the_swarm_flat_damage",
   "item_aghsfort_weaver_the_swarm_percent_cooldown",
   "item_aghsfort_weaver_shukuchi_flat_damage",
   "item_aghsfort_weaver_shukuchi_duration",
   "item_aghsfort_weaver_geminate_attack_cooldown",
   "item_aghsfort_weaver_geminate_attack_flat_bonus_damage",
   "item_aghsfort_weaver_time_lapse_cooldown",
}

--Winter Wyvern
item_aghsfort_winter_wyvern_arctic_burn_flat_damage = item_small_scepter_fragment
item_aghsfort_winter_wyvern_arctic_burn_flat_duration = item_small_scepter_fragment
item_aghsfort_winter_wyvern_splinter_blast_flat_radius = item_small_scepter_fragment
item_aghsfort_winter_wyvern_splinter_blast_flat_damage = item_small_scepter_fragment
item_aghsfort_winter_wyvern_cold_embrace_flat_heal_percentage = item_small_scepter_fragment
item_aghsfort_winter_wyvern_cold_embrace_pct_cooldown = item_small_scepter_fragment
item_aghsfort_winter_wyvern_winters_curse_flat_duration = item_small_scepter_fragment
item_aghsfort_winter_wyvern_winters_curse_pct_cooldown = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_winter_wyvern" ] =
{
   "item_aghsfort_winter_wyvern_arctic_burn_flat_damage",
   "item_aghsfort_winter_wyvern_arctic_burn_flat_duration",
   "item_aghsfort_winter_wyvern_splinter_blast_flat_radius",
   "item_aghsfort_winter_wyvern_splinter_blast_flat_damage",
   "item_aghsfort_winter_wyvern_cold_embrace_flat_heal_percentage",
   "item_aghsfort_winter_wyvern_cold_embrace_pct_cooldown",
   "item_aghsfort_winter_wyvern_winters_curse_flat_duration",
   "item_aghsfort_winter_wyvern_winters_curse_pct_cooldown",
}

--WD
item_aghsfort_witch_doctor_voodoo_restoration_manacost = item_small_scepter_fragment
item_aghsfort_witch_doctor_voodoo_restoration_flat_heal = item_small_scepter_fragment
item_aghsfort_witch_doctor_paralyzing_cask_flat_damage = item_small_scepter_fragment
item_aghsfort_witch_doctor_paralyzing_cask_flat_bounces = item_small_scepter_fragment
item_aghsfort_witch_doctor_maledict_flat_ticks = item_small_scepter_fragment
item_aghsfort_witch_doctor_maledict_flat_max_bonus_damage = item_small_scepter_fragment
item_aghsfort_witch_doctor_death_ward_flat_damage = item_small_scepter_fragment
item_aghsfort_witch_doctor_death_ward_flat_channel_duration = item_small_scepter_fragment

PURCHASABLE_SHARDS[ "npc_dota_hero_witch_doctor" ] =
{
   "item_aghsfort_witch_doctor_voodoo_restoration_manacost",
   "item_aghsfort_witch_doctor_voodoo_restoration_flat_heal",
   "item_aghsfort_witch_doctor_paralyzing_cask_flat_damage",
   "item_aghsfort_witch_doctor_paralyzing_cask_flat_bounces",
   "item_aghsfort_witch_doctor_maledict_flat_ticks",
   "item_aghsfort_witch_doctor_maledict_flat_max_bonus_damage",
   "item_aghsfort_witch_doctor_death_ward_flat_damage",
   "item_aghsfort_witch_doctor_death_ward_flat_channel_duration",
}