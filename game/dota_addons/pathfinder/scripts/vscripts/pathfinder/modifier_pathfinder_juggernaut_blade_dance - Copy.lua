modifier_pathfinder_juggernaut_blade_dance = class({})
require("libraries.has_shard")

--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_juggernaut_blade_dance:IsHidden()
	return true
end

function modifier_pathfinder_juggernaut_blade_dance:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_pathfinder_juggernaut_blade_dance:OnCreated( kv )
	-- references
	self.crit_chance = self:GetAbility():GetLevelSpecialValueFor( "blade_dance_crit_chance", self:GetAbility():GetLevel() - 1 )
	self.crit_mult = self:GetAbility():GetLevelSpecialValueFor( "blade_dance_crit_mult", self:GetAbility():GetLevel() - 1 )
end

function modifier_pathfinder_juggernaut_blade_dance:OnRefresh( kv )
	-- references
	self.crit_chance = self:GetAbility():GetLevelSpecialValueFor( "blade_dance_crit_chance", self:GetAbility():GetLevel() - 1 )
	self.crit_mult = self:GetAbility():GetLevelSpecialValueFor( "blade_dance_crit_mult", self:GetAbility():GetLevel() - 1 )
end

function modifier_pathfinder_juggernaut_blade_dance:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_pathfinder_juggernaut_blade_dance:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		--MODIFIER_EVENT_ON_MODIFIER_ADDED,
	}

	return funcs
end
function modifier_pathfinder_juggernaut_blade_dance:GetModifierPreAttack_CriticalStrike( params )
	if IsServer() and (not self:GetParent():PassivesDisabled()) then
		if params.target:GetTeamNumber()==self:GetParent():GetTeamNumber() then
			return
		end

		-- Throw dice
		if RandomInt(0, 100)<self.crit_chance then
			self.record = params.record

			if HasShard(self:GetCaster(), "pathfinder_special_juggernaut_blade_dance_illusion") then
				local illusion_ability = self:GetAbility():GetCaster():FindAbilityByName("pathfinder_special_juggernaut_blade_dance_illusion")

				if true then--not self:GetAbility():GetCaster():IsIllusion() then
					local modifierKeys = {}
					modifierKeys.outgoing_damage = 40
					modifierKeys.incoming_damage = 140
					modifierKeys.duration = illusion_ability:GetSpecialValueFor("illusion_duration")
					
					local illusion = CreateIllusions( self:GetAbility():GetCaster(), self:GetAbility():GetCaster(), modifierKeys, 1, 20, true, true)
					illusion[1]:AddNewModifier(self:GetCaster(), self, "modifier_phantom_lancer_juxtapose_illusion", {})
					illusion[1]:SetControllableByPlayer(-1, true)	
				end
			end

			if HasShard(self:GetCaster(), "pathfinder_special_juggernaut_blade_dance_reduce_omnislash_cooldown") then
				local omnislash = self:GetAbility():GetCaster():FindAbilityByName("pathfinder_juggernaut_omni_slash")
				local cd_spell = self:GetAbility():GetCaster():FindAbilityByName("pathfinder_special_juggernaut_blade_dance_reduce_omnislash_cooldown")
				if omnislash:GetCooldownTimeRemaining() > cd_spell:GetSpecialValueFor("seconds") then
					local cd = omnislash:GetCooldownTimeRemaining()
					omnislash:EndCooldown()
					omnislash:StartCooldown(cd - cd_spell:GetSpecialValueFor("seconds"))
				end
			end
			
			return self.crit_mult
		end
	end
end
function modifier_pathfinder_juggernaut_blade_dance:GetModifierProcAttack_Feedback( params )
	if IsServer() then
		if self.record and self.record == params.record then
			self.record = nil

			-- Play effects
			local sound_cast = "Hero_Juggernaut.BladeDance"
			EmitSoundOn( sound_cast, params.target )
		end
	end
end
--------------------------------------------------------------------------------

function modifier_pathfinder_juggernaut_blade_dance:OnAttackLanded( params )
	if IsServer() then
		
	end
	
	return 0
end

-- function modifier_pathfinder_juggernaut_blade_dance:OnModifierAdded( keys )
-- 	for ind = 0, self:GetCaster():GetModifierCount() do
-- 		print(self:GetCaster():GetModifierNameByIndex(ind))
-- 	end	
-- end

