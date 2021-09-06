-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
modifier_dark_willow_shadow_realm_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_dark_willow_shadow_realm_lua:IsHidden()
	return false
end

function modifier_dark_willow_shadow_realm_lua:IsDebuff()
	return false
end

function modifier_dark_willow_shadow_realm_lua:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_dark_willow_shadow_realm_lua:OnCreated( kv )
	-- references
	self.bonus_range = self:GetAbility():GetSpecialValueFor( "attack_range_bonus" )
	self.bonus_damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.bonus_max = self:GetAbility():GetSpecialValueFor( "max_damage_duration" )
	self.buff_duration = 3
	self.assault = self:GetCaster():FindAbilityByName("dark_willow_shadow_realm_lua_assault")

	self.phased = self:GetCaster():FindAbilityByName("dark_willow_shadow_realm_lua_phase")

	self.blast_rad = 0
	if self:GetCaster():FindAbilityByName("dark_willow_shadow_realm_lua_blast") then
		self.blast_rad = self:GetCaster():FindAbilityByName("dark_willow_shadow_realm_lua_blast"):GetSpecialValueFor("blast_radius")
	end

	self.move_modifier = 0
	self.heal_modifier = 0
	if self.phased then
		self.move_modifier = self:GetCaster():FindAbilityByName("dark_willow_shadow_realm_lua_blast"):GetSpecialValueFor("speed_bonus")
		self.heal_modifier = self:GetCaster():FindAbilityByName("dark_willow_shadow_realm_lua_blast"):GetSpecialValueFor("healing_multiplier")
	end

	if not IsServer() then return end
	-- set creation time
	self.create_time = GameRules:GetGameTime()

	-- dodge projectiles
	ProjectileManager:ProjectileDodge( self:GetParent() )

	-- stop if currently attacking
	if self:GetParent():GetAggroTarget() and not self.assault then

		-- unit:Stop() is not enough to stop
		local order = {
			UnitIndex = self:GetParent():entindex(),
			OrderType = DOTA_UNIT_ORDER_STOP,
		}
		ExecuteOrderFromTable( order )
	end

	self:PlayEffects()
end

function modifier_dark_willow_shadow_realm_lua:OnRefresh( kv )
	-- references
	self.bonus_range = self:GetAbility():GetSpecialValueFor( "attack_range_bonus" )
	self.bonus_damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.bonus_max = self:GetAbility():GetSpecialValueFor( "max_damage_duration" )
	self.buff_duration = 3

	if not IsServer() then return end
	-- dodge projectiles
	ProjectileManager:ProjectileDodge( self:GetParent() )
end

function modifier_dark_willow_shadow_realm_lua:OnRemoved()
end

function modifier_dark_willow_shadow_realm_lua:OnDestroy()
	-- stop sound
	local sound_cast = "Hero_DarkWillow.Shadow_Realm"
	StopSoundOn( sound_cast, self:GetParent() )
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_dark_willow_shadow_realm_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_PROJECTILE_NAME,

		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
	}

	return funcs
end

function modifier_dark_willow_shadow_realm_lua:GetModifierMoveSpeedBonus_Percentage()
	if not IsServer() then return end
	return self.move_modifier
end

function modifier_dark_willow_shadow_realm_lua:GetModifierHPRegenAmplify_Percentage()
	if not IsServer() then return end
	return self.heal_modifier
end

function modifier_dark_willow_shadow_realm_lua:GetModifierAttackRangeBonus()
	return self.bonus_range
end
function modifier_dark_willow_shadow_realm_lua:GetModifierProjectileName()
	return "particles/units/heroes/hero_dark_willow/dark_willow_shadow_attack_dummy.vpcf"
end

function modifier_dark_willow_shadow_realm_lua:OnAttack( params )
	if not IsServer() then return end
	if params.attacker~=self:GetParent() then return end

	-- calculate time
	local time = GameRules:GetGameTime() - self.create_time
	time = math.min( time/self.bonus_max, 1 )

	-- create modifier
	self:GetParent():AddNewModifier(
		self:GetCaster(), -- player source
		self:GetAbility(), -- ability source
		"modifier_dark_willow_shadow_realm_lua_buff", -- modifier name
		{
			duration = self.buff_duration,
			record = params.record,
			damage = self.bonus_damage,
			time = time,
			target = params.target:entindex(),
			blast_rad = self.blast_rad,
		} -- kv
	)

	-- play sound
	local sound_cast = "Hero_DarkWillow.Shadow_Realm.Attack"
	EmitSoundOn( sound_cast, self:GetParent() )

	-- destroy if doesn't have assault
	if not self.assault then
		self:Destroy()
	end
end
--------------------------------------------------------------------------------
-- Status Effects
function modifier_dark_willow_shadow_realm_lua:CheckState()
	local state = {
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = self:GetCaster():HasAbility("dark_willow_shadow_realm_lua_phase"),
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = self:GetCaster():HasAbility("dark_willow_shadow_realm_lua_phase"),
		[MODIFIER_STATE_INVISIBLE] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_dark_willow_shadow_realm_lua:GetStatusEffectName()
	return "particles/status_fx/status_effect_dark_willow_shadow_realm.vpcf"
end

function modifier_dark_willow_shadow_realm_lua:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_dark_willow/dark_willow_shadow_realm.vpcf"
	local sound_cast = "Hero_DarkWillow.Shadow_Realm"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self:GetParent(),
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetParent() )
end