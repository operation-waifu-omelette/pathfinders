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
dark_willow_bramble_maze_lua_thicket_thinker = class({})
LinkLuaModifier( "dark_willow_bramble_maze_lua", "pathfinder/dark_willow/dark_willow_bramble_maze_lua/dark_willow_bramble_maze_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Classifications
function dark_willow_bramble_maze_lua_thicket_thinker:IsHidden()
	return false
end

function dark_willow_bramble_maze_lua_thicket_thinker:IsDebuff()
	return false
end

function dark_willow_bramble_maze_lua_thicket_thinker:IsStunDebuff()
	return false
end

function dark_willow_bramble_maze_lua_thicket_thinker:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function dark_willow_bramble_maze_lua_thicket_thinker:OnCreated( kv )
	-- references
	self.root_chance = kv.chance / 100.0
    Msg("Mdofied Chance " .. self.root_chance.. "\n")
    self.max_checks = kv.duration / kv.interval
    self.current_checks = 0
    self.check_radius = kv.radius

    Msg("Bramble Thicket Event Started \nBramble Interval: " .. kv.interval .. "\n")

    self:StartIntervalThink( kv.interval )
end

function dark_willow_bramble_maze_lua_thicket_thinker:OnRefresh( kv )
end

function dark_willow_bramble_maze_lua_thicket_thinker:OnRemoved()
end

function dark_willow_bramble_maze_lua_thicket_thinker:OnDestroy()
    if not IsServer() then return end
	UTIL_Remove( self:GetParent() )
end

--------------------------------------------------------------------------------
-- Modifier Effects
function dark_willow_bramble_maze_lua_thicket_thinker:DeclareFunctions()
end

--------------------------------------------------------------------------------
-- Interval Effects
function dark_willow_bramble_maze_lua_thicket_thinker:OnIntervalThink()
	Msg("Bramble checking for enemies in radius\n")

    local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.check_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

    local current_chance = 0.0

    for _,enemy in pairs(enemies) do
        current_chance = math.random()
        Msg("Bramble rolled " .. current_chance .. " out of " .. self.root_chance .. " on enemy " .. enemy:GetName() .. "\n")
        if current_chance > self.root_chance then
            self:GetCaster():FindAbilityByName("dark_willow_bramble_maze_lua"):PlaceSingleBramble(enemy:GetOrigin())
        end
    end

    self.current_checks = self.current_checks + 1
    Msg("Bramble at " .. self.current_checks .. " out of " .. self.max_checks .. "\n")
    if self.current_checks >= self.max_checks then
        Msg("Bramble done thinking, " .. self.current_checks .. " is greater than/equal to " .. self.max_checks .. "\n")
        self:Destroy()
        return nil
    end
end

--------------------------------------------------------------------------------
-- Graphics & Animations

function dark_willow_bramble_maze_lua_thicket_thinker:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_dark_willow/dark_willow_bramble_ground_cracks.vpcf"
	local location = self:GetParent():GetOrigin()
	
	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, location )
	ParticleManager:SetParticleControl( effect_cast, 3, location )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( self.radius, self.radius, 5 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

