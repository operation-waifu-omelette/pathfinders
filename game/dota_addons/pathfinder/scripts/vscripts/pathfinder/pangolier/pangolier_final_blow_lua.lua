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
pangolier_final_blow= class({})
LinkLuaModifier( "modifier_generic_knockback_lua", "pathfinder/generic/modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_pangolier_final_blow_impact_check", "pathfinder/pangolier/pangolier_final_blow_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_pangolier_final_blow_marked", "pathfinder/pangolier/pangolier_final_blow_lua", LUA_MODIFIER_MOTION_BOTH )

--------------------------------------------------------------------------------
-- Ability Phase Start
function pangolier_final_blow:OnAbilityPhaseInterrupted()

end

function pangolier_final_blow:OnUpgrade()
	if IsServer() then
		self:GetCaster():SwapAbilities("pangolier_final_blow", "pangolier_lucky_shot_lua", true , true)
	end
end
--------------------------------------------------------------------------------
-- Ability Start
function pangolier_final_blow:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()



	local point = self:GetCursorPosition()
	local vector = point-caster:GetOrigin()
	vector.z = 0
	local origin = caster:GetOrigin()
	-- load data
	local speed = self:GetSpecialValueFor( "dash_speed" )
	local dist = vector:Length2D()
	vector.z = 0
	vector = vector:Normalized()
	caster:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_pangolier_final_blow_impact_check", -- modifier name
		{
			duration = dist/speed,
		} -- kv
	)
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_1)

	self.damage_multiplier =  self:GetSpecialValueFor( "damage_multiplier" )
	self.radius =  self:GetSpecialValueFor( "radius" )
	self.duration =  self:GetSpecialValueFor( "duration" )

	caster:SetForwardVector( vector )
	
	if self:GetCaster():HasModifier("modifier_pangolier_gyroshell") then
		self:GetCaster():RemoveModifierByName("modifier_pangolier_gyroshell")
	end

	-- Play effects
	local effects = self:PlayEffects()
	local effects2 = ParticleManager:CreateParticle("particles/econ/items/bloodseeker/bloodseeker_ti7/bloodseeker_ti7_ambient_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	local effects3 = ParticleManager:CreateParticle("particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	-- local effects4 = ParticleManager:CreateParticle("particles/econ/items/ursa/ursa_swift_claw/ursa_swift_claw_left.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	-- local effects5 = ParticleManager:CreateParticle("particles/econ/items/zeus/lightning_weapon_fx/zues_immortal_lightning_weapon_energy.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())


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
		ParticleManager:DestroyParticle( effects2, false )
		ParticleManager:ReleaseParticleIndex( effects2 )
		ParticleManager:DestroyParticle( effects3, false )
		ParticleManager:ReleaseParticleIndex( effects3 )
		-- ParticleManager:DestroyParticle( effects4, false )
		-- ParticleManager:ReleaseParticleIndex( effects4 )
		-- ParticleManager:DestroyParticle( effects5, false )
		-- ParticleManager:ReleaseParticleIndex( effects5 )
		if bInterrupted then return end			
	end

	knockback:SetEndCallback( callback )
end

--------------------------------------------------------------------------------
function pangolier_final_blow:PlayEffects()
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

-- Impact checker, will extend Rolling Thunder duration on each hero hit will also hadle the targets and damage for Talent #7
modifier_pangolier_final_blow_impact_check = modifier_pangolier_final_blow_impact_check or class({})


function modifier_pangolier_final_blow_impact_check:IsHidden() return true end
function modifier_pangolier_final_blow_impact_check:IsPurgable() return false end
function modifier_pangolier_final_blow_impact_check:IsDebuff() return false end

function modifier_pangolier_final_blow_impact_check:OnCreated()
	if IsServer() then
		--Ability Specials
		self.hit_radius = self:GetAbility():GetSpecialValueFor( "radius" )
        self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
        local caster = self:GetCaster()
		-- Increase think time so the talent damage hopefully doesn't stack in one instance
		self:StartIntervalThink(0.01)
	end
end

function modifier_pangolier_final_blow_impact_check:OnIntervalThink()
	if IsServer() then		
		local enemies_hit = 0

		-- Find all enemies in AoE
		local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
			self:GetParent():GetAbsOrigin(),
			nil,
			self.hit_radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false)

		-- Check how many targets are valid (not impacted recently)
		for _,enemy in pairs(enemies) do
			
			if not enemy:HasModifier("modifier_pangolier_final_blow_marked") then	
				enemy:AddNewModifier(
					self:GetCaster(), -- player source
					self:GetAbility(), -- ability source
					"modifier_pangolier_final_blow_marked", -- modifier name
					{ duration = self.duration } -- kv
				)					
				EmitSoundOn("Hero_Pangolier.Gyroshell.Carom", enemy)				
			end
		
		end
		
	end
end


modifier_pangolier_final_blow_marked = modifier_pangolier_final_blow_marked or class({})
function modifier_pangolier_final_blow_marked:IsHidden() return true end
function modifier_pangolier_final_blow_marked:IsPurgable() return false end
function modifier_pangolier_final_blow_marked:IsDebuff() return false end
function modifier_pangolier_final_blow_marked:GetEffectName()
	return "particles/items3_fx/silver_edge.vpcf"
end

function modifier_pangolier_final_blow_marked:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_pangolier_final_blow_marked:CheckState()
	state = {
			[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_BLIND] = true
			}
	return state
end

function modifier_pangolier_final_blow_marked:OnRemoved()
		self:GetAbility():GetCaster():PerformAttack( self:GetParent(), true, true, true, false, false, false, true )
		-- play sound
		local sound_target = "Hero_Pangolier.Swashbuckle.Damage"
		EmitSoundOn( sound_target, self:GetParent() )
		local particle_cast2 = "particles/items3_fx/silver_edge.vpcf"
		local effect_cast2 = ParticleManager:CreateParticle( particle_cast2, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:DestroyParticle( effect_cast2, false )
		ParticleManager:ReleaseParticleIndex( effect_cast2 )
		if self:GetParent():GetHealthPercent() <= 0 then
			local direction = (self:GetParent():GetOrigin() - self:GetAbility():GetCaster():GetOrigin()):Normalized()
			local particle_cast = "particles/econ/items/lifestealer/ls_ti9_immortal_gold/ls_ti9_open_wounds_gold_blood_soft.vpcf"
			local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			ParticleManager:SetParticleControl( effect_cast, 4, self:GetParent():GetOrigin() )
			ParticleManager:SetParticleControlForward( effect_cast, 3, direction )
			ParticleManager:ReleaseParticleIndex( effect_cast )
		end 		

end



