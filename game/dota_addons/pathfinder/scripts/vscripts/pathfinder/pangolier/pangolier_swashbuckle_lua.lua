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
--------------------------------------------------------------------------------
-- Ability Phase Start
function pangolier_swashbuckle_lua:OnAbilityPhaseInterrupted()

end
function pangolier_swashbuckle_lua:OnAbilityPhaseStart()
	-- Vector targeting
	if not self:CheckVectorTargetPosition() then return false end
	return true -- if success
end

--------------------------------------------------------------------------------
-- Ability Start
function pangolier_swashbuckle_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local targets = self:GetVectorTargetPosition()
	
	if self:GetCaster():HasAbility("pangolier_swashbuckle_ball") and self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):IsTrained() then
		new_roller = CreateUnitByName("npc_dota_creature_pangolier_rolling_summon", self:GetCaster():GetOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)
		new_roller:AddNewModifier(
			self:GetCaster(), -- player source
			self, -- ability source
			"modifier_pangolier_npc_gyroshell_lua", -- modifier name
			{ duration = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("duration") } -- kv
		)
	end
	-- load data
	local speed = self:GetSpecialValueFor( "dash_speed" )
	local direction = targets.direction

	local vector = (targets.init_pos-caster:GetOrigin())
	local dist = vector:Length2D()
	vector.z = 0
	vector = vector:Normalized()
	
	if self:GetCaster():HasModifier("modifier_pangolier_gyroshell") then
		self:GetCaster():RemoveModifierByName("modifier_pangolier_gyroshell")
	end
	-- Facing
	caster:SetForwardVector( direction )

	-- Play effects
	local effects = self:PlayEffects()

	-- knockback
	local knockback = caster:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_generic_knockback_lua", -- modifier name
		{
			direction_x = vector.x,
			direction_y = vector.y,
			distance = dist,
			duration = dist/speed,
			IsStun = true,
			IsFlail = false,
		} -- kv
	)
	local callback = function( bInterrupted )
		-- stop effects
		ParticleManager:DestroyParticle( effects, false )
		ParticleManager:ReleaseParticleIndex( effects )

		if bInterrupted then return end

		-- add modifier
		caster:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_pangolier_swashbuckle_lua", -- modifier name
			{
				dir_x = direction.x,
				dir_y = direction.y,
				duration = 3, -- max duration
				from_crash = false,
			} -- kv
		)
		
		
	end
	knockback:SetEndCallback( callback )

	local swashbuckle = self:GetCaster():FindAbilityByName("pangolier_swashbuckle_lua")
	if self:GetCaster():HasAbility("special_bonus_pathfinder_pangolier_swashbuckle_lua+cooldown") and self:GetCaster():FindAbilityByName("special_bonus_pathfinder_pangolier_swashbuckle_lua+cooldown"):IsTrained() and not swashbuckle:IsCooldownReady() then	
		swashbuckle:EndCooldown()
		local reduce_amount = self:GetCaster():FindAbilityByName("special_bonus_pathfinder_pangolier_swashbuckle_lua+cooldown"):GetSpecialValueFor("cooldown")
		local current_cooldown = swashbuckle:GetCooldown(swashbuckle:GetLevel())
		print("current cooldown swash: ", cooldown)
		print("doing current cooldown", current_cooldown)
		local new_cooldown = current_cooldown - reduce_amount
		print("doing current cooldown", new_cooldown)
		swashbuckle:StartCooldown(new_cooldown)
	end
end

--------------------------------------------------------------------------------
function pangolier_swashbuckle_lua:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_pangolier/pangolier_swashbuckler_dash.vpcf"
	local sound_cast = "Hero_Pangolier.Swashbuckle.Cast"
	local sound_layer = "Hero_Pangolier.Swashbuckle.Layer"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
	EmitSoundOn( sound_layer, self:GetCaster() )

	return effect_cast
end
