--------------------------------------------------------------------------------
modifier_dark_willow_bramble_maze_lua_heal_buff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_dark_willow_bramble_maze_lua_heal_buff:IsHidden()
	return true
end

function modifier_dark_willow_bramble_maze_lua_heal_buff:IsDebuff()
	return false
end

function modifier_dark_willow_bramble_maze_lua_heal_buff:IsStunDebuff()
	return false
end

function modifier_dark_willow_bramble_maze_lua_heal_buff:IsPurgable()
	return true
end

function modifier_dark_willow_bramble_maze_lua_heal_buff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_dark_willow_bramble_maze_lua_heal_buff:OnCreated( kv )
    if not IsServer() then return end
    Msg("Healing Target " .. self:GetParent():GetName())
    local heal_value = (self:GetParent():GetMaxHealth() / 100) * kv.healing_percent
    heal_value = heal_value + self:GetParent():FindAbilityByName("dark_willow_bramble_maze_lua"):GetSpecialValueFor("latch_damage")

	self:GetParent():Heal(heal_value, self:GetCaster())

	-- Start interval
	self:StartIntervalThink( 1 )

    self:PlayEffect()

end

function modifier_dark_willow_bramble_maze_lua_heal_buff:OnRefresh( kv )
	
end

function modifier_dark_willow_bramble_maze_lua_heal_buff:OnRemoved()
end

function modifier_dark_willow_bramble_maze_lua_heal_buff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_dark_willow_bramble_maze_lua_heal_buff:CheckState()
	local state = {
        
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_dark_willow_bramble_maze_lua_heal_buff:OnIntervalThink()
	self:Destroy()
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_dark_willow_bramble_maze_lua_heal_buff:PlayEffect()
    local particle_cast = "particles/dark_willow_bramble_maze_heal.vpcf"

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