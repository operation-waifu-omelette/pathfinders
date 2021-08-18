modifier_pathfinder_healing_ward_effect = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_healing_ward_effect:IsHidden()
	return false
end

function modifier_pathfinder_healing_ward_effect:IsDebuff()
	return false
end

function modifier_pathfinder_healing_ward_effect:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_pathfinder_healing_ward_effect:OnCreated( kv )
	local ability = nil
	if IsServer() then
		ability = self:GetAbility():GetCaster():GetOwner():FindAbilityByName("pathfinder_juggernaut_summon_healing_ward") -- special value
		self.regen = ability:GetLevelSpecialValueFor( "max_health_regen" , ability:GetLevel() - 1)
		self:SetHasCustomTransmitterData( true )
	end		
end

function modifier_pathfinder_healing_ward_effect:OnRefresh( kv )
	local ability = nil
	if IsServer() then
		ability = self:GetAbility():GetCaster():GetOwner():FindAbilityByName("pathfinder_juggernaut_summon_healing_ward") -- special value
		self.regen = ability:GetLevelSpecialValueFor( "max_health_regen" , ability:GetLevel() - 1)
		self:SetHasCustomTransmitterData( true )
	end	
end

function modifier_pathfinder_healing_ward_effect:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_pathfinder_healing_ward_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,		
	}

	return funcs
end

-- function modifier_pathfinder_healing_ward_effect:OnIntervalThink()
-- 	if IsServer() then
-- 		self:GetParent():Heal(self.regen, nil)
-- 		print(self:GetParent():GetUnitName())
-- 		print("healing")
-- 	end
-- end
function modifier_pathfinder_healing_ward_effect:GetModifierHealthRegenPercentage()
	return self.regen
end

function modifier_pathfinder_healing_ward_effect:GetEffectName()
	return "particles/items_fx/healing_flask_c.vpcf"
end

function modifier_pathfinder_healing_ward_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end



function modifier_pathfinder_healing_ward_effect:AddCustomTransmitterData( )
	return
	{
		regen = self.regen,
	}
end

--------------------------------------------------------------------------------

function modifier_pathfinder_healing_ward_effect:HandleCustomTransmitterData( data )
	self.regen = data.regen
end



