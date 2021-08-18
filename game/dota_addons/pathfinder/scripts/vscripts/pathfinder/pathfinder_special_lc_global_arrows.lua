pathfinder_special_lc_global_arrows = class({})
require("libraries.has_shard")
require("libraries.timers")

function pathfinder_special_lc_global_arrows:Precache(context)
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_legion_commander.vsndevts", context )
end

function pathfinder_special_lc_global_arrows:GetChannelAnimation()
	self:GetCaster():AddActivityModifier("fallen_legion")
    return ACT_DOTA_IDLE_RARE
end

function pathfinder_special_lc_global_arrows:GetChannelTime()	
    return self:GetLevelSpecialValueFor("channel_time", 1)
end


function pathfinder_special_lc_global_arrows:OnAbilityPhaseStart()
	if not IsServer() then return end
	self.interrupted = false	
	self.caster = self:GetCaster()

	self.interval = self:GetLevelSpecialValueFor("interval", 1)
	self.internal_timer = self.interval

	if RandomInt(1,100) < 50 then
		self.caster:EmitSound("legion_commander_legcom_duelhero_23")	
	else
		self.caster:EmitSound("legion_commander_legcom_duelhero_22")
	end

	self.delay = 0.6
	return true
end

function pathfinder_special_lc_global_arrows:OnAbilityPhaseInterrupted()
	self.interrupted = true
	self:StartCooldown(self:GetCooldown(self:GetLevel()))
end

function pathfinder_special_lc_global_arrows:OnChannelThink(eInterval)	
	if self.interrupted then 
		self:StartCooldown(self:GetCooldown(self:GetLevel()))
		return
	end

	if self.delay > 0 then
		self.delay = self.delay - eInterval
		return
	end

	self.internal_timer = self.internal_timer - eInterval

	if self.internal_timer > 0 then				
		return
	end

	local caster = self.caster
	
	self.internal_timer = self.interval	
	local enemies = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetOrigin(), nil, 8000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false )

	particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_duel.vpcf", PATTACH_ABSORIGIN, caster)	
	ParticleManager:SetParticleControl(particle, 7, caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle)

	local arrows_spell = caster:FindAbilityByName("pathfinder_lc_arrows")
	if arrows_spell:GetLevel() == 0 then
		return
	end

	for _,enemy in pairs(enemies) do
		if enemy ~= nil and not enemy:IsInvisible() and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then			
			caster:SetCursorPosition(enemy:GetAbsOrigin())
			arrows_spell:OnSpellStart()
			return
		end
	end	
end
