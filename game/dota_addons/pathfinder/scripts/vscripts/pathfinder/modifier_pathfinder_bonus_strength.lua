modifier_pathfinder_bonus_strength = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_bonus_strength:IsHidden()
	return false
end

function modifier_pathfinder_bonus_strength:IsDebuff()
	return false
end

function modifier_pathfinder_bonus_strength:IsPurgable()
	return false
end




--------------------------------------------------------------------------------
function modifier_pathfinder_bonus_strength:DeclareFunctions()
    local funcs_array = {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS , }
    return funcs_array
end

function modifier_pathfinder_bonus_strength:GetModifierBonusStats_Strength()	
    return self:GetAbility():GetSpecialValueFor("bonus_strength") * self:GetAbility():GetCaster():GetModifierStackCount("modifier_pathfinder_bonus_strength", self:GetAbility():GetCaster())
end
