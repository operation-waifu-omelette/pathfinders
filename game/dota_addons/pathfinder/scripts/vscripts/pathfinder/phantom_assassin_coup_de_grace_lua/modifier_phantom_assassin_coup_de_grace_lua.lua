modifier_phantom_assassin_coup_de_grace_lua = class({})
require("libraries.timers")

--------------------------------------------------------------------------------
-- Classifications
function modifier_phantom_assassin_coup_de_grace_lua:IsHidden()
	-- actual true
	return false
end

function modifier_phantom_assassin_coup_de_grace_lua:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_phantom_assassin_coup_de_grace_lua:OnCreated( kv )
	-- references
	self.crit_chance = self:GetAbility():GetSpecialValueFor( "crit_chance" )
	self.crit_bonus = self:GetAbility():GetSpecialValueFor( "crit_bonus" )

	self.can_proc_dagger = true
end

function modifier_phantom_assassin_coup_de_grace_lua:OnRefresh( kv )
	-- references
	self.crit_chance = self:GetAbility():GetSpecialValueFor( "crit_chance" )
	self.crit_bonus = self:GetAbility():GetSpecialValueFor( "crit_bonus" )
end

function modifier_phantom_assassin_coup_de_grace_lua:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_phantom_assassin_coup_de_grace_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}

	return funcs
end

function modifier_phantom_assassin_coup_de_grace_lua:GetModifierPreAttack_CriticalStrike( params )
	if IsServer() and (not self:GetParent():PassivesDisabled()) then
		if self:RollChance( self.crit_chance ) then
			self.record = params.record
			if params.attacker:HasAbility("pathfinder_special_pa_crit_lifesteal") then
				local pct = params.attacker:FindAbilityByName("pathfinder_special_pa_crit_lifesteal"):GetLevelSpecialValueFor("percent", 1)
				local dmg = params.attacker:GetAverageTrueAttackDamage(nil)
				params.attacker:Heal(dmg * (self.crit_bonus / 100) / 100 * pct, params.attacker)				
			end
			if params.attacker:HasAbility("pathfinder_special_pa_crit_fear") then
				local dur = params.attacker:FindAbilityByName("pathfinder_special_pa_crit_fear"):GetLevelSpecialValueFor("duration", 1)
				local range = params.attacker:FindAbilityByName("pathfinder_special_pa_crit_fear"):GetLevelSpecialValueFor("radius", 1)
				local hEnemies = FindUnitsInRadius( params.attacker:GetTeam(),params.target:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )

				for _,enemy in pairs(hEnemies) do
					if enemy ~= params.target then
								local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_crystalmaiden/maiden_frostbite.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy )
								ParticleManager:SetParticleControlEnt( nFXIndex, 1, enemy, PATTACH_ABSORIGIN_FOLLOW, nil, enemy:GetAbsOrigin(), false )
								ParticleManager:ReleaseParticleIndex( nFXIndex )
								EmitSoundOn( "IceDragonMaw.Trigger", enemy )

						enemy:AddNewModifier( nil, nil, "modifier_large_frostbitten_icicle", { duration = dur } )		
					end
				end			
			end
			if params.attacker:HasAbility("pathfinder_special_pa_crit_dagger") and params.target:HasModifier("modifier_phantom_assassin_stifling_dagger_lua") and self.can_proc_dagger == true then
				self.can_proc_dagger = false
				Timers:CreateTimer(0.4, function()
					self.can_proc_dagger = true
					return nil
				end)
				local amount = params.attacker:FindAbilityByName("pathfinder_special_pa_crit_dagger"):GetLevelSpecialValueFor("amount", 1)
				local dagger = params.attacker:FindAbilityByName("phantom_assassin_stifling_dagger_lua")				
	
				local hEnemies = FindUnitsInRadius( params.attacker:GetTeam(),params.target:GetAbsOrigin(), nil, dagger:GetCastRange(params.target:GetAbsOrigin(), nil), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )

				if #hEnemies > 0 then
					for i=1,amount do
						if #hEnemies > i then
							params.attacker:SetCursorCastTarget(hEnemies[i])
							dagger:OnSpellStart()
						end
					end
				end
			end
			return self.crit_bonus
		end
	end
end

function modifier_phantom_assassin_coup_de_grace_lua:GetModifierProcAttack_Feedback( params )
	if IsServer() then
		if self.record then
			self.record = nil
			self:PlayEffects( params.target )			
		end
	end
end
--------------------------------------------------------------------------------
-- Helper
function modifier_phantom_assassin_coup_de_grace_lua:RollChance( chance )
	local rand = math.random()
	if rand<chance/100 then
		return true
	end
	return false
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_phantom_assassin_coup_de_grace_lua:PlayEffects( target )
	-- Load effects
	local particle_cast = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf"
	local sound_cast = "Hero_PhantomAssassin.CoupDeGrace"

	-- if target:IsMechanical() then
	-- 	particle_cast = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact_mechanical.vpcf"
	-- 	sound_cast = "Hero_PhantomAssassin.CoupDeGrace.Mech"
	-- end

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt( effect_cast, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true )
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 1, -self:GetParent():GetForwardVector() )
	ParticleManager:SetParticleControlEnt( effect_cast, 10, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetOrigin(), true )
	ParticleManager:ReleaseParticleIndex( effect_cast )						

	EmitSoundOn( sound_cast, target )
end