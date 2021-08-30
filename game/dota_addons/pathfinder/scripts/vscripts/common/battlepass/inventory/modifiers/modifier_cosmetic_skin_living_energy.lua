modifier_cosmetic_skin_living_energy = class({})

function modifier_cosmetic_skin_living_energy:IsHidden() return true end
function modifier_cosmetic_skin_living_energy:IsDebuff() return false end
function modifier_cosmetic_skin_living_energy:IsPurgable() return false end
function modifier_cosmetic_skin_living_energy:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_cosmetic_skin_living_energy:GetStatusEffectName()
	return "particles/collection/hero_skins/living_energy_status_fx.vpcf"
end
