--------------------------------------------------------------------------------
modifier_dark_willow_bramble_maze_lua_boost_buff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_dark_willow_bramble_maze_lua_boost_buff:IsHidden()
	return false
end

function modifier_dark_willow_bramble_maze_lua_boost_buff:IsDebuff()
	return false
end

function modifier_dark_willow_bramble_maze_lua_boost_buff:IsStunDebuff()
	return false
end

function modifier_dark_willow_bramble_maze_lua_boost_buff:IsPurgable()
	return true
end

function modifier_dark_willow_bramble_maze_lua_boost_buff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_dark_willow_bramble_maze_lua_boost_buff:OnCreated( kv )
    if not IsServer() then return end

    self.boost_duration = self:GetAbility():GetSpecialValueFor( "placement_duration" )
    self.magic_res = self:GetCaster():FindAbilityByName("dark_willow_bramble_maze_lua_healing"):GetSpecialValueFor("magical_resistance")
    self.spell_amp = self:GetCaster():FindAbilityByName("dark_willow_bramble_maze_lua_healing"):GetSpecialValueFor("spell_amp")
    self.attack_rate = self:GetCaster():FindAbilityByName("dark_willow_bramble_maze_lua_healing"):GetSpecialValueFor("attack_rate_increace")

    self:SetDuration( self.boost_duration, true )

	-- Start interval
	self:StartIntervalThink( self.boost_duration )

    self:PlayEffect()

end

function modifier_dark_willow_bramble_maze_lua_boost_buff:OnRefresh( kv )
	
end

function modifier_dark_willow_bramble_maze_lua_boost_buff:OnRemoved()
end

function modifier_dark_willow_bramble_maze_lua_boost_buff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_dark_willow_bramble_maze_lua_boost_buff:CheckState()
	local state = {
        
	}

	return state
end

function modifier_dark_willow_bramble_maze_lua_boost_buff:DeclareFunctions()
    local funcs = 
	{
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end

function modifier_dark_willow_bramble_maze_lua_boost_buff:GetModifierMagicalResistanceBonus()
    return self.magic_res
end

function modifier_dark_willow_bramble_maze_lua_boost_buff:GetModifierSpellAmplify_Percentage()
    return self.spell_amp
end

function modifier_dark_willow_bramble_maze_lua_boost_buff:GetModifierAttackSpeedBonus_Constant()
    return self.attack_rate
end






--------------------------------------------------------------------------------
-- Interval Effects
function modifier_dark_willow_bramble_maze_lua_boost_buff:OnIntervalThink()
	if IsServer() then
		self:StartIntervalThink( -1 )
        self:Destroy()
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_dark_willow_bramble_maze_lua_boost_buff:PlayEffect()
    local particle_cast = "particles/units/heroes/hero_dark_willow/dark_willow_shadow_realm_embers.vpcf"

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
end