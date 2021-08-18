local Hoodwink =
{
	{
		description = "pathfinder_acorn_shot_percent_cooldown",
		ability_name = "pathfinder_acorn_shot",
		special_value_name = "cooldown",
		operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		value = 12,
	},
	
	{
		description = "pathfinder_acorn_shot_bonus_damage",
		ability_name = "pathfinder_acorn_shot",
		special_value_name = "bonus_damage",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 15,
	},

	{
		description = "pathfinder_acorn_shot_bounce_count",
		ability_name = "pathfinder_acorn_shot",
		special_value_name = "bounce_count",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 1,
	},

	{
		description = "pathfinder_acorn_shot_bounce_range",
		ability_name = "pathfinder_acorn_shot",
		special_value_name = "bounce_range",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 50,
	},

	{
		description = "pathfinder_acorn_shot_debuff_duration",
		ability_name = "pathfinder_acorn_shot",
		special_value_name = "debuff_duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 1,
	},


	-------------


	{
		description = "pathfinder_bushwhack_percent_cooldown",
		ability_name = "pathfinder_bushwhack",
		special_value_name = "cooldown",
		operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		value = 12,
	},
	
	{
		description = "pathfinder_bushwhack_trap_radius",
		ability_name = "pathfinder_bushwhack",
		special_value_name = "trap_radius",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 50,
	},

	{
		description = "pathfinder_bushwhack_debuff_duration",
		ability_name = "pathfinder_bushwhack",
		special_value_name = "debuff_duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 0.7,
	},

	{
		description = "pathfinder_bushwhack_total_damage",
		ability_name = "pathfinder_bushwhack",
		special_value_name = "total_damage",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 75,
	},



	-------------


	{
		description = "pathfinder_scurry_percent_cooldown",
		ability_name = "pathfinder_scurry",
		special_value_name = "cooldown",
		operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		value = 12,
	},
	{
		description = "pathfinder_scurry_movement_speed_pct",
		ability_name = "pathfinder_scurry",
		special_value_name = "movement_speed_pct",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 5,
	},

	{
		description = "pathfinder_scurry_duration",
		ability_name = "pathfinder_scurry",
		special_value_name = "duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 1,
	},

	{
		description = "pathfinder_scurry_movement_evasion",
		ability_name = "pathfinder_scurry",
		special_value_name = "evasion",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 5,
	},
	


	-------------


	{
		description = "pathfinder_sharpshooter_percent_cooldown",
		ability_name = "pathfinder_sharpshooter",
		special_value_name = "cooldown",
		operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		value = 12,
	},
	{
		description = "pathfinder_sharpshooter_max_damage",
		ability_name = "pathfinder_sharpshooter",
		special_value_name = "max_damage",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 350,
	},
	{
		description = "pathfinder_sharpshooter_arrow_range",
		ability_name = "pathfinder_sharpshooter",
		special_value_name = "arrow_range",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 850,
	},
	{
		description = "pathfinder_sharpshooter_max_slow_debuff_duration",
		ability_name = "pathfinder_sharpshooter",
		special_value_name = "max_slow_debuff_duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 2,
	},
}

return Hoodwink
