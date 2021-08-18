  
modifier_pathfinder_healing_ward_passive = class({})
LinkLuaModifier( "modifier_pathfinder_healing_ward_effect", "pathfinder/modifier_pathfinder_healing_ward_effect", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_healing_ward_passive:IsHidden()
	return true
end

function modifier_pathfinder_healing_ward_passive:IsDebuff()
	return false
end

function modifier_pathfinder_healing_ward_passive:IsPurgable()
	return false
end

local pfx

--------------------------------------------------------------------------------
-- Aura
function modifier_pathfinder_healing_ward_passive:IsAura()
	return (not self:GetCaster():PassivesDisabled())
end

function modifier_pathfinder_healing_ward_passive:GetModifierAura()
	return "modifier_pathfinder_healing_ward_effect"
end

function modifier_pathfinder_healing_ward_passive:GetAuraRadius()
	if IsServer() then		
		return self:GetCaster():GetOwner():FindAbilityByName("pathfinder_juggernaut_summon_healing_ward"):GetLevelSpecialValueFor("radius", self:GetCaster():GetOwner():FindAbilityByName("pathfinder_juggernaut_summon_healing_ward"):GetLevel() - 1)
	end
end

function modifier_pathfinder_healing_ward_passive:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_pathfinder_healing_ward_passive:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_pathfinder_healing_ward_passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH,
	}
end

function modifier_pathfinder_healing_ward_passive:OnIntervalThink()
	if IsServer() and self:GetCaster():GetOwner():FindAbilityByName("pathfinder_special_juggernaut_healing_ward_creep") then
		if self:GetParent():IsAttacking() then
			self:GetParent():StartGesture(ACT_DOTA_IDLE_RARE)
		else
			self:GetParent():FadeGesture(ACT_DOTA_IDLE_RARE)
		end
	end
end

function modifier_pathfinder_healing_ward_passive:CheckState()
	local state =
	{
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return state
end


function modifier_pathfinder_healing_ward_passive:PlayEffects()
	require("libraries.timers")
		-- Get Resources
	local particle_cast = "particles/econ/items/witch_doctor/wd_ti10_immortal_weapon/wd_ti10_immortal_voodoo.vpcf"
	sound_cast = "Hero_Juggernaut.HealingWard.Loop"

	-- Create Particle
	local healing_ward_ambient_pfx = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( healing_ward_ambient_pfx, 1, Vector( self:GetAbility():GetCaster():GetOwner():FindAbilityByName("pathfinder_juggernaut_summon_healing_ward"):GetLevelSpecialValueFor("radius", self:GetAbility():GetCaster():GetOwner():FindAbilityByName("pathfinder_juggernaut_summon_healing_ward"):GetLevel() - 1), 0, 450) )

	-- ParticleManager:SetParticleControl( healing_ward_ambient_pfx, 1, self:GetParent():GetAbsOrigin() )

	pfx = healing_ward_ambient_pfx

	-- Emit sound
	EmitSoundOn( sound_cast, self:GetParent() )

	local eruption_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_healing_ward_eruption.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(eruption_pfx, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(eruption_pfx)


	-- Timers:CreateTimer( self:GetAbility():GetLevelSpecialValueFor("duration", self:GetAbility():GetLevel() - 1), function()
	-- 	ParticleManager:DestroyParticle(healing_ward_ambient_pfx, true)
    --     return nil
	-- end
	-- )		
end

function modifier_pathfinder_healing_ward_passive:OnDeath(params) -- modifier kill instadeletes thanks valve
	if params.unit ~= self:GetParent() then return end
	StopSoundOn("Hero_Juggernaut.HealingWard.Loop", self:GetParent())
	self:GetAbility():GetCaster():GetOwner().active_healing_ward = nil
	if pfx then
		ParticleManager:DestroyParticle(pfx, false)
		ParticleManager:ReleaseParticleIndex(pfx)
	end

end

function modifier_pathfinder_healing_ward_passive:OnCreated( kv )
	if IsServer() then
		self:GetAbility():SetLevel(1)
	end
	self:StartIntervalThink(0.75)
	-- PlayEffects
	if self:GetCaster() and IsServer() then
		self:PlayEffects()
	end
	
end