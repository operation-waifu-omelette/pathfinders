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
--------------------------------------------------------------------------------
modifier_windranger_windrun_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_windranger_windrun_lua:IsHidden()
	return false
end

function modifier_windranger_windrun_lua:IsDebuff()
	return false
end

function modifier_windranger_windrun_lua:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
require("libraries.has_shard")
-- Initializations
function modifier_windranger_windrun_lua:OnCreated( kv )
	-- references
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.evasion = self:GetAbility():GetSpecialValueFor( "evasion_pct_tooltip" )
	self.ms_bonus = self:GetAbility():GetSpecialValueFor( "movespeed_bonus_pct" )

	self.aura_duration = 2.5

	if IsServer() and self:GetAbility():GetCaster():HasAbility("pathfinder_special_windranger_windrun_cyclone") then
		self:StartIntervalThink( self:GetAbility():GetCaster():FindAbilityByName("pathfinder_special_windranger_windrun_cyclone"):GetLevelSpecialValueFor("duration", 1))
	end
end

function modifier_windranger_windrun_lua:OnIntervalThink()
	if IsServer() and self:GetAbility():GetCaster():HasAbility("pathfinder_special_windranger_windrun_cyclone") then
		if self:GetAbility():GetCaster():HasAbility("windranger_shackleshot_lua") then
			local enemies = FindUnitsInRadius( self:GetAbility():GetCaster():GetTeamNumber(), self:GetAbility():GetCaster():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

			if #enemies > 0 then
				self:GetAbility():GetCaster():SetCursorCastTarget(enemies[1])			
				self:GetAbility():GetCaster():FindAbilityByName("windranger_shackleshot_lua"):OnSpellStart()
			end
		end
	end
end

function modifier_windranger_windrun_lua:OnRefresh( kv )
	-- same as oncreated
	self:OnCreated( kv )
end

function modifier_windranger_windrun_lua:OnRemoved()
end

function modifier_windranger_windrun_lua:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_windranger_windrun_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}

	return funcs
end

function modifier_windranger_windrun_lua:GetActivityTranslationModifiers()
	return "windrun"
end


function modifier_windranger_windrun_lua:GetModifierIgnoreMovespeedLimit(params)
    return 1
end

function modifier_windranger_windrun_lua:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end
function modifier_windranger_windrun_lua:GetModifierEvasion_Constant()
	return self.evasion
end

-- --------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Aura Effects
function modifier_windranger_windrun_lua:IsAura()
	return true
end

function modifier_windranger_windrun_lua:GetModifierAura()
	return "modifier_windranger_windrun_lua_debuff"
end

function modifier_windranger_windrun_lua:GetAuraRadius()
	return self.radius
end

function modifier_windranger_windrun_lua:GetAuraDuration()
	return self.aura_duration
end

function modifier_windranger_windrun_lua:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_windranger_windrun_lua:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_windranger_windrun_lua:GetEffectName()
	return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
end

function modifier_windranger_windrun_lua:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

-----------------
--------------
--------------
--------------
-----------------
------------------
modifier_windranger_windrun_lua_invis = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_windranger_windrun_lua_invis:IsHidden()
	return true
end

function modifier_windranger_windrun_lua_invis:IsDebuff()
	return false
end

function modifier_windranger_windrun_lua_invis:IsPurgable()
	return true
end

function modifier_windranger_windrun_lua_invis:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end

function modifier_windranger_windrun_lua_invis:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end



function modifier_windranger_windrun_lua_invis:OnAttackLanded(params)
	if IsServer() and params.attacker == self:GetParent() then		
		self:Destroy()
	end
end

function modifier_windranger_windrun_lua_invis:OnDestroy()
	if IsServer() then
		if self:GetParent():HasModifier("modifier_invisible") and not self:GetParent():HasModifier("modifier_windranger_windrun_lua_invis") then
			self:GetParent():RemoveModifierByName("modifier_invisible")
		end
	end
end


function modifier_windranger_windrun_lua_invis:OnCreated()	
	if not IsServer() then return end
	if not self:GetCaster():FindAbilityByName("pathfinder_special_windranger_windrun_invis") then self:Destroy() end
	self.ability = self:GetCaster():FindAbilityByName("pathfinder_special_windranger_windrun_invis")

	local illusion_damage = self:GetCaster():FindAbilityByName("pathfinder_special_windranger_windrun_invis"):GetLevelSpecialValueFor("illusion_dmg_mult",1)						
		
	local modifierKeys = {}
	modifierKeys.outgoing_damage = -1 * illusion_damage
	modifierKeys.incoming_damage = -1 * illusion_damage
	modifierKeys.duration = self:GetDuration()
	
	local illusion = CreateIllusions( self:GetCaster(), self:GetCaster(), modifierKeys, 1, 0, true, true)
	illusion[1]:AddNewModifier(self:GetCaster(), self, "modifier_terrorblade_conjureimage", {})
	illusion[1]:AddNewModifier(self:GetCaster(), self, "modifier_phased", {})
	illusion[1]:AddNewModifier(self:GetCaster(), self, "modifier_no_healthbar", {})
	illusion[1]:SetControllableByPlayer(-1, true)			
	FindClearSpaceForUnit(illusion[1], self:GetCaster():GetAbsOrigin(), false)

	self.illusion = illusion[1]

	self:GetParent():AddNewModifier(self:GetParent(), self, "modifier_invisible", {duration = self:GetDuration()})
end

