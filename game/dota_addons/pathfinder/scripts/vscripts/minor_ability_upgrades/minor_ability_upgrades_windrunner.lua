local Windrunner =
{
	{
		 description = "windranger_shackleshot_lua_stun_duration",
		 ability_name = "windranger_shackleshot_lua",
		 special_value_name = "stun_duration",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 0.7,
	},

	{
		 description = "windranger_shackleshot_lua_shackle_distance",
		 ability_name = "windranger_shackleshot_lua",
		 special_value_name = "shackle_distance",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 50,
	},

	{
		 description = "windranger_shackleshot_lua_shackle_angle",
		 ability_name = "windranger_shackleshot_lua",
		 special_value_name = "shackle_angle",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 15,
	},
	{
		 description = "windranger_shackleshot_lua_shackle_shackle_count",
		 ability_name = "windranger_shackleshot_lua",
		 special_value_name = "shackle_count",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 1,
	},

	{
		 description = "windranger_windrun_lua_duration",
		 ability_name = "windranger_windrun_lua",
		 special_value_name = "duration",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 1,
	},

	{
		 description = "windranger_windrun_lua_movespeed_bonus_pct",
		 ability_name = "windranger_windrun_lua",
		 special_value_name = "movespeed_bonus_pct",
		 operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		 value = 8,
	},

	{
		 description = "windranger_powershot_lua_powershot_damage",
		 ability_name = "windranger_powershot_lua",
		 special_value_name = "powershot_damage",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 50,
	},

	{
		 description = "windranger_focus_fire_lua_bonus_attack_speed",
		 ability_name = "windranger_focus_fire_lua",
		 special_value_name = "bonus_attack_speed",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 30,
	},

	{
		description = "windranger_focus_fire_lua_cooldown",
		ability_name = "windranger_focus_fire_lua",
		special_value_name = "cooldown",
		operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		value = 12,
	},

	{
		description = "windranger_shackleshot_lua_cooldown",
		ability_name = "windranger_shackleshot_lua",
		special_value_name = "cooldown",
		operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		value = 12,
	},
	{
		description = "windranger_powershot_lua_cooldown",
		ability_name = "windranger_powershot_lua",
		special_value_name = "cooldown",
		operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		value = 12,
	},
	{
		description = "windranger_powershot_lua_arrow_range",
		ability_name = "windranger_powershot_lua",
		special_value_name = "arrow_range",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 200,
	},

	{
		description = "windranger_windrun_lua_enemy_slow",
		ability_name = "windranger_windrun_lua",
		special_value_name = "enemy_movespeed_bonus_pct",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = -10,
	},
}

return Windrunner