local Juggernaut =
{
	{
		description = "pathfinder_juggernaut_blade_fury_damage",
		ability_name = "pathfinder_juggernaut_blade_fury",
		special_value_name = "blade_fury_damage",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 20,
	},

	-- {
	-- 	description = "aghsfort_ursa_earthshock_percent_mana_cost",
	-- 	ability_name = "aghsfort_ursa_earthshock",
	-- 	special_value_name = "mana_cost",
	-- 	operator = MINOR_ABILITY_UPGRADE_OP_MUL,
	-- 	value = 15,
	-- },

	{
		description = "pathfinder_juggernaut_blade_fury_radius",
		ability_name = "pathfinder_juggernaut_blade_fury",
		special_value_name = "blade_fury_radius",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 35,
	},

	
	{
		description = "pathfinder_juggernaut_blade_fury_percent_cooldown",
		ability_name = "pathfinder_juggernaut_blade_fury",
		special_value_name = "cooldown",
		operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		value = 12,
	},

	{
		description = "pathfinder_juggernaut_blade_fury_duration",
		ability_name = "pathfinder_juggernaut_blade_fury",
		special_value_name = "duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 0.6,
	},
	-- {
	-- 	description = "pathfinder_juggernaut_summon_healing_ward_health",
	-- 	ability_name = "pathfinder_juggernaut_summon_healing_ward",
	-- 	special_value_name = "ward_health",
	-- 	operator = MINOR_ABILITY_UPGRADE_OP_ADD,
	-- 	value = 250,
	-- },
	{
		description = "pathfinder_juggernaut_summon_healing_ward_percent_cooldown",
		ability_name = "pathfinder_juggernaut_summon_healing_ward",
		special_value_name = "cooldown",
		operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		value = 12,
	},

	{
		description = "pathfinder_juggernaut_summon_healing_ward_duration",
		ability_name = "pathfinder_juggernaut_summon_healing_ward",
		special_value_name = "duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 8,
	},

	{
		description = "pathfinder_juggernaut_summon_healing_ward_max_health_regen",
		ability_name = "pathfinder_juggernaut_summon_healing_ward",
		special_value_name = "max_health_regen",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 0.5,
	},

	{
		description = "pathfinder_juggernaut_summon_healing_ward_radius",
		ability_name = "pathfinder_juggernaut_summon_healing_ward",
		special_value_name = "radius",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 100,
	},

	{
		description = "pathfinder_juggernaut_blade_dance_crit_chance",
		ability_name = "pathfinder_juggernaut_blade_dance",
		special_value_name = "blade_dance_crit_chance",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 5,
	},

	{
		description = "pathfinder_juggernaut_blade_dance_crit_mult",
		ability_name = "pathfinder_juggernaut_blade_dance",
		special_value_name = "blade_dance_crit_mult",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 10,
	},

	{
		description = "pathfinder_juggernaut_omni_slash_cooldown",
		ability_name = "pathfinder_juggernaut_omni_slash",
		special_value_name = "cooldown",
		operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		value = 12,
	},

	{
		description = "pathfinder_juggernaut_omni_slash_bounce_radius",
		ability_name = "pathfinder_juggernaut_omni_slash",
		special_value_name = "bounce_radius",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 90,
	},

	{
		description = "pathfinder_juggernaut_omni_slash_damage_bonus",
		ability_name = "pathfinder_juggernaut_omni_slash",
		special_value_name = "damage_bonus",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 20
	},

	{
		description = "pathfinder_juggernaut_omni_slash_duration",
		ability_name = "pathfinder_juggernaut_omni_slash",
		special_value_name = "duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 0.7,
	},
}

return Juggernaut
