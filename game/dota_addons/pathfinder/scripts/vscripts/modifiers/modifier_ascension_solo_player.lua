
modifier_ascension_solo_player = class({})

-----------------------------------------------------------------------------------------

function modifier_ascension_solo_player:constructor()
	self.health_percent  = 0
end

-----------------------------------------------------------------------------------------

function modifier_ascension_solo_player:IsPurgable()
	return false
end

----------------------------------------

function modifier_ascension_solo_player:OnCreated( kv )
	self:OnRefresh( kv )
end

----------------------------------------

function modifier_ascension_solo_player:OnRefresh( kv )
	if self:GetAbility() == nil then
		return
	end

	if IsServer() then
		self.health_percent = self:GetAbility():GetSpecialValueFor( "minus_health_percent" )

	end
end

--------------------------------------------------------------------------------

function modifier_ascension_solo_player:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_ascension_solo_player:GetModifierExtraHealthPercentage( params )
	return self.health_percent
end
