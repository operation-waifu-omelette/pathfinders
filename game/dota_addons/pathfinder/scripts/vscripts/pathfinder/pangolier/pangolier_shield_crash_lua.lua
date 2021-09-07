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


pangolier_shield_crash_lua = class({})

require("libraries.timers")
LinkLuaModifier( "modifier_generic_3_charges", "pathfinder/generic/modifier_generic_3_charges", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pangolier_shield_crash_lua", "pathfinder/pangolier/modifier_pangolier_shield_crash_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_arc_lua", "pathfinder/generic/modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )

--[[---------------------------------------------------------------------
	PANGOLIER SHIELD CRASH
]]------------------------------------------------------------------------
function pangolier_shield_crash_lua:OnSpellStart()
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor( "damage" )
	local radius = self:GetSpecialValueFor( "radius" )
	local distance = self:GetSpecialValueFor( "jump_horizontal_distance" )
	local duration = self:GetSpecialValueFor( "jump_duration" )
	local height = self:GetSpecialValueFor( "jump_height" )
	local buff_duration = self:GetSpecialValueFor( "duration" )

	--------------------------------- SHIELD CRASH MULTIBALL SHARD ---------------------------------------------------------
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)
	if caster:FindAbilityByName("pangolier_rolling_thunder_multi_ball") and caster:FindAbilityByName("pangolier_rolling_thunder_lua"):IsTrained() then
		new_roller = CreateUnitByName("npc_dota_creature_pangolier_rolling_summon", caster:GetOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)
		new_roller:AddNewModifier(
			caster, 
			self, 
			"modifier_pangolier_npc_gyroshell_lua", 
			{ duration = caster:FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("duration") }
		)
	end
	-------------------------------------------------------------------------------------------------------------------------------
	
	--------------------------------- SHIELD CRASH SWASHBUCKLE SHARD ---------------------------------------------------------
	if caster:FindAbilityByName("pangolier_shield_crash_swashbuckle") and caster:FindAbilityByName("pangolier_swashbuckle_lua"):IsTrained() then
		print("swashbukle!")
		local direction = caster:GetForwardVector()
		print(direction.x,direction.y)
		caster:AddNewModifier(
		caster, 
		self,
		"modifier_pangolier_swashbuckle_lua",
		{
			dir_x = direction.x,
			dir_y = direction.y,
			duration = 3,
			from_crash = true,
		}) 		
	end
	------------------------------------------------------------------------------------------------------------------------------

	local arc = caster:AddNewModifier(
		caster,
		self, 
		"modifier_generic_arc_lua",
		{
			distance = distance,
			duration = duration,
			height = height,
			fix_duration = false,
			isForward = true,
			isStun = true,
			activity = ACT_DOTA_FLAIL,
		} 
	)
	arc:SetEndCallback(function()
		local damage_dealt = 0
		local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(),	
			caster:GetOrigin(),
			nil,	
			radius,	
			DOTA_UNIT_TARGET_TEAM_ENEMY,	
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			0,	
			0,	
			false
		)
		
		local damageTable = {
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self, 
		}
	

		local stack = 0
		for _,enemy in pairs(enemies) do
			damage_dealt = damage_dealt + damage
			damageTable.victim = enemy
			ApplyDamage(damageTable)
			--------------------------------- SHIELD CRASH STUNS SHARD ---------------------------------------------------------
			if caster:FindAbilityByName("pangolier_shield_crash_stuns") then

				enemy:AddNewModifier(caster, self, "modifier_stunned", {duration = caster:FindAbilityByName("pangolier_shield_crash_stuns"):GetSpecialValueFor("stun_duration") * (1 - enemy:GetStatusResistance())})

				local knockback =
				{
					knockback_duration = 0.25 * (1 - enemy:GetStatusResistance()),
					duration = 0.25 * (1 - enemy:GetStatusResistance()),
					knockback_distance = 0,
					knockback_height = 150,
				}
				enemy:RemoveModifierByName("modifier_knockback")
				enemy:AddNewModifier(caster, self, "modifier_knockback", knockback)

			end		
			--------------------------------------------------------------------------------------------------------------------		
				stack = stack + 1
			self:PlayEffects4( enemy )
		end

		if stack>0 then
			if caster:HasModifier("modifier_pangolier_shield_crash_lua") then
				caster:RemoveModifierByName("modifier_pangolier_shield_crash_lua")
			end
			if stack > 100 then stack=99 end
			caster:AddNewModifier(
				caster, 
				self, 
				"modifier_pangolier_shield_crash_lua", 
				{
					duration = buff_duration,
					stack = stack,
				} 
			)
			------------------------ SHIELD CRASH ALLYS SHARD ----------------------------------------
			local heal_pct = caster:FindAbilityByName("pangolier_shield_crash_ally"):GetSpecialValueFor("heal_pct")
			caster:Heal(damage_dealt * (heal_pct/100), caster)
			if caster:FindAbilityByName("pangolier_shield_crash_ally") then
				local allys = FindUnitsInRadius(
					caster:GetTeamNumber(),	
					caster:GetOrigin(),
					nil,	
					radius * caster:FindAbilityByName("pangolier_shield_crash_ally"):GetSpecialValueFor("radius_multiplier"),	
					DOTA_UNIT_TARGET_TEAM_FRIENDLY,	
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					0,	
					0,	
					false
				)
				for _,ally in pairs(allys) do
					if ally:HasModifier("modifier_pangolier_shield_crash_lua") then
						ally:RemoveModifierByName("modifier_pangolier_shield_crash_lua")
					end
					ally:Heal(damage_dealt * (heal_pct/100), caster)
					ally:AddNewModifier(
						caster, 
						self, 
						"modifier_pangolier_shield_crash_lua", 
						{
							duration = buff_duration,
							stack = stack,
						} 
					)
				end
			end
			
			--------------------------------------------------------------------------------------
		end


		self:PlayEffects2()
		if stack>0 then
			self:PlayEffects3()
		end
	end)

	self:PlayEffects1( arc )

	--------------------------------- SHIELD CRASH COOLDOWN IN BALL TALENT ---------------------------------------------------------
	local shield_crash = caster:FindAbilityByName("pangolier_shield_crash_lua")
	if caster:FindAbilityByName("special_bonus_shield_crash_in_ball") and caster:FindAbilityByName("special_bonus_shield_crash_in_ball"):IsTrained() and not shield_crash:IsCooldownReady() and self:GetCaster():HasModifier("modifier_pangolier_gyroshell") then
		shield_crash:EndCooldown()
		shield_crash:StartCooldown(2.5)
	end
	---------------------------------------------------------------------------------------------------------------------------------

end

function pangolier_shield_crash_lua:OnAbilityFullyCast()
	
end

--[[---------------------------------------------------------------------
	SHILED CRASH CHARGES
]]------------------------------------------------------------------------
function pangolier_shield_crash_lua:Spawn()
	if not IsServer() then return end
	Timers( 1, function ( )		
		if self:GetCaster():FindAbilityByName("pangolier_shield_crash_stuns") then			
			print('refreshing intrinsic')			
			self:RefreshIntrinsicModifier()
			return nil
		end
		return 1.5
	end)
end

function pangolier_shield_crash_lua:GetIntrinsicModifierName()
	if self:GetCaster():FindAbilityByName("pangolier_shield_crash_stuns") then
		return "modifier_generic_3_charges"
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
--------------------------------------------------------------------------------
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


