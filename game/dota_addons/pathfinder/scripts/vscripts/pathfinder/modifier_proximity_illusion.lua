
--------------------------------------------------------------------------------
modifier_proximity_illusion = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_proximity_illusion:IsHidden()
	return true
end

function modifier_proximity_illusion:IsDebuff()
	return false
end

function modifier_proximity_illusion:IsPurgable()
	return false
end


function modifier_proximity_illusion:CheckState()
	local state = {[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_UNSELECTABLE] = true,				
					[MODIFIER_STATE_NO_HEALTH_BAR] = true,
					[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,					
					[MODIFIER_STATE_MAGIC_IMMUNE] = true,}

	return state
end

function modifier_proximity_illusion:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
		MODIFIER_EVENT_ON_DEATH,	
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
	}
	return funcs
end

function modifier_proximity_illusion:GetModifierHPRegenAmplify_Percentage( params )
	return -105
end


function modifier_proximity_illusion:OnDeath(kv)
	if kv.unit == self:GetParent() and self.prox_ring then
		ParticleManager:DestroyParticle(self.prox_ring, false)
		ParticleManager:ReleaseParticleIndex(self.prox_ring)
	end
end

function modifier_proximity_illusion:OnCreated( kv )
	-- references
	self:StartIntervalThink(0.5)
	if not IsServer() then return end
	self.base_speed = self:GetAbility():GetCaster():FindAbilityByName("pathfinder_special_pa_blink_illusion"):GetLevelSpecialValueFor("speed", 1)

	self.prox_ring = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell_ring_rope.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	
	ParticleManager:SetParticleControl(self.prox_ring, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.prox_ring, 1, Vector(400,0,0))
end

function modifier_proximity_illusion:GetModifierMoveSpeedOverride()
	return self.base_speed
end

function modifier_proximity_illusion:OnIntervalThink()
	if self:GetParent() == nil or not IsServer() then
		return
	end
	local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, 400, 
				DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
				DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
	if #enemies < 1 then
		self:GetParent():ForceKill(false)
	end
end

