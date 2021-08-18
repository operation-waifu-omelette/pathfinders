  
modifier_pathfinder_bigass_ward_passive = class({})
require("pathfinder.plague_ward")
--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_bigass_ward_passive:IsHidden()
	return true
end

function modifier_pathfinder_bigass_ward_passive:IsDebuff()
	return false
end

function modifier_pathfinder_bigass_ward_passive:IsPurgable()
	return false
end



function modifier_pathfinder_bigass_ward_passive:GetEffectName()
	return "particles/units/heroes/hero_snapfire/hero_snapfire_burn_debuff.vpcf"
end

function modifier_pathfinder_bigass_ward_passive:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_pathfinder_bigass_ward_passive:GetStatusEffectName()
	return "particles/status_fx/status_effect_snapfire_magma.vpcf"
end

function modifier_pathfinder_bigass_ward_passive:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function modifier_pathfinder_bigass_ward_passive:CheckState()
    local state =
	{
		[ MODIFIER_STATE_LOW_ATTACK_PRIORITY ] = true,
	}

	return state
end

function modifier_pathfinder_bigass_ward_passive:OnCreated( table )
	if not IsServer() then return end
	self:StartIntervalThink( 12 )		
	self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_phased", {})
	self:GetParent():SetUnitCanRespawn(true)
end

function modifier_pathfinder_bigass_ward_passive:OnIntervalThink(  )
	if not IsServer() then return end			
    	local plague_ward_ability = self.creator:FindAbilityByName("venomancer_plague_ward_datadriven")
		local plague_ward_level = plague_ward_ability:GetLevel()
		if plague_ward_level < 1 then return end
		
		local keys = {}
		keys.caster = self.creator
		keys.Duration = plague_ward_ability:GetLevelSpecialValueFor("duration", plague_ward_level - 1)
		keys.ability = plague_ward_ability
		keys.target_points = {self:GetParent():GetAbsOrigin() + RandomVector( RandomFloat( 50, 250 ) )}		
		venomancer_plague_ward_datadriven_on_spell_start(keys)		
end

function modifier_pathfinder_bigass_ward_passive:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end


function modifier_pathfinder_bigass_ward_passive:OnDeath( params )
	if IsServer() then
		if params.unit == self:GetParent() and self:GetParent().veno then
			self:GetParent().veno.terry = nil
		end
	end
end
