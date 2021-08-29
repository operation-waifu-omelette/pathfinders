modifier_cosmetic_skin_gold_character = class({})

function modifier_cosmetic_skin_gold_character:IsHidden() return true end
function modifier_cosmetic_skin_gold_character:IsDebuff() return false end
function modifier_cosmetic_skin_gold_character:IsPurgable() return false end
function modifier_cosmetic_skin_gold_character:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_cosmetic_skin_gold_character:OnCreated()
	if not IsServer() then return end
	
	local parent = self:GetParent()
	local pos = parent:GetAbsOrigin()
	self.gold = "particles/econ/courier/courier_nian/courier_nian_bag_coin.vpcf"
	
	self.pfx1 = ParticleManager:CreateParticle( self.gold, PATTACH_CUSTOMORIGIN_FOLLOW, parent )
	self.pfx2 = ParticleManager:CreateParticle( self.gold, PATTACH_CUSTOMORIGIN_FOLLOW, parent )
	self.pfx3 = ParticleManager:CreateParticle( self.gold, PATTACH_CUSTOMORIGIN_FOLLOW, parent )

	ParticleManager:SetParticleControlEnt( self.pfx1, 0, parent, PATTACH_POINT_FOLLOW, "attach_attack1", pos, true )
	ParticleManager:SetParticleControlEnt( self.pfx1, 1, parent, PATTACH_POINT_FOLLOW, "attach_attack1", pos, true )
	ParticleManager:SetParticleControlEnt( self.pfx2, 1, parent, PATTACH_POINT_FOLLOW, "attach_attack2", pos, true )
	ParticleManager:SetParticleControlEnt( self.pfx3, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", pos, true )
	ParticleManager:SetParticleControlEnt( self.pfx3, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", pos, true )
end

function modifier_cosmetic_skin_gold_character:OnDestroy()
	if not IsServer() then return end
	
	ParticleManager:DestroyParticle(self.pfx1,false)
	ParticleManager:DestroyParticle(self.pfx2,false)
	ParticleManager:DestroyParticle(self.pfx3,false)
	
	ParticleManager:ReleaseParticleIndex(self.pfx1)
	ParticleManager:ReleaseParticleIndex(self.pfx2)
	ParticleManager:ReleaseParticleIndex(self.pfx3)
end

function modifier_cosmetic_skin_gold_character:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_gold_lvl2.vpcf"
end
function modifier_cosmetic_skin_gold_character:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end
function modifier_cosmetic_skin_gold_character:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end
