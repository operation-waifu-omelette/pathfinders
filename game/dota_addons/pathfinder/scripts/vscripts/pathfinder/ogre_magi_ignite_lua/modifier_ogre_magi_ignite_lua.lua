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
modifier_ogre_magi_ignite_lua = class({})
require("libraries.timers")
LinkLuaModifier( "modifier_ogre_magi_ignite_multismash", "pathfinder/ogre_magi_ignite_lua/modifier_ogre_magi_ignite_lua", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
-- Classifications
function modifier_ogre_magi_ignite_lua:IsHidden()
	return false
end

function modifier_ogre_magi_ignite_lua:IsDebuff()
	if self:GetParent():GetTeamNumber() == DOTA_TEAM_GOODGUYS then
		return false
	end
	return true
end

function modifier_ogre_magi_ignite_lua:IsStunDebuff()
	return false
end

function modifier_ogre_magi_ignite_lua:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_ogre_magi_ignite_lua:OnCreated( kv )
	-- references
	self.slow = self:GetAbility():GetSpecialValueFor( "slow_movement_speed_pct" )
	local damage = self:GetAbility():GetSpecialValueFor( "burn_damage" )

	if not IsServer() then return end

	local interval = 1

	-- precache damage
	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self, --Optional.
	}
	-- ApplyDamage(damageTable)

	if self:GetParent():GetTeamNumber() == DOTA_TEAM_GOODGUYS then		
		self.heal = damage
	end	

	-- Start interval
	self:StartIntervalThink( interval )

	self.can_proc_multismash = false
	if self:GetCaster():FindAbilityByName("pathfinder_special_ignite_multismash") then
		self.can_proc_multismash = true
	end
end

function modifier_ogre_magi_ignite_lua:OnRefresh( kv )
	-- references
	self.slow = self:GetAbility():GetSpecialValueFor( "slow_movement_speed_pct" )
	local damage = self:GetAbility():GetSpecialValueFor( "burn_damage" )

	if self:GetParent():GetTeamNumber() == DOTA_TEAM_GOODGUYS then		
		self.heal = damage
	end	
	
	if not IsServer() then return end
	-- update damage

	self.damageTable.damage = damage
end

function modifier_ogre_magi_ignite_lua:OnRemoved()
end

function modifier_ogre_magi_ignite_lua:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_ogre_magi_ignite_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end

function modifier_ogre_magi_ignite_lua:OnAttackLanded(params)
	if IsServer() and params.target == self:GetParent() and params.attacker:GetTeamNumber() == self:GetCaster():GetTeamNumber() and self.can_proc_multismash == true and self:GetCaster():HasModifier("modifier_ogre_magi_multicast_lua") then
		local mod = params.attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ogre_magi_ignite_multismash", {duration=2, attack_target=self:GetParent():entindex()})

		local casts = 0

		if RandomInt( 0,100 ) < self:GetCaster():FindModifierByName("modifier_ogre_magi_multicast_lua").chance_2 then casts = 2 end
		if RandomInt( 0,100 ) < self:GetCaster():FindModifierByName("modifier_ogre_magi_multicast_lua").chance_3 then casts = 3 end
		if RandomInt( 0,100 ) < self:GetCaster():FindModifierByName("modifier_ogre_magi_multicast_lua").chance_4 then casts = 4 end

		if casts == 0 then return end

		local particle_cast = "particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf"
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_OVERHEAD_FOLLOW, params.attacker )
		ParticleManager:SetParticleControl( effect_cast, 1, Vector( casts, 2, 0 ) )
		ParticleManager:ReleaseParticleIndex( effect_cast )

		mod:SetStackCount(casts)

		self.can_proc_multismash = false
		local this_mod = self
		Timers(2, function()
			if this_mod then
				this_mod.can_proc_multismash = true
			end
		end)
	end
end

function modifier_ogre_magi_ignite_lua:GetModifierMoveSpeedBonus_Percentage()
	if self:GetParent():GetTeamNumber() == DOTA_TEAM_GOODGUYS then
		return self.slow * -1
	else
		return self.slow 
	end
end

require("libraries.has_shard")

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_ogre_magi_ignite_lua:OnIntervalThink()
	-- apply damage
	if self:GetParent():GetTeamNumber() == DOTA_TEAM_GOODGUYS then
		self:GetParent():Heal(self.heal, self:GetCaster())		
	else
		ApplyDamage( self.damageTable )		
	end
	-- play effects
	local sound_cast = "Hero_OgreMagi.Ignite.Damage"
	EmitSoundOn( sound_cast, self:GetParent() )
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_ogre_magi_ignite_lua:GetEffectName()
	return "particles/units/heroes/hero_ogre_magi/ogre_magi_ignite_debuff.vpcf"
end

function modifier_ogre_magi_ignite_lua:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


--------------------------------------------------------------------------------

modifier_ogre_magi_ignite_multismash = class({})

--------------------------------------------------------------------------------
function modifier_ogre_magi_ignite_multismash:OnCreated(kv)
	if not IsServer() then return end
	self.target = EntIndexToHScript(kv.attack_target)
	if not self.target then self:Destroy() end	
end

function modifier_ogre_magi_ignite_multismash:IsHidden()
	return true
end

function modifier_ogre_magi_ignite_multismash:IsDebuff()
	return false
end

function modifier_ogre_magi_ignite_multismash:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT ,		
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end

function modifier_ogre_magi_ignite_multismash:GetModifierAttackSpeedBonus_Constant()
	return 800
end

function modifier_ogre_magi_ignite_multismash:OnAttack(params)
	if IsServer() and params.attacker == self:GetParent() then
		if params.target ~= self.target then
			self:Destroy()
		end
	end
end

function modifier_ogre_magi_ignite_multismash:OnAttackLanded(params)
	if IsServer() and params.attacker == self:GetParent() then
		if params.target ~= self.target then
			self:Destroy()
		end		

		self:SetStackCount(self:GetStackCount() - 1)

	end
end

function modifier_ogre_magi_ignite_multismash:OnStackCountChanged(iStackCount)
	if self:GetStackCount() <= 0 then
		self:Destroy()
	end
end
