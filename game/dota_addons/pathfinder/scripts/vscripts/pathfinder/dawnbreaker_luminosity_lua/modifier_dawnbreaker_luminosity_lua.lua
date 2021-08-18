-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
LinkLuaModifier( "modifier_dawnbreaker_luminosity_lua_stacking", "pathfinder/dawnbreaker_luminosity_lua/dawnbreaker_luminosity_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dawnbreaker_luminosity_lua_explosion", "pathfinder/dawnbreaker_luminosity_lua/dawnbreaker_luminosity_lua", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
modifier_dawnbreaker_luminosity_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_dawnbreaker_luminosity_lua:IsHidden()
	return self:GetStackCount()<1
end

function modifier_dawnbreaker_luminosity_lua:IsDebuff()
	return false
end

function modifier_dawnbreaker_luminosity_lua:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_dawnbreaker_luminosity_lua:OnCreated( kv )
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	-- references
	self.count = self:GetAbility():GetSpecialValueFor( "attack_count" )

	if not IsServer() then return end
end

function modifier_dawnbreaker_luminosity_lua:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_dawnbreaker_luminosity_lua:OnRemoved()
end

function modifier_dawnbreaker_luminosity_lua:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_dawnbreaker_luminosity_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}

	return funcs
end

function modifier_dawnbreaker_luminosity_lua:GetModifierProcAttack_Feedback( params )
	-- if caster has starbreak, let starbreak do the increase
	if self:GetCaster():FindAbilityByName("dawnbreaker_luminosity_lua_explosion") then
		local grace_time = self:GetCaster():FindAbilityByName("dawnbreaker_luminosity_lua_explosion"):GetLevelSpecialValueFor("duration",1)
		if self:GetParent():HasModifier("modifier_dawnbreaker_luminosity_lua_buff") then
			params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_dawnbreaker_luminosity_lua_explosion", {duration = grace_time})
		end
	end
	
	if self.parent:HasModifier( "modifier_dawnbreaker_starbreaker_lua" ) then return end	

	self:Increment()
end

function modifier_dawnbreaker_luminosity_lua:GetAttackAnimationString()
	if self:GetStackCount() == 1 then
		return "ATTACKCOMBO_A"
	elseif self:GetStackCount() == 2 then
		return "ATTACKCOMBO_B"
	elseif self:GetStackCount() == 3 then
		return "ATTACKCOMBO_C"
	end
	return ""
end

function modifier_dawnbreaker_luminosity_lua:GetActivityTranslationModifiers()
	return self:GetAttackAnimationString()
end


--------------------------------------------------------------------------------
-- Helper
function modifier_dawnbreaker_luminosity_lua:Increment()
	-- add only if stack < count and not break
	if self.parent:PassivesDisabled() then return end

	if self:GetParent():FindAbilityByName("dawnbreaker_luminosity_lua_stacking") then
		local stacking_ability = self:GetParent():FindAbilityByName("dawnbreaker_luminosity_lua_stacking")
		local max_stacks = stacking_ability:GetLevelSpecialValueFor("max_stacks",1)
		local reset_time = stacking_ability:GetLevelSpecialValueFor("reset_time",1)

		if not self:GetParent():HasModifier("modifier_dawnbreaker_luminosity_lua_stacking") then
			local stack = self.parent:AddNewModifier(
				self.parent, -- player source
				self.ability, -- ability source
				"modifier_dawnbreaker_luminosity_lua_stacking", -- modifier name
				{duration = reset_time} -- kv
			)
			stack:SetStackCount(1)
		else
			self:GetParent():FindModifierByName("modifier_dawnbreaker_luminosity_lua_stacking"):ForceRefresh()
			if self:GetParent():FindModifierByName("modifier_dawnbreaker_luminosity_lua_stacking"):GetStackCount() < max_stacks then
				self:GetParent():FindModifierByName("modifier_dawnbreaker_luminosity_lua_stacking"):IncrementStackCount()
			end
		end
		self:GetParent():CalculateStatBonus(true)
	end

	if self:GetStackCount()>=self.count then return end

	-- add stack
	self:IncrementStackCount()
	if self:GetStackCount()<self.count then return end

	-- add buff
	local mod = self.parent:AddNewModifier(
		self.parent, -- player source
		self.ability, -- ability source
		"modifier_dawnbreaker_luminosity_lua_buff", -- modifier name
		{} -- kv
	)
	mod.modifier = self	
end