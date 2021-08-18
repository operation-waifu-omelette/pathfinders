local Nevermore =
{
	{
		 description = "pathfinder_nevermore_shadowraze_damage_value",
		 ability_name = "pathfinder_nevermore_shadowraze_damage",
		 special_value_name = "value",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 50,
	},
	
	{
		 description = "pathfinder_nevermore_shadowraze_stack_damage_value",
		 ability_name = "pathfinder_nevermore_shadowraze_stack_damage",
		 special_value_name = "value",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 10,
	},

	{
		 description = "pathfinder_nevermore_shadowraze_cooldown_value",
		 ability_name = "pathfinder_nevermore_shadowraze_cooldown",
		 special_value_name = "value",
		 operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		 value = -12,
	},


	--------

	{
		 description = "pathfinder_nevermore_necromastery_damage_per_soul",
		 ability_name = "pathfinder_nevermore_necromastery",
		 special_value_name = "damage_per_soul",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 1,
	},
	{
		 description = "pathfinder_nevermore_necromastery_max_souls",
		 ability_name = "pathfinder_nevermore_necromastery",
		 special_value_name = "max_souls",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 2,
	},
	-- {
	-- 	 description = "pathfinder_nevermore_necromastery_souls_per_kill",
	-- 	 ability_name = "pathfinder_nevermore_necromastery",
	-- 	 special_value_name = "souls_per_kill",
	-- 	 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
	-- 	 value = 1,
	-- },

	----------
	{
		 description = "pathfinder_nevermore_dark_lord_aura_radius",
		 ability_name = "pathfinder_nevermore_dark_lord",
		 special_value_name = "aura_radius",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 175,
	},
	{
		 description = "pathfinder_nevermore_dark_lord_armor_reduction",
		 ability_name = "pathfinder_nevermore_dark_lord",
		 special_value_name = "armor_reduction",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 0.5,
	},

	----------

	{
		 description = "pathfinder_nevermore_requiem_damage",
		 ability_name = "pathfinder_nevermore_requiem",
		 special_value_name = "damage",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 50,
	},
	{
		 description = "pathfinder_nevermore_requiem_travel_distance",
		 ability_name = "pathfinder_nevermore_requiem",
		 special_value_name = "travel_distance",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 200,
	},
	{
		 description = "pathfinder_nevermore_requiem_ms_slow_pct",
		 ability_name = "pathfinder_nevermore_requiem",
		 special_value_name = "ms_slow_pct",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 15,
	},
	-- {
	-- 	 description = "pathfinder_nevermore_requiem_requiem_slow_duration",
	-- 	 ability_name = "pathfinder_nevermore_requiem",
	-- 	 special_value_name = "slow_duration",
	-- 	 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
	-- 	 value = 0.8,
	-- },
	{
		 description = "pathfinder_nevermore_requiem_pct_cooldown",
		 ability_name = "pathfinder_nevermore_requiem",
		 special_value_name = "cooldown",
		 operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		 value = 12,
	},
}

return Nevermore