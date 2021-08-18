local Phoenix =
{
	{
		description = "phoenix_icarus_dive_pf_cooldown",
		ability_name = "phoenix_icarus_dive_pf",
		special_value_name = "cooldown",
		operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		value = 12,
	},

	{
		description = "phoenix_icarus_dive_pf_dash_length",
		ability_name = "phoenix_icarus_dive_pf",
		special_value_name = "dash_length",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 300,
	},

	{
		description = "phoenix_icarus_dive_pf_burn_duration",
		ability_name = "phoenix_icarus_dive_pf",
		special_value_name = "burn_duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 1.5,
	},

	{
		description = "phoenix_icarus_dive_pf_damage_per_second",
		ability_name = "phoenix_icarus_dive_pf",
		special_value_name = "damage_per_second",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 20,
	},

	{
		description = "phoenix_icarus_dive_pf_slow_movement_speed_pct",
		ability_name = "phoenix_icarus_dive_pf",
		special_value_name = "slow_movement_speed_pct",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 12,
	},


	------------------------------------
	------------------------------------

	{
		description = "phoenix_fire_spirits_pf_cooldown",
		ability_name = "phoenix_fire_spirits_pf",
		special_value_name = "cooldown",
		operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		value = 12,
	},
	{
		description = "phoenix_fire_spirits_pf_duration",
		ability_name = "phoenix_fire_spirits_pf",
		special_value_name = "duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 0.8,
	},
	{
		description = "phoenix_fire_spirits_pf_damage_per_second",
		ability_name = "phoenix_fire_spirits_pf",
		special_value_name = "damage_per_second",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 20,
	},
	{
		description = "phoenix_fire_spirits_pf_attackspeed_slow",
		ability_name = "phoenix_fire_spirits_pf",
		special_value_name = "attackspeed_slow",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 20,
	},

	------------------------------------
	------------------------------------

	{
		description = "phoenix_sun_ray_pf_cooldown",
		ability_name = "phoenix_sun_ray_pf",
		special_value_name = "cooldown",
		operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		value = 12,
	},

	{
		description = "phoenix_sun_ray_pf_hp_cost_perc_per_second",
		ability_name = "phoenix_sun_ray_pf",
		special_value_name = "hp_cost_perc_per_second",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = -0.75,
	},
	{
		description = "phoenix_sun_ray_pf_base_damage",
		ability_name = "phoenix_sun_ray_pf",
		special_value_name = "base_damage",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 10,
	},
	{
		description = "phoenix_sun_ray_pf_hp_perc_heal",
		ability_name = "phoenix_sun_ray_pf",
		special_value_name = "hp_perc_heal",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 0.5,
	},
	{
		description = "phoenix_sun_ray_pf_beam_range",
		ability_name = "phoenix_sun_ray_pf",
		special_value_name = "beam_range",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 210,
	},

	------------------------------------
	------------------------------------

	{
		description = "phoenix_supernova_pf_cooldown",
		ability_name = "phoenix_supernova_pf",
		special_value_name = "cooldown",
		operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		value = 12,
	},
	{
		description = "phoenix_supernova_pf_damage_per_sec",
		ability_name = "phoenix_supernova_pf",
		special_value_name = "damage_per_sec",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 25,
	},
	{
		description = "phoenix_supernova_pf_max_health_for_egg",
		ability_name = "phoenix_supernova_pf",
		special_value_name = "max_health_for_egg",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 10,
	},
	{
		description = "phoenix_supernova_pf_stun_duration",
		ability_name = "phoenix_supernova_pf",
		special_value_name = "stun_duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 1.5,
	},
}

return Phoenix