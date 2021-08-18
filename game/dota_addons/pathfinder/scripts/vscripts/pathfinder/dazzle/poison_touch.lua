pf_poison_touch = class({})
-- Creator: https://github.com/Elfansoer/dota-2-lua-abilities/tree/master/scripts/vscripts/lua_abilities/dazzle_poison_touch_lua

LinkLuaModifier( "modifier_pf_poison_touch", "pathfinder/dazzle/poison_touch", LUA_MODIFIER_MOTION_NONE )
require("libraries.timers")
--------------------------------------------------------------------------------
function pf_poison_touch:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor( "end_distance" )
end

-- Ability Start
function pf_poison_touch:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local origin = caster:GetOrigin()

	-- cancel if linken
	if target:TriggerSpellAbsorb( self ) then return end

	-- load data
	local max_targets = self:GetSpecialValueFor( "targets" )
	local distance = self:GetSpecialValueFor( "end_distance" )
	local start_radius = self:GetSpecialValueFor( "start_radius" )
	local end_radius = self:GetSpecialValueFor( "end_radius" )
	self.max_stack = self:GetSpecialValueFor( "max_stack" )

	-- get direction
	local direction = target:GetOrigin()-origin
	direction.z = 0
	direction = direction:Normalized()

	local enemies = self:FindUnitsInCone(
		caster:GetTeamNumber(),	-- nTeamNumber
		target:GetOrigin(),	-- vCenterPos
		caster:GetOrigin(),	-- vStartPos
		caster:GetOrigin() + direction*distance,	-- vEndPos
		start_radius,	-- fStartRadius
		end_radius,	-- fEndRadius
		nil,	-- hCacheUnit
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- nTeamFilter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- nTypeFilter
		0,	-- nFlagFilter
		FIND_CLOSEST,	-- nOrderFilter
		false	-- bCanGrowCache
	)

	-- projectile data
	local projectile_name = "particles/units/heroes/hero_dazzle/dazzle_poison_touch.vpcf"
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )

	-- precache projectile
	local info = {
		-- Target = target,
		Source = caster,
		Ability = self,	
		
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = true,                           -- Optional
	
		bVisibleToEnemies = true,                         -- Optional
		bProvidesVision = false,                           -- Optional

		ExtraData = nil
	}

	if self:GetCaster():FindAbilityByName("pf_poison_touch_chain") then
		info.EffectName = "particles/dazzle_poison_projectile.vpcf"
		info.ExtraData = { bounce = max_targets }
		info.Target = target
		info.iMoveSpeed = info.iMoveSpeed * 0.75
		info.bDodgeable = false
		ProjectileManager:CreateTrackingProjectile(info)
	else
		-- create projectile
		local counter = 0
		for _,enemy in pairs(enemies) do
			info.Target = enemy
			ProjectileManager:CreateTrackingProjectile(info)

			counter = counter+1
			if counter>=max_targets then break end
		end
	end

	-- Play effects
	local sound_cast = "Hero_Dazzle.Poison_Cast"
	EmitSoundOn( sound_cast, caster )
end

--------------------------------------------------------------------------------
function pf_poison_touch:OnProjectileHit_ExtraData(hTarget, vLocation, data)

	if data == nil or hTarget == nil or not self:GetCaster():FindAbilityByName("pf_poison_touch_chain") then
		return true
	end	

	local int_dmg = self:GetCaster():FindAbilityByName("pf_poison_touch_chain"):GetLevelSpecialValueFor("int_dmg",1)
	local splash_pct = self:GetCaster():FindAbilityByName("pf_poison_touch_chain"):GetLevelSpecialValueFor("splash_percent",1)
	local splash_radius = self:GetCaster():FindAbilityByName("pf_poison_touch_chain"):GetLevelSpecialValueFor("splash_radius",1)

	local damage = self:GetCaster():GetIntellect() / 100 * int_dmg
	local splash = damage / 100 * splash_pct

	local damageTable = {
		victim = hTarget,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		ability = self, --Optional.
	}
	ApplyDamage( damageTable )
	EmitSoundOn("Hero_Venomancer.VenomousGaleImpact", hTarget)

	local splash_targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
				hTarget:GetAbsOrigin(),
				nil,
				splash_radius,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
				FIND_ANY_ORDER,
				false)
	for _,splashed in pairs(splash_targets) do
		if splashed ~= hTarget then
			damageTable.damage = splash
			damageTable.victim = splashed
			ApplyDamage( damageTable )

			splashed:AddNewModifier(
				self:GetCaster(), -- player source
				self, -- ability source
				"modifier_pf_poison_touch", -- modifier name
				{ duration = self:GetSpecialValueFor( "duration" ) } -- kv
			)
		end
	end
	
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
				hTarget:GetAbsOrigin(),
				nil,
				self:GetSpecialValueFor( "end_distance" ) * 0.75,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
				FIND_ANY_ORDER,
				false)

	if #enemies > 1 and data.bounce > 0 then
		local i = 1		
		while enemies[i] == hTarget do
			i = i + 1			
		end
		local dest = enemies[i]

		print(data.bounce)
	
		local info = {
			Target = dest,
			Source = hTarget,
			Ability = self,	
			
			EffectName = "particles/dazzle_poison_projectile.vpcf",
			iMoveSpeed = self:GetSpecialValueFor( "projectile_speed" ) * 0.75,
			bDodgeable = false,                           -- Optional
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
			bVisibleToEnemies = true,                         -- Optional
			bProvidesVision = false,                           -- Optional DOTA_PROJECTILE_ATTACHMENT_HITLOCATION

			ExtraData = { bounce = data.bounce - 1}
		}
		ProjectileManager:CreateTrackingProjectile(info)
	end
	return true
