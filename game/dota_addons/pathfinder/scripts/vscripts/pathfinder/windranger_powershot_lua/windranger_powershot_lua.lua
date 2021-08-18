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
windranger_powershot_lua = class({})

--------------------------------------------------------------------------------
require("libraries.timers")

function windranger_powershot_lua:Spawn()
	if not IsServer() then return end
	local caster = self:GetCaster()
	Timers(2, function()
		if IsValidEntity(caster) and caster:HasAbility("pathfinder_special_windranger_powershot_repeating") and self:IsTrained() then
			if not caster:FindAbilityByName("windranger_powershot_lua"):GetAutoCastState() then
				caster:FindAbilityByName("windranger_powershot_lua"):ToggleAutoCast()
			end
			return nil
		else
			return 2
		end
	end)
end

function windranger_powershot_lua:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("arrow_range")
end

function windranger_powershot_lua:GetBehavior()
	if self:GetCaster():FindAbilityByName("pathfinder_special_windranger_powershot_repeating") then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_AUTOCAST
	else
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_CHANNELLED
	end
end

-- Ability Start
function windranger_powershot_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	self.bounceCount = 0	

	-- Play effects
	local sound_cast = "Ability.PowershotPull"
	EmitSoundOnLocationForAllies( caster:GetOrigin(), sound_cast, caster )
	
	self.is_first_shot = true
	self.doesNotPierce = false
	-- load data
	self.damage = self:GetSpecialValueFor( "powershot_damage" )

	if caster:HasAbility("pathfinder_special_windranger_powershot_repeating")  and self:GetAutoCastState() then
		self.damage = self:GetSpecialValueFor( "powershot_damage" ) / 100 * caster:FindAbilityByName("pathfinder_special_windranger_powershot_repeating"):GetSpecialValueFor("damage_percent")		
	end

end

--------------------------------------------------------------------------------
-- Ability Channeling
function windranger_powershot_lua:OnChannelFinish( bInterrupted )
	if bInterrupted == true then				
		if self:GetCaster():HasAbility("pathfinder_special_windranger_powershot_repeating")  and self:GetAutoCastState()  then
			self.damage = self:GetSpecialValueFor( "powershot_damage" ) / 100 * self:GetCaster():FindAbilityByName("pathfinder_special_windranger_powershot_repeating"):GetSpecialValueFor("damage_percent")	* 0.4
		else
			self.damage = self:GetSpecialValueFor( "powershot_damage" ) * 0.4
		end
	else
		self.damage = self:GetSpecialValueFor( "powershot_damage" )

		if self:GetCaster():HasAbility("pathfinder_special_windranger_powershot_repeating")  and self:GetAutoCastState()  then
			self.damage = self:GetSpecialValueFor( "powershot_damage" ) / 100 * self:GetCaster():FindAbilityByName("pathfinder_special_windranger_powershot_repeating"):GetSpecialValueFor("damage_percent")		
		end
	end
	self.hitlist = {}
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	--local channel_pct = (GameRules:GetGameTime() - self:GetChannelStartTime())/self:GetChannelTime()

	

	local vision_radius = self:GetSpecialValueFor( "vision_radius" )
	
	local projectile_name = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf"
	local projectile_speed = self:GetSpecialValueFor( "arrow_speed" )
	local projectile_distance = self:GetSpecialValueFor( "arrow_range" )
	local projectile_radius = self:GetSpecialValueFor( "arrow_width" )
	local projectile_direction = point-caster:GetOrigin()
	projectile_direction.z = 0
	projectile_direction = projectile_direction:Normalized()

	-- create projectile
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = projectile_radius,
	    fEndRadius = projectile_radius,
		vVelocity = projectile_direction * projectile_speed,
	
		bProvidesVision = true,
		iVisionRadius = vision_radius,
		iVisionTeamNumber = caster:GetTeamNumber(),
		ExtraData = {					
				},
	}
	local projectile = ProjectileManager:CreateLinearProjectile(info)

	require("libraries.timers")

	-- register projectile data
	self.projectiles[projectile] = {}
	self.projectiles[projectile].damage = self.damage--*channel_pct

	if IsServer() and caster:HasAbility("pathfinder_special_windranger_powershot_multishot") then
		local angle = 35
		local extra_shots = 1

		for i = 1, extra_shots do			
			local new_point = RotatePosition(caster:GetAbsOrigin(),QAngle(0,i * angle,0),point)		
			local dir = (new_point - caster:GetAbsOrigin())
			dir.z = 0
			dir = dir:Normalized()

			-- create projectile
			local info = {
				Source = caster,
				Ability = self,
				vSpawnOrigin = caster:GetAbsOrigin(),
				
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				
				EffectName = projectile_name,
				fDistance = projectile_distance,
				fStartRadius = projectile_radius,
				fEndRadius = projectile_radius,
				vVelocity = dir * projectile_speed,
			
				bProvidesVision = true,
				iVisionRadius = vision_radius,
				iVisionTeamNumber = caster:GetTeamNumber(),
				ExtraData = {					
				},
			}
			projectile = ProjectileManager:CreateLinearProjectile(info)
			-- register projectile data
			self.projectiles[projectile] = {}
			self.projectiles[projectile].damage = self.damage

			
			local new_point = RotatePosition(caster:GetAbsOrigin(),QAngle(0,-1 * i * angle,0),point)
			local dir = (new_point - caster:GetAbsOrigin())
			dir.z = 0
			dir = dir:Normalized()

			-- create projectile
			local info = {
				Source = caster,
				Ability = self,
				vSpawnOrigin = caster:GetAbsOrigin(),
				
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				
				EffectName = projectile_name,
				fDistance = projectile_distance,
				fStartRadius = projectile_radius,
				fEndRadius = projectile_radius,
				vVelocity = dir* projectile_speed,				
			
				bProvidesVision = true,
				iVisionRadius = vision_radius,
				iVisionTeamNumber = caster:GetTeamNumber(),
				ExtraData = {					
				},
			}
			projectile = ProjectileManager:CreateLinearProjectile(info)
			-- register projectile data
			self.projectiles[projectile] = {}
			self.projectiles[projectile].damage = self.damage

		end				
	end

	if IsServer() and self:GetCaster():FindAbilityByName("pathfinder_special_windranger_powershot_attacks") then		
		local radius = self:GetCaster():FindAbilityByName("pathfinder_special_windranger_powershot_attacks"):GetLevelSpecialValueFor("radius", 1)
		-- find nearby enemies
		local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			self:GetCaster():GetAbsOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			FIND_ANY_ORDER,	-- int, order filter
			false	-- bool, can grow cache
		)	
		
		for _,enemy in pairs(enemies) do			
			if self.hitlist[enemy] == nil then
				self:GetCaster():PerformAttack(enemy, false, true, true, true, true, true, false)
				self.hitlist[enemy] = true				
			end
		end		
	end


	-- Play effects
	local sound_cast = "Ability.Powershot"
	EmitSoundOn( sound_cast, caster )

	if caster:HasAbility("pathfinder_special_windranger_powershot_repeating") and self.is_first_shot == true and self:GetAutoCastState() then
		self.doesNotPierce = true
		self.is_first_shot = false
		local num = caster:FindAbilityByName("pathfinder_special_windranger_powershot_repeating"):GetSpecialValueFor("additional_shots")
		local interval = caster:FindAbilityByName("pathfinder_special_windranger_powershot_repeating"):GetSpecialValueFor("interval")
		for i=1,num do
			Timers:CreateTimer( i * interval, function()
				caster:SetCursorPosition(point)									
				self:OnChannelFinish(bInterrupted)
				return nil
    		end
			)			
		end
	end
