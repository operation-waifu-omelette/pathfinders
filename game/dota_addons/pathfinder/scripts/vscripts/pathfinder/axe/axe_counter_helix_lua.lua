axe_counter_helix_lua = class({})
LinkLuaModifier( "modifier_axe_counter_helix_lua", "pathfinder/axe/modifier_axe_counter_helix_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_axe_counter_helix_special_fury", "pathfinder/axe/modifier_axe_counter_helix_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function axe_counter_helix_lua:GetIntrinsicModifierName()
	return "modifier_axe_counter_helix_lua"
end

function axe_counter_helix_lua:GetBehavior()
	if self:GetCaster():HasModifier("modifier_axe_counter_helix_special_fury_checker") then		
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_TOGGLE + DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

-- function axe_counter_helix_lua:GetManaCost(iLevel)
-- 	if self:GetCaster():HasModifier("modifier_axe_counter_helix_special_fury_checker") then
-- 		return 20
-- 	end
-- end

function axe_counter_helix_lua:OnToggle()
	if self:GetToggleState() then
		print("WHY CANT YOU just work you piece of shit")		
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_axe_counter_helix_special_fury", {})
	else
		if self:GetCaster():HasModifier("modifier_axe_counter_helix_special_fury") then
			self:GetCaster():RemoveModifierByName("modifier_axe_counter_helix_special_fury")
		end
	end
end

function axe_counter_helix_lua:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasModifier("modifier_axe_counter_helix_aura") then
		return 700
	end
end

---------------------------------


modifier_axe_counter_helix_aura = modifier_axe_counter_helix_aura or class({})
LinkLuaModifier( "modifier_axe_counter_helix_lua", "pathfinder/axe/modifier_axe_counter_helix_lua", LUA_MODIFIER_MOTION_NONE )

function modifier_axe_counter_helix_aura:IsHidden() return true end
function modifier_axe_counter_helix_aura:IsPurgable() return false end
function modifier_axe_counter_helix_aura:IsDebuff() return false end

function modifier_axe_counter_helix_aura:AllowIllusionDuplicate()
	return true
end

function modifier_axe_counter_helix_aura:GetAuraRadius()
	if IsServer() then
		local special = self:GetCaster():FindAbilityByName("pathfinder_axe_special_counter_helix_allies")
		return special:GetLevelSpecialValueFor("radius", 1)
	end
end

function modifier_axe_counter_helix_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_axe_counter_helix_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_axe_counter_helix_aura:GetModifierAura()
	return "modifier_axe_counter_helix_lua"
end

function modifier_axe_counter_helix_aura:IsAura()	
	if self:GetCaster():PassivesDisabled() then
		return false
	end
	return true
end