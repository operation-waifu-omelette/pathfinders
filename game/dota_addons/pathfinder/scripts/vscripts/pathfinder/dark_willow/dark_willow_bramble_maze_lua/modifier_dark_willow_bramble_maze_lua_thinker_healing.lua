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
modifier_dark_willow_bramble_maze_lua_thinker_healing = class({})


--------------------------------------------------------------------------------
-- Classifications
function modifier_dark_willow_bramble_maze_lua_thinker_healing:IsHidden()
	return false
end

function modifier_dark_willow_bramble_maze_lua_thinker_healing:IsDebuff()
	return false
end

function modifier_dark_willow_bramble_maze_lua_thinker_healing:IsStunDebuff()
	return false
end

function modifier_dark_willow_bramble_maze_lua_thinker_healing:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_dark_willow_bramble_maze_lua_thinker_healing:OnCreated( kv )
	-- references
	self.duration = self:GetAbility():GetSpecialValueFor( "placement_duration" )
	self.radius = self:GetAbility():GetSpecialValueFor( "placement_range" )
	self.damage = self:GetAbility():GetSpecialValueFor( "latch_damage" )

	self:StartIntervalThink( self.duration )

	local units = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),
        self:GetParent():GetAbsOrigin(),
        nil,
        self.radius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
        false
	)
	if units then
		for _,unit in pairs(units) do
			local healing = ( unit:GetMaxHealth() / 100 ) * 10 + ( self.damage )
			unit:Heal( healing, self:GetCaster() )
		end
	end
    
end

function modifier_dark_willow_bramble_maze_lua_thinker_healing:OnRefresh( kv )
	
end

function modifier_dark_willow_bramble_maze_lua_thinker_healing:OnRemoved()
end

function modifier_dark_willow_bramble_maze_lua_thinker_healing:OnDestroy()
	if not IsServer() then return end
	UTIL_Remove( self:GetParent() )
end


--------------------------------------------------------------------------------
-- Interval Effects
function modifier_dark_willow_bramble_maze_lua_thinker_healing:OnIntervalThink()
	self:Destroy()
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_dark_willow_bramble_maze_lua_thinker_healing:PlayEffects()
	
	-- Get Resources
	local particle_cast = "particles/econ/items/witch_doctor/wd_ti10_immortal_weapon/wd_ti10_immortal_voodoo.vpcf"

	-- Create Particle
	local healing_ambient_pfx = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl(
		healing_ambient_pfx, 
		1, 
		Vector( self.radius, 0, 450) 
	)
end