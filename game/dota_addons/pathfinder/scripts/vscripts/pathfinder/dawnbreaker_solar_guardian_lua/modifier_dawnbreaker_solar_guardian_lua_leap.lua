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
modifier_dawnbreaker_solar_guardian_lua_leap = class({})
require("libraries.timers")

--------------------------------------------------------------------------------
-- Classifications
function modifier_dawnbreaker_solar_guardian_lua_leap:IsHidden()
	return true
end

function modifier_dawnbreaker_solar_guardian_lua_leap:IsDebuff()
	return false
end

function modifier_dawnbreaker_solar_guardian_lua_leap:IsPurgable()
	return false
end

function modifier_dawnbreaker_solar_guardian_lua_leap:CheckState()
	local state =
	{
		[MODIFIER_STATE_INVULNERABLE] = true,
	}
	return state
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_dawnbreaker_solar_guardian_lua_leap:OnCreated( kv )
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	-- references
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.damage = self:GetAbility():GetSpecialValueFor( "land_damage" )
	self.duration = self:GetAbility():GetSpecialValueFor( "land_stun_duration" )

	if not IsServer() then return end
	-- ability properties
	self.abilityDamageType = self:GetAbility():GetAbilityDamageType()

	-- get data
	local arc_height = 2500 * kv.duration
	self.point = Vector( kv.x, kv.y, 0 )
	self.interrupted = false

	-- add arc
	local arc = self.parent:AddNewModifier(
		self.parent, -- player source
		self:GetAbility(), -- ability source
		"modifier_generic_arc_lua", -- modifier name
		{
			duration = kv.duration,
			height = arc_height,
			isStun = false,
			isForward = true,
		} -- kv
	)
	arc:SetEndCallback(function( interrupted )
		if interrupted then
			self.interrupted = interrupted
			self:Destroy()
		end
	end)

	if self:GetParent():FindAbilityByName("dawnbreaker_solar_guardian_lua_capture") then
		self.captured_enemies = FindUnitsInRadius(
			self.parent:GetTeamNumber(),	-- int, your team number
			self:GetParent():GetAbsOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)
		self.captured_pos = {}		
		for _,enemy in pairs(self.captured_enemies) do			
			self.captured_pos[enemy] = RandomVector(RandomFloat(80,self.radius))
			arc = enemy:AddNewModifier(
				self.parent, -- player source
				self:GetAbility(), -- ability source
				"modifier_generic_arc_lua", -- modifier name
				{
					duration = kv.duration,
					height = arc_height,
					isStun = false,
					isForward = true,
				} -- kv
			)
			arc:SetEndCallback(function( interrupted )
				if interrupted then
					self.interrupted = interrupted
					self:Destroy()
				end
			end)			
		end
	end

	self:StartIntervalThink( kv.duration/2 )

	-- play effects
	self:PlayEffects1()
end

function modifier_dawnbreaker_solar_guardian_lua_leap:OnRefresh( kv )
end

function modifier_dawnbreaker_solar_guardian_lua_leap:OnRemoved()
end

function modifier_dawnbreaker_solar_guardian_lua_leap:OnDestroy()
	if not IsServer() then return end
	if self.interrupted then return end

	-- find enemies
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),	-- int, your team number
		self.point,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	-- precache damage
	local damageTable = {
		-- victim = target,
		attacker = self.parent,
		damage = self.damage,
		damage_type = self.abilityDamageType,
		ability = self.ability, --Optional.
	}
	-- ApplyDamage(damageTable)

	for _,enemy in pairs(enemies) do
		-- damage
		damageTable.victim = enemy
		ApplyDamage( damageTable )

		-- stun
		enemy:AddNewModifier(
			self.parent, -- player source
			self.ability, -- ability source
			"modifier_stunned", -- modifier name
			{ duration = self.duration * (1 - enemy:GetStatusResistance())} -- kv
		)
	end

	-- destroy trees
	GridNav:DestroyTreesAroundPoint( self.point, self.radius/2, false )

	-- play effects
	self:PlayEffects2( self.point, self.radius )

	if self:GetCaster():FindAbilityByName("dawnbreaker_solar_guardian_lua_charges") then
		self:GetCaster():FindAbilityByName("dawnbreaker_starbreaker_lua"):EndCooldown()
		self:GetCaster():FindAbilityByName("dawnbreaker_celestial_hammer_lua"):EndCooldown()
		self:GetCaster():FindAbilityByName("dawnbreaker_luminosity_lua"):EndCooldown()
	end

	if self:GetCaster():FindAbilityByName("dawnbreaker_solar_guardian_lua_capture") then
		local buff_duration = self:GetParent():FindAbilityByName("dawnbreaker_solar_guardian_lua_capture"):GetLevelSpecialValueFor("buff_duration",1)
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_omninight_guardian_angel", {duration = buff_duration})
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_minotaur_horn_immune", {duration = buff_duration})
	end
	
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_dawnbreaker_solar_guardian_lua_leap:OnIntervalThink()
	-- move position to target
	self.point.z = self.parent:GetOrigin().z
	self.parent:SetOrigin( self.point )	

	if self:GetParent():FindAbilityByName("dawnbreaker_solar_guardian_lua_capture") and self.captured_enemies then
		for _,enemy in pairs(self.captured_enemies) do			
			local new_point = self.point + self.captured_pos[enemy]
			enemy:SetOrigin(new_point)			
		end
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
-- function modifier_dawnbreaker_solar_guardian_lua_leap:GetEffectName()
-- 	return "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_airtime_buff.vpcf"
-- end

-- function modifier_dawnbreaker_solar_guardian_lua_leap:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end

function modifier_dawnbreaker_solar_guardian_lua_leap:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_airtime_buff.vpcf"
	local sound_cast = "Hero_Dawnbreaker.Solar_Guardian.BlastOff"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	EmitSoundOn( sound_cast, self.parent )
	self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_4_END)
end

function modifier_dawnbreaker_solar_guardian_lua_leap:PlayEffects2( point, radius )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_landing.vpcf"
	local sound_cast = "Hero_Dawnbreaker.Solar_Guardian.Impact"

	-- Get Data
	point = GetGroundPosition( point, self.parent )

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self.parent )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:SetParticleControl( effect_cast, 1, point )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOnLocationWithCaster( point, sound_cast, self.parent )
	self:GetParent():StartGestureFadeWithSequenceSettings(ACT_DOTA_OVERRIDE_ABILITY_4)

	local land_voiceline = {
		"dawnbreaker_valora_fury_01",
		"dawnbreaker_valora_fury_02",
		"dawnbreaker_valora_fury_03",
		"dawnbreaker_valora_fury_04",
		"dawnbreaker_valora_fury_05",
		"dawnbreaker_valora_fury_06",
		"dawnbreaker_valora_fury_07",
		"dawnbreaker_valora_fury_08",
		"dawnbreaker_valora_fury_09",
		"dawnbreaker_valora_fury_10",
		"dawnbreaker_valora_fury_11",
		"dawnbreaker_valora_fury_12",
		"dawnbreaker_valora_fury_13",
		"dawnbreaker_valora_fury_14",
		"dawnbreaker_valora_fury_15",
		"dawnbreaker_valora_fury_16",
		"dawnbreaker_valora_fury_17",
		"dawnbreaker_valora_fury_18",
		"dawnbreaker_valora_fury_19",
		"dawnbreaker_valora_fury_20",
		"dawnbreaker_valora_fury_21",
		"dawnbreaker_valora_fury_22",				
	}
	self:GetParent():EmitSound(land_voiceline[RandomInt(1, #land_voiceline)])
end