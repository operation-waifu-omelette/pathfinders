pathfinder_fire_breath = class({})

function pathfinder_fire_breath:Precache( context )
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_dragon_knight.vsndevts", context)	
end

--------------------------------------------------------------------------------
function pathfinder_fire_breath:OnCreated()
	if IsServer() then
		self:GetCaster():PrecacheScriptSound("sounds/weapons/hero/dragon_knight/dragonknight_fire.vsnd")
	end	
end
-- Ability Start
function pathfinder_fire_breath:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local point = self:GetCursorPosition()

	-- unit target just indicates point
	if target then point = target:GetOrigin() end
	
	-- load projectile
	local projectile_name = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf"
	local projectile_distance = self:GetSpecialValueFor( "range" )
	local projectile_start_radius = self:GetSpecialValueFor( "start_radius" )
	local projectile_end_radius = self:GetSpecialValueFor( "end_radius" )
	local projectile_speed = self:GetSpecialValueFor( "speed" )
	local projectile_direction = point - caster:GetOrigin()
	projectile_direction.z = 0
	projectile_direction = projectile_direction:Normalized()

	local loc = caster:GetAbsOrigin()
	loc.z = loc.z + 190

	-- create projectile
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = loc,
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = projectile_start_radius,
	    fEndRadius =projectile_end_radius,
		vVelocity = projectile_direction * projectile_speed,
		}
	ProjectileManager:CreateLinearProjectile(info)
	
	EmitSoundOn( "Conquest.FireTrap.Generic", self:GetCaster() )
end
--------------------------------------------------------------------------------
-- Projectile
function pathfinder_fire_breath:OnProjectileHit( target, location )
	if not target then return end

	-- load data
	local damage = self:GetCaster():GetOwner():GetAverageTrueAttackDamage(nil) * self:GetCaster():GetOwner():FindAbilityByName("pathfinder_venomancer_bigass_ward"):GetSpecialValueFor("damage_multiplier")
	--local duration = self:GetSpecialValueFor( "duration" )

	-- damage
	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)
end

