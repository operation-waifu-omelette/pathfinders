modifier_cosmetic_skin_nightwing = class({})

function modifier_cosmetic_skin_nightwing:IsHidden() return true end
function modifier_cosmetic_skin_nightwing:IsDebuff() return false end
function modifier_cosmetic_skin_nightwing:IsPurgable() return false end
function modifier_cosmetic_skin_nightwing:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_cosmetic_skin_nightwing:GetStatusEffectName()
	return "particles/collection/hero_skins/nightwing.vpcf"
end