end


-- Projectile
function pf_poison_touch:OnProjectileHit( target, location )
	if not target then return end

	-- get data
	local duration = self:GetSpecialValueFor( "duration" )

	-- add debuff
	if target:HasModifier("modifier_pf_poison_touch") then
		if target:FindModifierByName("modifier_pf_poison_touch"):GetStackCount() < self.max_stack then
			target:FindModifierByName("modifier_pf_poison_touch"):IncrementStackCount()
		end
	end

	target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_pf_poison_touch", -- modifier name
		{ duration = duration } -- kv
	)

	if self:GetCaster():FindAbilityByName("pf_poison_touch_chain") then
		if target:FindModifierByName("modifier_pf_poison_touch"):GetStackCount() < self.max_stack then
			target:FindModifierByName("modifier_pf_poison_touch"):IncrementStackCount()
		end
	end

	-- Play effects
	local sound_target = "Hero_Dazzle.Poison_Touch"
	EmitSoundOn( sound_target, target )

	if self:GetCaster():FindAbilityByName("pf_poison_touch_spread") then
		stun_duration = self:GetCaster():FindAbilityByName("pf_poison_touch_spread"):GetLevelSpecialValueFor("stun",1)
		target:AddNewModifier(
			self:GetCaster(), -- player source
			self, -- ability source
			"modifier_stunned", -- modifier name
			{ duration = stun_duration } -- kv
		)
	end	
end

--------------------------------------------------------------------------------
-- Helper
function pf_poison_touch:FindUnitsInCone( nTeamNumber, vCenterPos, vStartPos, vEndPos, fStartRadius, fEndRadius, hCacheUnit, nTeamFilter, nTypeFilter, nFlagFilter, nOrderFilter, bCanGrowCache )
	-- vCenterPos is used to determine searching center (FIND_CLOSEST will refer to units closest to vCenterPos)

	-- get cast direction and length distance
	local direction = vEndPos-vStartPos
	direction.z = 0

	local distance = direction:Length2D()
	direction = direction:Normalized()

	-- get max radius circle search
	local big_radius = distance + math.max(fStartRadius, fEndRadius)

	-- find enemies closest to primary target within max radius
	local units = FindUnitsInRadius(
		nTeamNumber,	-- int, your team number
		vCenterPos,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		big_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		nTeamFilter,	-- int, team filter
		nTypeFilter,	-- int, type filter
		nFlagFilter,	-- int, flag filter
		nOrderFilter,	-- int, order filter
		bCanGrowCache	-- bool, can grow cache
	)

	-- Filter within cone
	local targets = {}
	for _,unit in pairs(units) do

		-- get unit vector relative to vStartPos
		local vUnitPos = unit:GetOrigin()-vStartPos

		-- get projection scalar of vUnitPos onto direction using dot-product
		local fProjection = vUnitPos.x*direction.x + vUnitPos.y*direction.y + vUnitPos.z*direction.z

		-- clamp projected scalar to [0,distance]
		fProjection = math.max(math.min(fProjection,distance),0)
		
		-- get projected vector of vUnitPos onto direction
		local vProjection = direction*fProjection

		-- calculate distance between vUnitPos and the projected vector
		local fUnitRadius = (vUnitPos - vProjection):Length2D()

		-- calculate interpolated search radius at projected vector
		local fInterpRadius = (fProjection/distance)*(fEndRadius-fStartRadius) + fStartRadius

		-- if unit is within distance, add them
		if fUnitRadius<=fInterpRadius then
			table.insert( targets, unit )
		end
	end

	return targets
end

modifier_pf_poison_touch = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_pf_poison_touch:IsHidden()
	return false
end

