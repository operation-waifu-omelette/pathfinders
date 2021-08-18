modifier_pathfinder_juggernaut_blade_fury = class({})
LinkLuaModifier( "modifier_pathfinder_bonus_strength", "pathfinder/modifier_pathfinder_bonus_strength", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_juggernaut_blade_fury:IsHidden()
	return false
end

function modifier_pathfinder_juggernaut_blade_fury:IsDebuff()
	return false
end

function modifier_pathfinder_juggernaut_blade_fury:IsPurgable()
	return false
end

function modifier_pathfinder_juggernaut_blade_fury:DestroyOnExpire()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_pathfinder_juggernaut_blade_fury:OnCreated( kv )
	-- references
	self.tick = self:GetAbility():GetSpecialValueFor( "blade_fury_damage_tick" ) -- special value
	self.radius = self:GetAbility():GetSpecialValueFor( "blade_fury_radius" ) -- special value
	self.dps = self:GetAbility():GetSpecialValueFor( "blade_fury_damage" ) -- special value
	
	self.max_count = kv.duration/self.tick
	self.count = 0

	-- Start interval
	if IsServer() then
		-- precache damagetable
		self.damageTable = {
			-- victim = target,
			attacker = self:GetParent(),
			damage = self.dps * self.tick,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(), --Optional.
		}

		self:StartIntervalThink( self.tick )
		self:GetCaster():Purge(false, true, false, false, false)
	end

	-- PlayEffects
	self:PlayEffects()
	
end

function modifier_pathfinder_juggernaut_blade_fury:OnRefresh( kv )
	-- references
	self.tick = self:GetAbility():GetSpecialValueFor( "blade_fury_damage_tick" ) -- special value
	self.radius = self:GetAbility():GetSpecialValueFor( "blade_fury_radius" ) -- special value
	self.dps = self:GetAbility():GetSpecialValueFor( "blade_fury_damage" ) -- special value


	self.count = 0

	if IsServer() then
		self.damageTable.damage = self.dps * self.tick
	end
end

function modifier_pathfinder_juggernaut_blade_fury:OnDestroy( kv )
	-- Stop effects
	local sound_cast = "Hero_Juggernaut.BladeFuryStart"
	StopSoundOn( sound_cast, self:GetParent() )
end

--------------------------------------------------------------------------------
-- Status Effects
require("libraries.has_shard")

function modifier_pathfinder_juggernaut_blade_fury:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,	
		-- [MODIFIER_STATE_STUNNED] = false,
	}
	if HasShard(self:GetAbility():GetCaster(),"pathfinder_special_juggernaut_blade_fury_flying") then
		state[MODIFIER_STATE_FLYING] = true
	end	
	if HasShard(self:GetAbility():GetCaster(),"pathfinder_special_juggernaut_blade_fury_strength") and self:GetCaster():GetUnitName()== "npc_dota_hero_juggernaut" then
		state[MODIFIER_STATE_DISARMED] = true
	end	
	return state
end
--------------------------------------------------------------------------------
-- Interval Effects
function modifier_pathfinder_juggernaut_blade_fury:OnIntervalThink()
	-- Find enemies in radius
	if not IsServer() then return end
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	require("libraries.has_shard")
	if HasShard(self:GetCaster(), "pathfinder_special_juggernaut_blade_fury_strength") then
		local str_ability = self:GetCaster():FindAbilityByName("pathfinder_special_juggernaut_blade_fury_strength")
		if #enemies > 0 then
			self:ForceRefresh()
		end
		-- local bonus_strength_duration = str_ability:GetSpecialValueFor("strength_duration")

		-- for _,enemy in pairs(enemies) do			
		-- 	if self:GetCaster():HasModifier("modifier_pathfinder_bonus_strength") then
		-- 		self:GetCaster():AddNewModifier(self:GetCaster(), str_ability, "modifier_pathfinder_bonus_strength", {duration = bonus_strength_duration})
		-- 		self:GetCaster():SetModifierStackCount("modifier_pathfinder_bonus_strength", self:GetCaster(), self:GetCaster():GetModifierStackCount("modifier_pathfinder_bonus_strength", self:GetCaster()) + 1)
		-- 		self:GetCaster():CalculateStatBonus(true)
		-- 	else
		-- 		self:GetCaster():AddNewModifier(self:GetCaster(), str_ability, "modifier_pathfinder_bonus_strength", {duration = bonus_strength_duration})
		-- 		self:GetCaster():CalculateStatBonus(true)
		-- 	end
		-- end 
	end

	-- damage enemies
	for _,enemy in pairs(enemies) do
		self.damageTable.victim = enemy
		ApplyDamage( self.damageTable )

		-- Play effects
		self:PlayEffects2( enemy )
	end

	-- counter
	self.count = self.count+1
	if self.count>= self.max_count then
		self:Destroy()
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_pathfinder_juggernaut_blade_fury:PlayEffects()
		-- Get Resources
	local particle_cast = "particles/units/heroes/hero_juggernaut/juggernaut_blade_fury.vpcf"
	local sound_cast = "Hero_Juggernaut.BladeFuryStart"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 5, Vector( self.radius, 0, 0 ) )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)

	-- Emit sound	
	if IsServer() then
		self:GetParent():EmitSoundParams(sound_cast, -1, 0.55, -1)
	end
end

function modifier_pathfinder_juggernaut_blade_fury:PlayEffects2( target )
	local particle_cast = "particles/units/heroes/hero_juggernaut/juggernaut_blade_fury_tgt.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_pathfinder_juggernaut_blade_fury:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE ,
	}
	return funcs
end

function modifier_pathfinder_juggernaut_blade_fury:GetModifierIncomingDamage_Percentage( params )
	if HasShard(self:GetAbility():GetCaster(), "pathfinder_special_juggernaut_blade_fury_flying") then
		return -1 * self:GetAbility():GetCaster():FindAbilityByName("pathfinder_special_juggernaut_blade_fury_flying"):GetSpecialValueFor("damage_reduction")
	else
		return 0
	end	
end

function modifier_pathfinder_juggernaut_blade_fury:GetOverrideAnimation( params )
	return ACT_DOTA_OVERRIDE_ABILITY_1
end


function modifier_pathfinder_juggernaut_blade_fury:GetModifierMoveSpeedBonus_Percentage( params )
	if self:GetCaster():FindAbilityByName("pathfinder_special_juggernaut_blade_fury_strength") then
		local slow = self:GetCaster():FindAbilityByName("pathfinder_special_juggernaut_blade_fury_strength"):GetLevelSpecialValueFor("slow_pct", 1)
		return -1 * slow	
	end
end