end

--------------------------------------------------------------------------------
-- Projectile
-- projectile data table
windranger_powershot_lua.projectiles = {}

function windranger_powershot_lua:OnProjectileHitHandle( target, location, handle )
	if not target then
		-- unregister projectile
		self.projectiles[handle] = nil

		-- create Vision
		local vision_radius = self:GetSpecialValueFor( "vision_radius" )
		local vision_duration = self:GetSpecialValueFor( "vision_duration" )
		AddFOWViewer( self:GetCaster():GetTeamNumber(), location, vision_radius, vision_duration, false )

		return
	end	


	-- get data
	local data = self.projectiles[handle]
	local damage = data.damage

	-- damage
	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = self.damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)

	data.damage = self.damage

	-- Play effects
	local sound_cast = "Hero_Windrunner.PowershotDamage"
	EmitSoundOn( sound_cast, target )

	return self.doesNotPierce
end

function windranger_powershot_lua:OnProjectileThink_ExtraData( location, data )
	-- destroy trees
	local tree_width = self:GetSpecialValueFor( "tree_width" )
	GridNav:DestroyTreesAroundPoint(location, tree_width, false)	

	if IsServer() and self:GetCaster():FindAbilityByName("pathfinder_special_windranger_powershot_attacks") then		
		local radius = self:GetCaster():FindAbilityByName("pathfinder_special_windranger_powershot_attacks"):GetLevelSpecialValueFor("radius", 1)
		-- find nearby enemies
		local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			location,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			FIND_ANY_ORDER,	-- int, order filter
			false	-- bool, can grow cache
		)	
		
		for _,enemy in pairs(enemies) do			
			if self.hitlist[enemy] == nil then
				self:GetCaster():PerformAttack(enemy, false, true, true, true, true, true, false)
				self.hitlist[enemy] = true				
			end
		end		
	end
end