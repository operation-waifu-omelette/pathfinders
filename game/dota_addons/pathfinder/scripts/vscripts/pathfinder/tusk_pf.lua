LinkLuaModifier("modifier_tusk_frozen_sigil_pf_aura", "pathfinder/tusk_pf", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tusk_frozen_sigil_pf_effect", "pathfinder/tusk_pf", LUA_MODIFIER_MOTION_NONE)

require("libraries.has_shard")
require("libraries.timers")

tusk_frozen_sigil_pf										= class({})
modifier_tusk_frozen_sigil_pf_aura								= class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,		
})
modifier_tusk_frozen_sigil_pf_effect								= class({
	IsHidden				= function(self) return false end,	
})

function tusk_frozen_sigil_pf:OnUpgrade()
	self:GetCaster():SwapAbilities("aghanim_empty_spell1", "tusk_frozen_sigil_pf", false, true)
end

function tusk_frozen_sigil_pf:OnSpellStart()
	local caster = self:GetCaster()
	local targetPoint = self:GetCursorPosition()

	local sigil = nil
	if IsServer() then
		sigil = CreateUnitByName("tusk_sigil_pf", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
		sigil:SetOwner(caster)	
		sigil:AddNewModifier(caster, self, "modifier_tusk_frozen_sigil_pf_aura", {})
		sigil:AddNewModifier(caster, self, "modifier_kill", {duration = self:GetLevelSpecialValueFor("duration",1)})

		local caster_dmg = caster:GetAverageTrueAttackDamage(nil)
		local dmg_pct = self:GetLevelSpecialValueFor("attack_damage_percent",1)

		sigil:SetBaseDamageMin(caster_dmg / 100 * dmg_pct)
		sigil:SetBaseDamageMax(caster_dmg / 100 * dmg_pct)
	end
	
	sigil:SetControllableByPlayer(caster:GetPlayerID(), true)	
		
	sigil:SetContextThink(DoUniqueString(self:GetName()), function()
		sigil:MoveToPosition(targetPoint)
		return nil
	end, FrameTime())	
end

--------------
function modifier_tusk_frozen_sigil_pf_aura:OnCreated()
	if not IsServer() then return end
	self.radius = self:GetAbility():GetLevelSpecialValueFor("radius",1)
	self.nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_tusk/tusk_frozen_sigil.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl(self.nFXIndex, 1, Vector(self.radius,0,-1 * self.radius))
	ParticleManager:SetParticleControl(self.nFXIndex, 2, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.nFXIndex, 3, self:GetParent():GetAbsOrigin())
	self:AddParticle( self.nFXIndex, false, false, -1, false, false )

	self:StartIntervalThink(1)
end

function modifier_tusk_frozen_sigil_pf_aura:OnIntervalThink()
	local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
	for  _,enemy in pairs(enemies) do
		self:GetParent():PerformAttack(enemy, false, true, true, true, true, false, false)
	end
end

function modifier_tusk_frozen_sigil_pf_aura:IsAura()					return true end
function modifier_tusk_frozen_sigil_pf_aura:IsAuraActiveOnDeath() 		return false end

function modifier_tusk_frozen_sigil_pf_aura:GetAuraRadius()				
	return self.radius 
end

function modifier_tusk_frozen_sigil_pf_aura:GetAuraSearchTeam()			
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_tusk_frozen_sigil_pf_aura:GetAuraSearchType()			
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_tusk_frozen_sigil_pf_aura:GetModifierAura()			
	return "modifier_tusk_frozen_sigil_pf_effect" 
end


function modifier_tusk_frozen_sigil_pf_aura:CheckState()
	local state =
	{
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
	return state
end

function modifier_tusk_frozen_sigil_pf_aura:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
	}
end

function modifier_tusk_frozen_sigil_pf_aura:GetVisualZDelta()        
	return 390 -- This is your desired height.
end

function modifier_tusk_frozen_sigil_pf_aura:OnDeath(params) -- modifier kill instadeletes thanks valve
	if not IsServer() then return end
	if params.unit ~= self:GetParent() then return end		
	if self.nFXIndex then
		ParticleManager:DestroyParticle(self.nFXIndex, false)
		ParticleManager:ReleaseParticleIndex(self.nFXIndex)
	end
	local deathFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_tusk/tusk_frozen_sigil_death.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl(deathFX, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(deathFX, 2, self:GetParent():GetAbsOrigin())
	self:GetParent():RemoveSelf()
end

----------------------------------

function modifier_tusk_frozen_sigil_pf_effect:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_tusk_frozen_sigil_pf_effect:OnAttackLanded(params)
	if not IsServer() or params.target ~= self:GetParent() then return end
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tidehunter/tidehunter_krakenshell_purge.vpcf", PATTACH_ABSORIGIN, self:GetParent())
	ParticleManager:ReleaseParticleIndex(particle)		
	local ability = self:GetCaster():FindAbilityByName("tusk_frozen_sigil_pf")	
	self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_rooted", { duration = ability:GetLevelSpecialValueFor("freeze_duration",1) } )			
	EmitSoundOn( "IceDragonMaw.Trigger", self:GetParent() )
end


function modifier_tusk_frozen_sigil_pf_effect:GetStatusEffectName()
	return "particles/units/heroes/hero_tusk/tusk_frozen_sigil_status.vpcf"
end