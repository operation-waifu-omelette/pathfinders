modifier_rooted = class({})

function modifier_rooted:Precache( context )		
	PrecacheResource( "particle", "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo_debuff.vpcf", context )		
end

--------------------------------------------------------------------------------
-- Classifications
function modifier_rooted:IsHidden()
	return true
end

function modifier_rooted:IsDebuff()
	return true
end

function modifier_rooted:IsPurgable()
	return false
end




--------------------------------------------------------------------------------
function modifier_rooted:CheckState()
    local state =
	{
		[ MODIFIER_STATE_ROOTED ] = true,
	}

	return state
end

function modifier_rooted:GetEffectName()
	return "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo_debuff.vpcf"
end

function modifier_rooted:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
