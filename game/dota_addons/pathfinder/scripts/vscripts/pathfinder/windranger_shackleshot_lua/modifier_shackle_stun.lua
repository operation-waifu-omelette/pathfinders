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
LinkLuaModifier( "modifier_universal_sleep", "pathfinder/dawnbreaker_starbreaker_lua/modifier_dawnbreaker_starbreaker_lua", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
modifier_shackle_stun = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_shackle_stun:IsHidden()
	return true
end

function modifier_shackle_stun:IsDebuff()
	return true
end

function modifier_shackle_stun:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_shackle_stun:CheckState()
	local state = {	}
	if IsServer() then
		state = {[MODIFIER_STATE_STUNNED] = true,}	
	end

	return state
end

function modifier_shackle_stun:OnCreated(table)
	if IsServer() then
		self:GetParent():StartGesture(ACT_DOTA_DISABLED)
	end
	self:StartIntervalThink(0.2)
end


function modifier_shackle_stun:OnDestroy()
	if IsServer() then
		self:GetParent():FadeGesture(ACT_DOTA_DISABLED)
		if self:GetAbility():GetCaster():HasAbility("pathfinder_special_windranger_shackleshot_sleep") then
			local sleep_duration = self:GetAbility():GetCaster():FindAbilityByName("pathfinder_special_windranger_shackleshot_sleep"):GetLevelSpecialValueFor("duration", 1)
			self:GetParent():AddNewModifier(self:GetAbility():GetCaster(), self:GetAbility(), "modifier_universal_sleep", {duration = sleep_duration})
		end
	end
end

function modifier_shackle_stun:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_ATTACKED,}

	return decFuncs
end

function modifier_shackle_stun:OnAttacked( params )
	if IsServer() then
		if self:GetAbility():GetCaster():HasAbility("pathfinder_special_windranger_shackleshot_armor") and params.attacker ~= nil and params.attacker == self:GetAbility():GetCaster() and params.target ~= self:GetParent() and not params.no_attack_cooldown then
			params.attacker:PerformAttack(self:GetParent(), false, true, true, true, true, false, false)
		end		
	end
end


function modifier_shackle_stun:OnIntervalThink()
	if IsServer() and self:GetParent():IsStunned() == false then
		self:GetParent():FadeGesture(ACT_DOTA_DISABLED)
	end
end