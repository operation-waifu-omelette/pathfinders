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
--------------------------------------------------------------------------------
modifier_pathfinder_trap_catapult_passive = class({})

function modifier_pathfinder_trap_catapult_passive:Precache( context )
	PrecacheResource( "particle", "particles/econ/courier/courier_trail_int_2012/courier_trail_international_2012.vpcf", context )
end

--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_trap_catapult_passive:IsHidden()
	return false
end

function modifier_pathfinder_trap_catapult_passive:IsDebuff()
	return false
end

function modifier_pathfinder_trap_catapult_passive:IsPurgable()
	return false
end

function modifier_pathfinder_trap_catapult_passive:OnDestroy()

	if not IsServer() then return end
	if self.healing_ward_ambient_pfx then
		ParticleManager:DestroyParticle(self.healing_ward_ambient_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.healing_ward_ambient_pfx)
	end
end

function modifier_pathfinder_trap_catapult_passive:OnCreated(table)
	self.healing_ward_ambient_pfx = ParticleManager:CreateParticle( "particles/items_fx/gem_truesight_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( self.healing_ward_ambient_pfx, 1, Vector( 600, 0, 450) )
end


function modifier_pathfinder_trap_catapult_passive:CheckState()
	local state = {[MODIFIER_STATE_NO_UNIT_COLLISION] = true,										
					[MODIFIER_STATE_NO_HEALTH_BAR] = true,
					[MODIFIER_STATE_PROVIDES_VISION] = true,
					[MODIFIER_STATE_INVULNERABLE] = true,
				}

	return state
end

function modifier_pathfinder_trap_catapult_passive:GetStatusEffectName()
	return "particles/status_fx/status_effect_snapfire_magma.vpcf"
end

function modifier_pathfinder_trap_catapult_passive:GetEffectName()	
	return "particles/econ/courier/courier_trail_int_2012/courier_trail_international_2012.vpcf"
end

function modifier_pathfinder_trap_catapult_passive:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function modifier_pathfinder_trap_catapult_passive:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 10000
end
