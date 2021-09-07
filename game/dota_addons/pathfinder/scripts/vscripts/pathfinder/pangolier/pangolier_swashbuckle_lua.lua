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

pangolier_swashbuckle_lua = class({})

LinkLuaModifier( "modifier_generic_knockback_lua", "pathfinder/generic/modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_pangolier_swashbuckle_lua", "pathfinder/pangolier/modifier_pangolier_swashbuckle_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pangolier_npc_gyroshell_lua", "pathfinder/pangolier/modifier_pangolier_npc_gyroshell_lua", LUA_MODIFIER_MOTION_NONE )

--[[---------------------------------------------------------------------
	PANGOLIER SWASHBUCKLE
]]------------------------------------------------------------------------

function pangolier_swashbuckle_lua:OnAbilityPhaseInterrupted()

end
function pangolier_swashbuckle_lua:OnAbilityPhaseStart()
	
	if not self:CheckVectorTargetPosition() then return false end
	return true 

end

function pangolier_swashbuckle_lua:OnSpellStart()

	local caster = self:GetCaster()
	local targets = self:GetVectorTargetPosition()
	local speed = self:GetSpecialValueFor( "dash_speed" )
	local direction = targets.direction
	local vector = (targets.init_pos-caster:GetOrigin())
	local dist = vector:Length2D()
	vector.z = 0
	vector = vector:Normalized()
	
	--------------------------------- MULTIBALL SHARD ----------------------------------------------------------------------------------------------
	if caster:FindAbilityByName("pangolier_rolling_thunder_multi_ball") and caster:FindAbilityByName("pangolier_rolling_thunder_lua"):IsTrained() then
		new_roller = CreateUnitByName("npc_dota_creature_pangolier_rolling_summon", caster:GetOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)
		new_roller:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_pangolier_npc_gyroshell_lua", -- modifier name
			{ duration = caster:FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("duration") }
		)
	end
	------------------------------------------------------------------------------------------------------------------------------------------

	
	if caster:HasModifier("modifier_pangolier_gyroshell") then
		caster:RemoveModifierByName("modifier_pangolier_gyroshell")
	end

	caster:SetForwardVector( direction )

	local effects = self:PlayEffects()

	local knockback = caster:AddNewModifier(
		caster, 
		self, 
		"modifier_generic_knockback_lua", 
		{
			direction_x = vector.x,
			direction_y = vector.y,
			distance = dist,
			duration = dist/speed,
			IsStun = true,
			IsFlail = false,
		} 
	)
	local callback = function( bInterrupted )
		
		ParticleManager:DestroyParticle( effects, false )
		ParticleManager:ReleaseParticleIndex( effects )

		if bInterrupted then return end

		caster:AddNewModifier(
			caster,
			self, 
			"modifier_pangolier_swashbuckle_lua",
			{
				dir_x = direction.x,
				dir_y = direction.y,
				duration = 3,
				from_crash = false,
			}
		)
		
		
	end
	knockback:SetEndCallback( callback )
	---------------------------------------- SWASHBUCKLE COOLDOWN TALENT ----------------------------------------------------------------
	local swashbuckle = caster:FindAbilityByName("pangolier_swashbuckle_lua")
	if caster:FindAbilityByName("special_bonus_pathfinder_pangolier_swashbuckle_lua+cooldown"):IsTrained() and not swashbuckle:IsCooldownReady() then	
		swashbuckle:EndCooldown()
		local reduce_amount = caster:FindAbilityByName("special_bonus_pathfinder_pangolier_swashbuckle_lua+cooldown"):GetSpecialValueFor("cooldown")
		local current_cooldown = swashbuckle:GetCooldown(swashbuckle:GetLevel())
		local new_cooldown = current_cooldown - reduce_amount
		swashbuckle:StartCooldown(new_cooldown)
	end
	-----------------------------------------------------------------------------------------------------------------------------------------
end

function pangolier_swashbuckle_lua:PlayEffects()
	
	local particle_cast = "particles/units/heroes/hero_pangolier/pangolier_swashbuckler_dash.vpcf"
	local sound_cast = "Hero_Pangolier.Swashbuckle.Cast"
	local sound_layer = "Hero_Pangolier.Swashbuckle.Layer"

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )

	EmitSoundOn( sound_cast, self:GetCaster() )
	EmitSoundOn( sound_layer, self:GetCaster() )

	return effect_cast

end