function modifier_pf_poison_touch:IsDebuff()
	return true
end

function modifier_pf_poison_touch:IsStunDebuff()
	return false
end

function modifier_pf_poison_touch:IsPurgable()
	return true
end

-- function modifier_pf_poison_touch:GetAttributes()
-- 	return MODIFIER_ATTRIBUTE_MULTIPLE
-- end

--------------------------------------------------------------------------------
-- Initializations
function modifier_pf_poison_touch:OnCreated( kv )
	-- references
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.slow = self:GetAbility():GetSpecialValueFor( "slow" )	
	self.duration = kv.duration

	if not IsServer() then return end
	-- precache damage
	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self, --Optional.
	}
	-- ApplyDamage(damageTable)

	-- Start interval
	self:StartIntervalThink( 1 )
	self:OnIntervalThink()
	self:SetStackCount(1)
end

function modifier_pf_poison_touch:OnRefresh( kv )		
end

function modifier_pf_poison_touch:OnRemoved()
end

function modifier_pf_poison_touch:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_pf_poison_touch:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_pf_poison_touch:OnAttackLanded( params )
	if not IsServer() then return end
	if params.target~=self:GetParent() or params.attacker ~= self:GetCaster() or params.attacker:GetUnitName() ~= self:GetCaster():GetUnitName() then return end

	-- refresh duration
	self:SetDuration( self.duration, true )	

	if self:GetCaster():FindAbilityByName("pf_poison_touch_spread") then
		count = self:GetCaster():FindAbilityByName("pf_poison_touch_spread"):GetLevelSpecialValueFor("targets",1)
		self:Spread(self:GetParent(), 500, count)
	end
end

function modifier_pf_poison_touch:OnDeath( params )
	if not IsServer() then return end
	if params.unit~=self:GetParent() then return end

	if self:GetCaster():FindAbilityByName("pf_poison_touch_ward") and self:GetCaster():FindAbilityByName("pf_shadow_wave"):IsTrained() then
		local chance = self:GetCaster():FindAbilityByName("pf_poison_touch_ward"):GetLevelSpecialValueFor("chance",1)
		local pulse = self:GetCaster():FindAbilityByName("pf_poison_touch_ward"):GetLevelSpecialValueFor("pulse",1)		

		if RollPseudoRandomPercentage( chance, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, self:GetCaster() ) == true then
			local ward = CreateUnitByName("pathfinder_dazzle_ward", self:GetParent():GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)

			ward:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kill", {duration = 3.5})
			ward:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_phased", {})
			ward:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_invulnerable", {})

			local caster = self:GetCaster()
			
			for i=1,pulse do
				Timers(1.5 * i, function()
					caster:FindAbilityByName("pf_shadow_wave"):CastFromUnit(ward)
				end)
			end
		end
	end
end

function modifier_pf_poison_touch:Spread( source, radius, count )
	if not source then return end

	local enemies = FindUnitsInRadius(
            source:GetTeamNumber(),	-- int, your team number
            source:GetOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES,	-- int, flag filter
            FIND_ANY_ORDER,	-- int, order filter
            false	-- bool, can grow cache
        )
	
	local projectile_name = "particles/units/heroes/hero_dazzle/dazzle_poison_touch.vpcf"
	local projectile_speed = self:GetAbility():GetSpecialValueFor( "projectile_speed" )

	-- precache projectile
	local info = {
		-- Target = target,
		Source = source,
		Ability = self:GetAbility(),	
		
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = true,                           -- Optional

		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
	
		bVisibleToEnemies = true,                         -- Optional
		bProvidesVision = false,                           -- Optional
	}

	local counter = 0
	for _,enemy in pairs(enemies) do
		if enemy ~= source then
			info.Target = enemy
			ProjectileManager:CreateTrackingProjectile(info)
			counter = counter+1
		end
		if counter>=count then break end
	end
	
end

function modifier_pf_poison_touch:GetModifierMoveSpeedBonus_Percentage()
	return self.slow * -1
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_pf_poison_touch:OnIntervalThink()
	-- apply damage
	self.damageTable.damage = self:GetAbility():GetSpecialValueFor( "damage" ) * self:GetStackCount()
	ApplyDamage( self.damageTable )

	-- Play effects
	local sound_cast = "Hero_Dazzle.Poison_Tick"
	EmitSoundOn( sound_cast, self:GetParent() )
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_pf_poison_touch:GetEffectName()
	return "particles/units/heroes/hero_dazzle/dazzle_poison_debuff.vpcf"
end

function modifier_pf_poison_touch:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_pf_poison_touch:GetStatusEffectName()
	return "particles/status_fx/status_effect_poison_dazzle_copy.vpcf"
end