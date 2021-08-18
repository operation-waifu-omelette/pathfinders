phantom_assassin_stifling_dagger_lua = class({})
LinkLuaModifier( "modifier_phantom_assassin_stifling_dagger_lua", "pathfinder/phantom_assassin_stifling_dagger_lua/modifier_phantom_assassin_stifling_dagger_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_phantom_assassin_stifling_dagger_lua_attack", "pathfinder/phantom_assassin_stifling_dagger_lua/modifier_phantom_assassin_stifling_dagger_lua_attack", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hexed", "pathfinder/modifier_hexed", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function phantom_assassin_stifling_dagger_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()	

	-- get projectile_data
	local projectile_name = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf"
	local projectile_speed = self:GetSpecialValueFor("dagger_speed")
	local projectile_vision = 450

	-- Create Projectile
	local info = {
		Target = target,
		Source = caster,
		Ability = self,	
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bReplaceExisting = false,                         -- Optional
		bProvidesVision = true,                           -- Optional
		iVisionRadius = projectile_vision,				-- Optional
		iVisionTeamNumber = caster:GetTeamNumber()  ,      -- Optional
		ExtraData = {bounce = 0,},
	}
	ProjectileManager:CreateTrackingProjectile(info)

	self:PlayEffects1()
end

function phantom_assassin_stifling_dagger_lua:OnProjectileHit_ExtraData(hTarget, vLocation, table)
	local target = hTarget
	if target==nil then return end
	if target:IsInvulnerable() or target:IsMagicImmune() then return end
	if target:TriggerSpellAbsorb( self ) then return end
	
	local modifier = self:GetCaster():AddNewModifier(
		self:GetCaster(),
		self,
		"modifier_phantom_assassin_stifling_dagger_lua_attack",
		{}
	)
	self:GetCaster():PerformAttack (
		hTarget,
		true,
		true,
		true,
		false,
		false,
		false,
		true
	)
	if IsServer() and self:GetCaster():HasAbility("phantom_assassin_dagger_global") then
		self:GetCaster():Heal(self:GetCaster():GetAverageTrueAttackDamage(nil ), self:GetCaster())		
	end
	modifier:Destroy()

	hTarget:AddNewModifier(
			self:GetCaster(),
			self,
			"modifier_phantom_assassin_stifling_dagger_lua",
			{duration = self:GetDuration()}
		)
	self:PlayEffects2( hTarget )
	

	--------------------------------------------------------
	if IsServer() and self:GetCaster():HasAbility("pathfinder_special_pa_dagger_bouncing") then	
		local special = self:GetCaster():FindAbilityByName("pathfinder_special_pa_dagger_bouncing")
		local bounces = special:GetLevelSpecialValueFor("bounces",1)	
			
		if table.bounce < bounces then			
			local range = special:GetLevelSpecialValueFor("range",1)
			local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), target:GetAbsOrigin(), nil, range, 
				DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
				DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )

			if #enemies > 1 then
				local bounce_target = enemies[1]
				if bounce_target == hTarget then
					bounce_target = enemies[2]
				end				
				local caster = self:GetCaster()
				local target = bounce_target

				-- get projectile_data
				local projectile_name = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf"
				local projectile_speed = self:GetSpecialValueFor("dagger_speed")
				local projectile_vision = 450

				-- Create Projectile
				local info = {
					Target = target,
					Source = hTarget,
					Ability = self,	
					EffectName = projectile_name,
					iMoveSpeed = projectile_speed,
					bReplaceExisting = false,                         -- Optional
					bProvidesVision = true,                           -- Optional
					iVisionRadius = projectile_vision,				-- Optional
					iVisionTeamNumber = caster:GetTeamNumber() ,       -- Optional
					ExtraData = {bounce = table.bounce + 1}
				}
				ProjectileManager:CreateTrackingProjectile(info)								
				self:PlayEffects1()
				self:PlayEffects2( target )
				--table.bounce = table.bounce + 1
			end			
		end
	end

	if IsServer() and self:GetCaster():HasAbility("pathfinder_special_pa_dagger_freeze") then
		hTarget:AddNewModifier( nil, nil, "modifier_hexed", { duration = self:GetCaster():FindAbilityByName("pathfinder_special_pa_dagger_freeze"):GetLevelSpecialValueFor("duration", 1) } )		
	end

	
end

--------------------------------------------------------------------------------
function phantom_assassin_stifling_dagger_lua:PlayEffects1()
	-- Get Resources
	local sound_cast = "Hero_PhantomAssassin.Dagger.Cast"

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
end

function phantom_assassin_stifling_dagger_lua:PlayEffects2( target )
	-- Get Resources
	local sound_target = "Hero_PhantomAssassin.Dagger.Target"

	-- Create Sound
	EmitSoundOn( sound_target, target )
end