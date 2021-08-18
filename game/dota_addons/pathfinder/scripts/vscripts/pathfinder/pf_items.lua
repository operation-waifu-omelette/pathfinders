

--------------------------------------------------------------------------------
item_seer_stone_pf = class({})

LinkLuaModifier("modifier_item_seer_stone_pf", "pathfinder/pf_items", LUA_MODIFIER_MOTION_NONE)

function item_seer_stone_pf:GetIntrinsicModifierName()
	return "modifier_item_seer_stone_pf"
end

modifier_item_seer_stone_pf				= class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,	
})

function modifier_item_seer_stone_pf:DeclareFunctions()
	local decFuncs = 
	{
		MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING ,
		MODIFIER_PROPERTY_MANA_BONUS,		
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}	

	return decFuncs
end

function modifier_item_seer_stone_pf:IsAura() return true end
function modifier_item_seer_stone_pf:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_item_seer_stone_pf:GetModifierAura() return "modifier_truesight" end
function modifier_item_seer_stone_pf:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_item_seer_stone_pf:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_item_seer_stone_pf:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_OTHER end
function modifier_item_seer_stone_pf:GetAuraDuration() return 0.5 end

function modifier_item_seer_stone_pf:GetModifierCastRangeBonusStacking()
	return self:GetAbility():GetSpecialValueFor("bonus_cast_range")
end

function modifier_item_seer_stone_pf:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("mana")
end

function modifier_item_seer_stone_pf:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("mana_regen")
end


-------------------------
-------------------------

modifier_drop_potion_on_death = class({})

function modifier_drop_potion_on_death:Precache( context )
	PrecacheItemByNameSync( "item_health_potion", context )	
	PrecacheItemByNameSync( "item_mana_potion", context )	
end

function modifier_drop_potion_on_death:IsHidden()			return true end
function modifier_drop_potion_on_death:DeclareFunctions()
	local decFuncs = 
	{
		MODIFIER_EVENT_ON_DEATH
	}	

	return decFuncs
end

-- function modifier_drop_potion_on_death:OnCreated(table)
-- 	if not IsServer() then return end
-- 	-- self:StartIntervalThink(0.1)	
-- end

-- function modifier_drop_potion_on_death:OnIntervalThink()
-- 	if not IsServer() then return end
-- 	if GetGroundHeight(self:GetParent():GetAbsOrigin(), self:GetParent()) > 256 then
-- 		self:GetParent():SetAbsOrigin(GetGroundPosition(FindRandomPointInRoom(self:GetParent():GetAbsOrigin(), 100, 500 ), self:GetParent()))
-- 	else
-- 		print(self:GetParent():GetAbsOrigin())
-- 		self:StartIntervalThink(-1)
-- 	end
-- end

function modifier_drop_potion_on_death:CheckState()
	local state = {}
	if IsServer()  then
		state[MODIFIER_STATE_ROOTED] = true
		state[MODIFIER_STATE_NO_HEALTH_BAR] = true
		state[MODIFIER_STATE_BLIND] = true
		state[MODIFIER_STATE_NOT_ON_MINIMAP] = true
		state[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true
		state[MODIFIER_STATE_MAGIC_IMMUNE] = true
	end

	return state
end

function modifier_drop_potion_on_death:OnDeath(params)
	if not IsServer() or not params.unit or not params.attacker or params.unit ~= self:GetParent() then return end
	
	local nHealthPotChance = 55 
	local szItem = nil
	if RollPseudoRandomPercentage( nHealthPotChance, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, params.attacker ) == true then
		szItem = item_health_potion
	else
		szItem = item_mana_potion		
	end

	self:GetParent():DropItemAtPosition(self:GetParent():GetAbsOrigin(), szItem)
	EmitSoundOn( "Dungeon.TreasureItemDrop", self:GetParent() )

end
