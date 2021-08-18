phantom_assassin_phantom_strike_lua = class({})
LinkLuaModifier( "modifier_phantom_assassin_phantom_strike_lua", "pathfinder/phantom_assassin_phantom_strike_lua/modifier_phantom_assassin_phantom_strike_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_proximity_illusion", "pathfinder/modifier_proximity_illusion", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Cast Filter
function phantom_assassin_phantom_strike_lua:CastFilterResultTarget( hTarget )
	if self:GetCaster() == hTarget then
		return UF_FAIL_CUSTOM
	end

	local result = UnitFilter(
		hTarget,	-- Target Filter
		DOTA_UNIT_TARGET_TEAM_BOTH,	-- Team Filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- Unit Flag
		self:GetCaster():GetTeamNumber()	-- Team reference
	)
	
	if result ~= UF_SUCCESS then
		return result
	end

	return UF_SUCCESS
end

function phantom_assassin_phantom_strike_lua:GetCastRange(target, location)
    return self:GetSpecialValueFor("range")
end

--------------------------------------------------------------------------------
-- Ability Cast Error Message
function phantom_assassin_phantom_strike_lua:GetCustomCastErrorTarget( hTarget )
	if self:GetCaster() == hTarget then
		return "#dota_hud_error_cant_cast_on_self"
	end

	return ""
end



--------------------------------------------------------------------------------
-- Ability Start
function phantom_assassin_phantom_strike_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local origin = caster:GetOrigin()

	-- Stop if blocked by linken
	if target:GetTeamNumber()~=caster:GetTeamNumber() then
		if target:TriggerSpellAbsorb( self ) then
			return
		end
	end

	if IsServer() and caster:HasAbility("pathfinder_special_pa_blink_illusion") then
		local special = caster:FindAbilityByName("pathfinder_special_pa_blink_illusion")
		local modifierKeys = {}
		modifierKeys.outgoing_damage = special:GetLevelSpecialValueFor("damage_dealt",1) - 100
		modifierKeys.incoming_damage = special:GetLevelSpecialValueFor("damage_taken",1)
		modifierKeys.duration = -1							
		local illusion = CreateIllusions( caster, caster, modifierKeys, 1, 20, true, true)
		illusion[1]:AddNewModifier(self:GetCaster(), self, "modifier_grimstroke_scepter_buff", {})
		illusion[1]:AddNewModifier(self:GetCaster(), self, "modifier_proximity_illusion", {})
		illusion[1]:SetControllableByPlayer(-1, true)
	end

	-- Get data
	local buff_duration = self:GetLevelSpecialValueFor("duration", self:GetLevel()-1)

	-- Generate data
	local blinkDistance = 50
	local blinkDirection = (caster:GetOrigin() - target:GetOrigin()):Normalized() * blinkDistance
	local blinkPosition = target:GetOrigin() + blinkDirection

	-- Blink
	caster:SetOrigin( blinkPosition )
	FindClearSpaceForUnit( caster, blinkPosition, true )
	caster:AddNewModifier(caster, self, "modifier_phased", {duration = 2})

	local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetLevelSpecialValueFor("radius", self:GetLevel() - 1), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
	for _,enemy in pairs(enemies) do
		self:GetCaster():PerformAttack(enemy, false, true, true, true, false, false, false)	
	end
	local radius_fx = ParticleManager:CreateParticle("particles/econ/items/ursa/ursa_ti10/ursa_ti10_earthshock_rings.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(radius_fx, 1, Vector(0, self:GetSpecialValueFor("radius") / 2 , 0))
	ParticleManager:ReleaseParticleIndex(radius_fx)

	-- Add modifier
	if target:GetTeamNumber()~=caster:GetTeamNumber() then
		caster:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_phantom_assassin_phantom_strike_lua", -- modifier name
			{ duration = buff_duration } -- kv
		)		
		caster:MoveToTargetToAttack(target)
	end

	caster:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_phased", -- modifier name
			{ duration = buff_duration } -- kv
		)

	require("libraries.timers")

	if IsServer() and caster:HasAbility("pathfinder_special_pa_blink_aoe") then
		local special = caster:FindAbilityByName("pathfinder_special_pa_blink_aoe")
		local pulse = special:GetLevelSpecialValueFor("pulse",1)
		local center = self:GetCaster():GetOrigin()
		local interval = 1.6
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_riki/riki_tricks_ring.vpcf", PATTACH_WORLDORIGIN, nil ) 
		ParticleManager:SetParticleControl( nFXIndex, 0, center )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector(special:GetLevelSpecialValueFor("radius",1),0,0) )
		ParticleManager:SetParticleControl( nFXIndex, 2, Vector(pulse * interval,0,0) )
		--ParticleManager:DestroyParticle(nFXIndex, false)
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		for i=0,pulse do			
			Timers:CreateTimer(interval*i, function()
				local enemies = FindUnitsInRadius( caster:GetTeamNumber(), center, nil, special:GetLevelSpecialValueFor("radius",1), 
					DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
					DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )		
				for _,enemy in pairs(enemies) do
					self:GetCaster():PerformAttack(enemy, true, true, true, true, false, false, true)
					nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/legion/legion_overwhelming_odds_ti7/legion_commander_odds_ti7_proj_hit_streaks.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, enemy ) 
					ParticleManager:SetParticleControl( nFXIndex, 0, enemy:GetAbsOrigin() + Vector(0,0,-150))
					ParticleManager:ReleaseParticleIndex( nFXIndex )
				end
				return nil
			end)			
		end

	end

	self:PlayEffects( origin )
end

--------------------------------------------------------------------------------
function phantom_assassin_phantom_strike_lua:PlayEffects( origin )
	-- Get Resources
	local particle_cast_start = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_phantom_strike_start.vpcf"
	local sound_cast_start = "Hero_PhantomAssassin.Strike.Start"
	local particle_cast_end = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_phantom_strike_end.vpcf"
	local sound_cast_end = "Hero_PhantomAssassin.Strike.End"

	-- Create Particle
	local effect_cast_start = ParticleManager:CreateParticle( particle_cast_start, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast_start, 0, origin )
	ParticleManager:ReleaseParticleIndex( effect_cast_start )

	local effect_cast_end = ParticleManager:CreateParticle( particle_cast_end, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast_end, 0, self:GetCaster():GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast_end )

	-- Create Sound
	EmitSoundOnLocationWithCaster( origin, sound_cast_start, self:GetCaster() )
	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), sound_cast_end, self:GetCaster() )
end
