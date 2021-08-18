modifier_pango_bonus = class({})

--------------------------------------------------------------------------------

function modifier_pango_bonus:IsHidden()
	return true
end

-----------------------------------------------------------------------------------------

function modifier_pango_bonus:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_pango_bonus:GetPriority()
	return MODIFIER_PRIORITY_ULTRA + 10001
end

function modifier_pango_bonus:RemoveOnDeath()
	return false
end

function modifier_pango_bonus:GetOverrideAnimation( params )
	return ACT_DOTA_RUN
end

--------------------------------------------------------------------------------

function modifier_pango_bonus:CheckState()
	local state = {}

	if IsServer() then
		local hModifier = self:GetParent():FindModifierByName( "modifier_pangolier_gyroshell" )
		state[MODIFIER_STATE_SILENCED] = ( hModifier ~= nil )
		state[MODIFIER_STATE_MUTED] = true
		state[MODIFIER_STATE_IGNORING_STOP_ORDERS] = true
		state[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = ( hModifier == nil )
		state[MODIFIER_STATE_MAGIC_IMMUNE] = false
	end
	
	return state
end

function modifier_pango_bonus:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

