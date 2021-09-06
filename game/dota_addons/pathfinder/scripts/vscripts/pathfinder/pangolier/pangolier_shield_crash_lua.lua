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
pangolier_shield_crash_lua = class({})
LinkLuaModifier( "modifier_pangolier_shield_crash_lua", "pathfinder/pangolier/modifier_pangolier_shield_crash_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_arc_lua", "pathfinder/generic/modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )
--LinkLuaModifier( "modifier_pangolier_shield_crash_model", "pathfinder/pangolier/modifier_pangolier_shield_crash_lua", LUA_MODIFIER_MOTION_BOTH )
-- --------------------------------------------------------------------------------
-- -- Custom KV
-- function pangolier_shield_crash_lua:GetCooldown( level )
-- 	if self:GetCaster():HasAbility("special_bonus_shield_crash_in_ball") and self:GetCaster():HasModifier("modifier_pangolier_gyroshell") then
-- 		return self:GetCaster():GetAbility("special_bonus_shield_crash_in_ball"):GetSpecialValueFor("cooldown")
-- 	end

-- 	return self.BaseClass.GetCooldown( self, level )
-- end

--------------------------------------------------------------------------------
-- Ability Start

function pangolier_shield_crash_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local damage = self:GetSpecialValueFor( "damage" )
	local radius = self:GetSpecialValueFor( "radius" )
	local distance = self:GetSpecialValueFor( "jump_horizontal_distance" )
	local duration = self:GetSpecialValueFor( "jump_duration" )
	local height = self:GetSpecialValueFor( "jump_height" )
	local buff_duration = self:GetSpecialValueFor( "duration" )
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_2)
	if self:GetCaster():HasAbility("pangolier_shield_crash_ball") and self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):IsTrained() then
		new_roller = CreateUnitByName("npc_dota_creature_pangolier_rolling_summon", self:GetCaster():GetOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)
		new_roller:AddNewModifier(
			self:GetCaster(), -- player source
			self, -- ability source
			"modifier_pangolier_npc_gyroshell_lua", -- modifier name
			{ duration = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("duration") } -- kv
		)
	end

	if self:GetCaster():HasAbility("pangolier_shield_crash_swashbuckle") and self:GetCaster():FindAbilityByName("pangolier_swashbuckle_lua"):IsTrained() then
		print("swashbukle!")
		local direction = self:GetCaster():GetForwardVector()
		print(direction.x,direction.y)
		self:GetCaster():AddNewModifier(
		self:GetCaster(), 
		self,
		"modifier_pangolier_swashbuckle_lua", -- modifier name
		{
			dir_x = direction.x,
			dir_y = direction.y,
			duration = 3, -- max duration
		}) -- kv		
	end
	-- caster:AddNewModifier(
	-- 	caster, -- player source
	-- 	self, -- ability source
	-- 	"modifier_pangolier_shield_crash_model", -- modifier name
	-- 	{
	-- 		duration = 4,
	-- 	} -- kv
	-- )
	-- arc
	local arc = caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_generic_arc_lua", -- modifier name
		{
			distance = distance,
			duration = duration,
			height = height,
			fix_duration = false,
			isForward = true,
			isStun = true,
			activity = ACT_DOTA_FLAIL,
		} -- kv
	)
	arc:SetEndCallback(function()
		-- find enemies
		local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(),	-- int, your team number
			caster:GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)
		-- precache damage
		local damageTable = {
			-- victim = target,
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self, --Optional.
		}

		--caster:RemoveModifierByName("modifier_pangolier_shield_crash_model")

	

		local stack = 0
		for _,enemy in pairs(enemies) do
			-- damage
			damageTable.victim = enemy
			ApplyDamage(damageTable)
			if self:GetCaster():FindAbilityByName("pangolier_shield_crash_stuns") then

				enemy:AddNewModifier(caster, self, "modifier_stunned", {duration = self:GetCaster():FindAbilityByName("pangolier_shield_crash_stuns"):GetLevelSpecialValueFor("stun_duration",1) * (1 - enemy:GetStatusResistance())})

				-- Knock the enemy into the air
				local knockback =
				{
					knockback_duration = 0.25 * (1 - enemy:GetStatusResistance()),
					duration = 0.25 * (1 - enemy:GetStatusResistance()),
					knockback_distance = 0,
					knockback_height = 150,
				}
				enemy:RemoveModifierByName("modifier_knockback")
				enemy:AddNewModifier(caster, self, "modifier_knockback", knockback)

				print("using stun")
			end	
			-- count stack
			
				stack = stack + 1

			-- play effects
			self:PlayEffects4( enemy )
		end

		-- add buff
		if stack>0 then
			caster:AddNewModifier(
				caster, -- player source
				self, -- ability source
				"modifier_pangolier_shield_crash_lua", -- modifier name
				{
					duration = buff_duration,
					stack = stack,
				} -- kv
			)
		end

		-- play effects
		self:PlayEffects2()
		if stack>0 then
			self:PlayEffects3()
		end
	end)

	-- play effects
	self:PlayEffects1( arc )
	
	local shield_crash = self:GetCaster():FindAbilityByName("pangolier_shield_crash_lua")
	if self:GetCaster():HasAbility("special_bonus_shield_crash_in_ball") and self:GetCaster():FindAbilityByName("special_bonus_shield_crash_in_ball"):IsTrained() and not shield_crash:IsCooldownReady() and self:GetCaster():HasModifier("modifier_pangolier_gyroshell") then
		shield_crash:EndCooldown()
		shield_crash:StartCooldown(2.5)
	end
end

function pangolier_shield_crash_lua:OnAbilityFullyCast()
	
end
--------------------------------------------------------------------------------
-- Graphics & Animations
function pangolier_shield_crash_lua:PlayEffects1( modifier )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_pangolier/pangolier_tailthump_cast.vpcf"
	local sound_cast = "Hero_Pangolier.TailThump.Cast"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )

	-- buff particle
	modifier:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
end

function pangolier_shield_crash_lua:PlayEffects2()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_pangolier/pangolier_tailthump.vpcf"
	local sound_cast = "Hero_Pangolier.TailThump"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
end

function pangolier_shield_crash_lua:PlayEffects3()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_pangolier/pangolier_tailthump_hero.vpcf"
	local sound_cast = "Hero_Pangolier.TailThump.Shield"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
end

function pangolier_shield_crash_lua:PlayEffects3()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_pangolier/pangolier_tailthump_hero.vpcf"
	local sound_cast = "Hero_Pangolier.TailThump.Shield"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
end

function pangolier_shield_crash_lua:PlayEffects4( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_pangolier/pangolier_tailthump_shield_impact.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end


-- modifier_pangolier_shield_crash_model = modifier_pangolier_shield_crash_model or class({})

-- function modifier_pangolier_shield_crash_model:IsHidden() return false end

-- function modifier_pangolier_shield_crash_model:DeclareFunctions()
-- 	local declfuncs = {MODIFIER_PROPERTY_MODEL_CHANGE}
-- 	return declfuncs
-- end 

-- function modifier_pangolier_shield_crash_model:GetModifierModelChange()
-- 	return "models/heroes/pangolier/pangolier_gyroshell2.vmdl"
-- end