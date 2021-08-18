local Legion_Commander =
{
	{
		 description = "pathfinder_lc_arrows_arrows_radius",
		 ability_name = "pathfinder_lc_arrows",
		 special_value_name = "arrows_radius",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 50,
	},
	{
		 description = "pathfinder_lc_arrows_arrows_base_damage",
		 ability_name = "pathfinder_lc_arrows",
		 special_value_name = "arrows_base_damage",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 40,
	},

	{
		 description = "pathfinder_lc_arrows_arrows_damage_per_unit",
		 ability_name = "pathfinder_lc_arrows",
		 special_value_name = "arrows_damage_per_unit",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 10,
	},
	{
		 description = "pathfinder_lc_arrows_arrows_movespeed_duration",
		 ability_name = "pathfinder_lc_arrows",
		 special_value_name = "arrows_movespeed_duration",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 3,
	},

	{
		description = "pathfinder_lc_arrows_cooldown",
		ability_name = "pathfinder_lc_arrows",
		special_value_name = "cooldown",
		operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		value = 12,
	},

	{
		description = "pathfinder_lc_press_press_regen",
		ability_name = "pathfinder_lc_press",
		special_value_name = "press_regen",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 5,
	},

	{
		description = "pathfinder_lc_press_press_attack",
		ability_name = "pathfinder_lc_press",
		special_value_name = "press_attack",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 10,
	},

	{
		description = "pathfinder_lc_press_press_duration",
		ability_name = "pathfinder_lc_press",
		special_value_name = "press_duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 1,
	},
	{
		description = "pathfinder_lc_press_cooldown",
		ability_name = "pathfinder_lc_press",
		special_value_name = "cooldown",
		operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		value = 12,
	},

	{
		description = "pathfinder_lc_moment_moment_chance",
		ability_name = "pathfinder_lc_moment",
		special_value_name = "moment_chance",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 5,
	},

	{
		description = "pathfinder_lc_moment_moment_lifesteal",
		ability_name = "pathfinder_lc_moment",
		special_value_name = "moment_lifesteal",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 7,
	},

	{
		description = "pathfinder_lc_duel_duel_duration",
		ability_name = "pathfinder_lc_duel",
		special_value_name = "duel_duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 1,
	},

	{
		description = "pathfinder_lc_duel_duel_hero_damage",
		ability_name = "pathfinder_lc_duel",
		special_value_name = "duel_hero_damage",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 4,
	},
	{
		description = "pathfinder_lc_duel_cooldown",
		ability_name = "pathfinder_lc_duel",
		special_value_name = "cooldown",
		operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		value = 12,
	},
}

return Legion_Commander