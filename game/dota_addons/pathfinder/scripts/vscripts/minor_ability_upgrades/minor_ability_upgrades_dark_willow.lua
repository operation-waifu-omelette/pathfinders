local Dark_Willow =
{
	{
		 description = "dark_willow_bramble_maze_lua_cooldown",
		 ability_name = "dark_willow_bramble_maze_lua",
		 special_value_name = "cooldown",
		 operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		 value = 12,
	},
	{
		description = "dark_willow_bramble_maze_lua_latch_damage",
		ability_name = "dark_willow_bramble_maze_lua",
		special_value_name = "latch_damage",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 25,
   },
   {
		description = "dark_willow_bramble_maze_lua_latch_duration",
		ability_name = "dark_willow_bramble_maze_lua",
		special_value_name = "latch_duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 0.5,
	},
	
   {
		description = "dark_willow_shadow_realm_lua_duration",
		ability_name = "dark_willow_shadow_realm_lua",
		special_value_name = "duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 1,
	},
	{
		description = "dark_willow_shadow_realm_lua_damage",
		ability_name = "dark_willow_shadow_realm_lua",
		special_value_name = "damage",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 45,
	},
	{
		description = "dark_willow_shadow_realm_lua_range",
		ability_name = "dark_willow_shadow_realm_lua",
		special_value_name = "attack_range_bonus",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 100,
	},

	{
		description = "dark_willow_cursed_crown_lua_cooldown",
		ability_name = "dark_willow_cursed_crown_lua",
		special_value_name = "cooldown",
		operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		value = 12,
   },
   {
		description = "dark_willow_cursed_crown_lua_stun_duration",
		ability_name = "dark_willow_cursed_crown_lua",
		special_value_name = "stun_duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 0.5,
	},
	{
		description = "dark_willow_cursed_crown_lua_stun_damage",
		ability_name = "dark_willow_cursed_crown_lua",
		special_value_name = "stun_damage",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 100,
	},
	{
		description = "dark_willow_cursed_crown_lua_stun_radius",
		ability_name = "dark_willow_cursed_crown_lua",
		special_value_name = "stun_radius",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 50,
	},

	{
		description = "dark_willow_bedlam_lua_cooldown",
		ability_name = "dark_willow_bedlam_lua",
		special_value_name = "cooldown",
		operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		value = 12,
   },
   {
		description = "dark_willow_bedlam_lua_damage",
		ability_name = "dark_willow_bedlam_lua",
		special_value_name = "attack_damage",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 25,
	},
	{
		description = "dark_willow_bedlam_lua_duration",
		ability_name = "dark_willow_bedlam_lua",
		special_value_name = "roaming_duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 1.0,
	},

   {
		description = "dark_willow_terrorize_lua_cooldown",
		ability_name = "dark_willow_terrorize_lua",
		special_value_name = "cooldown",
		operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		value = 12,
	},
	{
		description = "dark_willow_terrorize_lua_duration",
		ability_name = "dark_willow_terrorize_lua",
		special_value_name = "destination_status_duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 1,
	},
	{
		description = "dark_willow_terrorize_lua_radius",
		ability_name = "dark_willow_terrorize_lua",
		special_value_name = "destination_radius",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 50,
	},
}

return Dark_Willow