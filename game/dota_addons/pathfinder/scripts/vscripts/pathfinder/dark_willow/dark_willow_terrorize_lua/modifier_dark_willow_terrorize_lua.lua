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
modifier_dark_willow_terrorize_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_dark_willow_terrorize_lua:IsHidden()
	return false
end

function modifier_dark_willow_terrorize_lua:IsDebuff()
	return true
end

function modifier_dark_willow_terrorize_lua:IsStunDebuff()
	return false
end

function modifier_dark_willow_terrorize_lua:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_dark_willow_terrorize_lua:OnCreated( kv )
	if not IsServer() then return end
	-- play effects
	self:PlayEffects()
	local fear_angle = kv.angle
	self.center_point = kv.spell_center
	self.crazy = kv.crazy
	-- local cast_location = kv.location
	-- local target_location = self:GetParent():GetOrigin()
	Msg("Is Crazy? : " .. kv.crazy .. "\n")
	if kv.crazy == 1 then
		Msg("Doing crazy logic \n")
		local nearest_ally = FindUnitsInRadius(
			kv.teamnumber,	-- int, unit team number
			self:GetParent():GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			FIND_CLOSEST,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)
		for _,ally in pairs(nearest_ally) do
			self:GetParent():MoveToTargetToAttack(ally)
			self:GetParent():SetForceAttackTargetAlly(ally)
			break
		end
		
	else
		local travel_dist = 800
		local fear_target_loc = Vector( 0, 0, 0 )

		local current_pos = self:GetParent():GetOrigin()
		local run_from_pos = self:GetCaster():GetOrigin()
		local fear_angle = math.atan2(run_from_pos.y - current_pos.y, run_from_pos.x - current_pos.x) * 180 / math.pi
		Msg("Fear Angle: " .. fear_angle .. "\n")

		repeat
			fear_target_loc = RotatePosition( self:GetParent():GetOrigin(), QAngle( 0, fear_angle, 0 ), self:GetParent():GetOrigin() + Vector(0,travel_dist,0) )
			travel_dist = travel_dist - 25
		until((GridNav:CanFindPath(current_pos, fear_target_loc)) or travel_dist <= 0)

		self:GetParent():MoveToPosition( fear_target_loc )
	end
	

end

function modifier_dark_willow_terrorize_lua:OnRefresh( kv )
	
end

function modifier_dark_willow_terrorize_lua:OnRemoved()
end

function modifier_dark_willow_terrorize_lua:OnDestroy()
	if not IsServer() then return end

	-- stop running
	self:GetParent():Stop()
	if self:GetParent():IsCreep() then
		self:GetParent():SetForceAttackTargetAlly( nil ) -- for creeps
	end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_dark_willow_terrorize_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
		MODIFIER_EVENT_ON_ATTACK_START,
	}

	return funcs
end

function modifier_dark_willow_terrorize_lua:GetModifierProvidesFOWVision()
	return 1
end

function modifier_dark_willow_terrorize_lua:OnAttackStart()
	if not self:GetCaster():HasAbility("dark_willow_terrorize_lua_crazy") then
		self:GetParent():Stop()
	end
end


--------------------------------------------------------------------------------
-- Status Effects
function modifier_dark_willow_terrorize_lua:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_SILENCED] = true,
	}

	if self.crazy == 1 then
		state = {
			[MODIFIER_STATE_DISARMED] = false,
			[MODIFIER_STATE_COMMAND_RESTRICTED] = false,
			[MODIFIER_STATE_MUTED] = false,
			[MODIFIER_STATE_SILENCED] = false,
		}
	end
	
	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_dark_willow_terrorize_lua:GetStatusEffectName()
	return "particles/status_fx/status_effect_dark_willow_wisp_fear.vpcf"
end

function modifier_dark_willow_terrorize_lua:PlayEffects()
	-- Get Resources
	local particle_cast1 = "particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell_debuff.vpcf"
	local particle_cast2 = "particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell_fear_debuff.vpcf"

	-- Create Particle
	local effect_cast1 = ParticleManager:CreateParticle( particle_cast1, PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
	local effect_cast2 = ParticleManager:CreateParticle( particle_cast2, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	-- local effect_cast1 = assert(loadfile("lua_abilities/rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast1, PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
	-- local effect_cast2 = assert(loadfile("lua_abilities/rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast2, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )

	-- buff particle
	self:AddParticle(
		effect_cast1,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
	self:AddParticle(
		effect_cast2,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end