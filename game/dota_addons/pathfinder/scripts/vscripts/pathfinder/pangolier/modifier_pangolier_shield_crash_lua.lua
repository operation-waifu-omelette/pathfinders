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
------------------------------------------------------------------------------------------------------
modifier_pangolier_shield_crash_lua = class({})

function modifier_pangolier_shield_crash_lua:IsHidden() return false end

function modifier_pangolier_shield_crash_lua:IsDebuff() return false end

function modifier_pangolier_shield_crash_lua:IsPurgable() return true end
------------------------------------------------------------------------------------------------------

--[[---------------------------------------------------------------------
	PANGOLIER SHIELD CRASH MODIFIER
]]------------------------------------------------------------------------


function modifier_pangolier_shield_crash_lua:OnCreated( kv )

	local stack_pct = self:GetAbility():GetSpecialValueFor( "hero_stacks" )
	
	if not IsServer() then return end

	self.reduction = kv.stack * stack_pct
	self:SetStackCount( self.reduction )

	self:PlayEffects()

end

function modifier_pangolier_shield_crash_lua:OnRefresh( kv )

	local stack_pct = self:GetAbility():GetSpecialValueFor( "hero_stacks" )

	if not IsServer() then return end

	local reduction = kv.stack * stack_pct
	if self.reduction<reduction then
		self.reduction = reduction
		self:PlayEffects()
	end

	self:SetStackCount( self.reduction )

end


function modifier_pangolier_shield_crash_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
	return funcs
end

function modifier_pangolier_shield_crash_lua:GetModifierIncomingDamage_Percentage()
	return -self.reduction
end

--------------------------------------------------------------------------------
-- Graphics & Animations
-------------------------------------------------------------------------------
function modifier_pangolier_shield_crash_lua:GetStatusEffectName()
	return "particles/status_fx/status_effect_pangolier_shield.vpcf"
end

function modifier_pangolier_shield_crash_lua:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function modifier_pangolier_shield_crash_lua:PlayEffects()

	if self.effect_cast then
		ParticleManager:DestroyParticle( self.effect_cast, false )
	end

	local particle_cast = "particles/units/heroes/hero_pangolier/pangolier_tailthump_buff.vpcf"

	local parent = self:GetParent()

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, parent )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		parent,
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true 
	)
	ParticleManager:SetParticleControl( effect_cast, 3, Vector( self.reduction, 0, 0 ) )

	self:AddParticle(
		effect_cast,
		false, 
		false, 
		-1, 
		false, 
		false 
	)
	
	self.effect_cast = effect_cast
end