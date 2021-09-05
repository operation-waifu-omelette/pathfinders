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
modifier_pangolier_swashbuckle_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_pangolier_swashbuckle_lua:IsHidden()
	return true
end

function modifier_pangolier_swashbuckle_lua:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_pangolier_swashbuckle_lua:OnCreated( kv )
	-- references
	local ability = self:GetCaster():FindAbilityByName("pangolier_swashbuckle_lua")
	self.range = ability:GetSpecialValueFor( "range" )
	if self:GetCaster():FindAbilityByName("special_bonus_pathfinder_pangolier_swashbuckle_lua+range"):IsTrained() then
		self.range = self.range + self:GetCaster():FindAbilityByName("special_bonus_pathfinder_pangolier_swashbuckle_lua+range"):GetSpecialValueFor("range")
	end
	self.speed = ability:GetSpecialValueFor( "dash_speed" )
	self.radius = ability:GetSpecialValueFor( "start_radius" )

	self.interval = ability:GetSpecialValueFor( "attack_interval" )
	self.damage = ability:GetSpecialValueFor( "damage" )
	if self:GetCaster():FindAbilityByName("special_bonus_pathfinder_pangolier_swashbuckle_lua+damage"):IsTrained() then
		self.damage = self.damage + self:GetCaster():FindAbilityByName("special_bonus_pathfinder_pangolier_swashbuckle_lua+damage"):GetSpecialValueFor("damage")
	end
	self.strikes = ability:GetSpecialValueFor( "strikes" )

	if not IsServer() then return end
	-- get positions
	self.origin = self:GetParent():GetOrigin()
	self.direction = Vector( kv.dir_x, kv.dir_y, 0 )
	self.target = self.origin + self.direction*self.range

	-- set count
	self.count = 0

	-- Start interval
	self:StartIntervalThink( self.interval )
	self:OnIntervalThink()
end

function modifier_pangolier_swashbuckle_lua:OnRefresh( kv )
end

function modifier_pangolier_swashbuckle_lua:OnRemoved()
end

function modifier_pangolier_swashbuckle_lua:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_pangolier_swashbuckle_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE,
	}

	return funcs
end

function modifier_pangolier_swashbuckle_lua:GetModifierOverrideAttackDamage()

	if self:GetCaster():FindAbilityByName("pangolier_swashbuckle_uses_attack") then	
		return 
	else		
		return self.damage
		
	end
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_pangolier_swashbuckle_lua:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_pangolier_swashbuckle_lua:OnIntervalThink()


	-- find units in line
	local enemies = FindUnitsInLine(
		self:GetParent():GetTeamNumber(),	-- int, your team number
		self.origin,	-- point, center point
		targetf,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0	-- int, flag filter
	)

	for _,enemy in pairs(enemies) do
		-- Attack
		self:GetParent():PerformAttack( enemy, true, true, true, false, false, false, true )

		-- play sound
		local sound_target = "Hero_Pangolier.Swashbuckle.Damage"
		EmitSoundOn( sound_target, enemy )
	end

	if	self:GetParent():HasAbility("pangolier_swashbuckle_360") then
		local enemies2 = FindUnitsInLine(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self.origin,	-- point, center point
			targetr,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0	-- int, flag filter
		)
		for _,enemy in pairs(enemies2) do
			-- Attack
			self:GetParent():PerformAttack( enemy, true, true, true, false, false, false, true )

			-- play sound
			local sound_target = "Hero_Pangolier.Swashbuckle.Damage"
			EmitSoundOn( sound_target, enemy )
		end

		

		local enemies3 = FindUnitsInLine(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self.origin,	-- point, center point
			targetl,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0	-- int, flag filter
		)
		for _,enemy in pairs(enemies3) do
			-- Attack
			self:GetParent():PerformAttack( enemy, true, true, true, false, false, false, true )

			-- play sound
			local sound_target = "Hero_Pangolier.Swashbuckle.Damage"
			EmitSoundOn( sound_target, enemy )
		end
		local enemies4 = FindUnitsInLine(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self.origin,	-- point, center point
			targetb,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0	-- int, flag filter
		)
		for _,enemy in pairs(enemies4) do
			-- Attack
			self:GetParent():PerformAttack( enemy, true, true, true, false, false, false, true )

			-- play sound
			local sound_target = "Hero_Pangolier.Swashbuckle.Damage"
			EmitSoundOn( sound_target, enemy )
		end
	end

	-- Play effects
	self:PlayEffects()

	self.count = self.count+1
	if self.count>=self.strikes then
		self:Destroy()
	end
end

function modifier_pangolier_swashbuckle_lua:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_pangolier/pangolier_swashbuckler.vpcf"
	local sound_cast = "Hero_Pangolier.Swashbuckle.Attack"
	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 1, self.direction )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
	if	self:GetParent():HasAbility("pangolier_swashbuckle_360") then
		local effect_cast2 = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( effect_cast2, 1, self.direction * (-1) )

		-- buff particle
		self:AddParticle(
			effect_cast2,
			false, -- bDestroyImmediately
			false, -- bStatusEffect
			-1, -- iPriority
			false, -- bHeroEffect
			false -- bOverheadEffect
		)

		local effect_cast3 = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( effect_cast3, 1, self:GetParent():GetRightVector() )

		-- buff particle
		self:AddParticle(
			effect_cast3,
			false, -- bDestroyImmediately
			false, -- bStatusEffect
			-1, -- iPriority	
			false, -- bHeroEffect
			false -- bOverheadEffect
		)

		local effect_cast4 = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( effect_cast4, 1, self:GetParent():GetRightVector() * (-1) )

		-- buff particle
		self:AddParticle(
			effect_cast4,
			false, -- bDestroyImmediately
			false, -- bStatusEffect
			-1, -- iPriority
			false, -- bHeroEffect
			false -- bOverheadEffect
		)
	end

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetParent() )
end