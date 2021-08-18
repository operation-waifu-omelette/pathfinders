require("libraries.timers")

modifier_pathfinder_shadowraze_debuff = class ({})
function modifier_pathfinder_shadowraze_debuff:IsDebuff() return true end


-------------------------------------------------------------------------------------
modifier_pathfinder_revenant_status = class ({})
LinkLuaModifier("modifier_pathfinder_revenant_status", "pathfinder/pathfinder_nevermore.lua", LUA_MODIFIER_MOTION_NONE)


function modifier_pathfinder_revenant_status:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 90001
end

function modifier_pathfinder_revenant_status:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_gold_dire.vpcf" 
end

function modifier_pathfinder_revenant_status:IsHidden()
	return true
end

-- function modifier_pathfinder_revenant_status:RemoveOnDeath()
-- 	return false
-- end

function modifier_pathfinder_revenant_status:DeclareFunctions()
	local funcs = {MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT,					}
	return funcs
end

function modifier_pathfinder_revenant_status:CheckState() 
  local state = {
    [MODIFIER_STATE_UNSELECTABLE] = true,    
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
  }

  if self:GetParent():GetTeamNumber() == DOTA_TEAM_GOODGUYS then
	  return state
  end
end


function modifier_pathfinder_revenant_status:OnTakeDamageKillCredit( params )
	if IsServer() then				
		if params.inflictor and params.attacker and params.attacker:GetUnitName() == "npc_dota_hero_nevermore" and params.attacker:HasAbility("pathfinder_nevermore_special_necromastery_revenant") and params.target == self:GetParent() and params.damage >= params.target:GetHealth() then 			

			local name = params.target:GetUnitName()

			if name == "npc_dota_creature_wave_blaster" then
				name = "npc_dota_creature_baby_ogre_tank"
			elseif name == "npc_dota_undead_woods_skeleton_king" then
				name = "npc_dota_creature_bandit_captain"
			elseif name == "npc_dota_creature_spectre" then
				name = "npc_dota_creature_rock_golem_a"
			end

			local revenant = CreateUnitByName( name, params.target:GetAbsOrigin(), true, params.attacker, params.attacker, DOTA_TEAM_GOODGUYS )
			revenant:AddNewModifier(params.attacker, params.inflictor, "modifier_pathfinder_revenant_status", {})
			revenant:AddNewModifier(params.attacker, params.inflictor, "modifier_kill", {duration = 160})			
			self:Destroy()
        end 
    end 
end

-----------------------------------------

pathfinder_nevermore_shadowraze_near = pathfinder_nevermore_shadowraze_near or class({})
LinkLuaModifier("modifier_pathfinder_shadowraze_debuff", "pathfinder/pathfinder_nevermore.lua", LUA_MODIFIER_MOTION_NONE)

function pathfinder_nevermore_shadowraze_near:GetCooldown()
	if IsServer() then
		return self:GetCaster():FindAbilityByName("pathfinder_nevermore_shadowraze_cooldown"):GetLevelSpecialValueFor("value",1)
	end
end

function pathfinder_nevermore_shadowraze_near:OnUpgrade()
	print("upgrading passive unifier")
	self:GetCaster():FindAbilityByName("pathfinder_nevermore_shadowraze_damage"):UpgradeAbility( true )
	self:GetCaster():FindAbilityByName("pathfinder_nevermore_shadowraze_cooldown"):UpgradeAbility( true )
	self:GetCaster():FindAbilityByName("pathfinder_nevermore_shadowraze_stack_damage"):UpgradeAbility( true )

end

function pathfinder_nevermore_shadowraze_near:OnSpellStart()
	-- Ability properties

	local caster = self:GetCaster()
	local ability = self
	local sound_raze = "Hero_Nevermore.Shadowraze"

	-- Ability specials
	local raze_radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() -1)
	local raze_distance = ability:GetLevelSpecialValueFor("distance", ability:GetLevel() - 1)

	-- Play cast sound
	EmitSoundOn(sound_raze, caster)

	-- Calculate the center point of the raze
	local raze_point = caster:GetAbsOrigin() + caster:GetForwardVector() * raze_distance
	CastShadowRazeOnPoint(caster, ability, raze_point, raze_radius)

	if caster:HasAbility("pathfinder_nevermore_special_raze_multi") then
		local raze_angle = 180
		local left_qangle = QAngle(0, raze_angle, 0)		
		local left = RotatePosition(caster:GetAbsOrigin(), left_qangle, raze_point)		
		CastShadowRazeOnPoint(caster, ability, left, raze_radius)		
	end
end

pathfinder_nevermore_shadowraze_medium = pathfinder_nevermore_shadowraze_medium or class({})
LinkLuaModifier("modifier_pathfinder_shadowraze_debuff", "pathfinder/pathfinder_nevermore.lua", LUA_MODIFIER_MOTION_NONE)

function pathfinder_nevermore_shadowraze_medium:GetCooldown()
	if IsServer() then
		return self:GetCaster():FindAbilityByName("pathfinder_nevermore_shadowraze_cooldown"):GetLevelSpecialValueFor("value",1)
	end
end

function pathfinder_nevermore_shadowraze_medium:OnSpellStart()
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local sound_raze = "Hero_Nevermore.Shadowraze"

	-- Ability specials
	local raze_radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() -1)
	local raze_distance = ability:GetLevelSpecialValueFor("distance", ability:GetLevel() - 1)

	-- Play cast sound
	EmitSoundOn(sound_raze, caster)

	-- Calculate the center point of the raze
	local raze_point = caster:GetAbsOrigin() + caster:GetForwardVector() * raze_distance
	CastShadowRazeOnPoint(caster, ability, raze_point, raze_radius)

	if caster:HasAbility("pathfinder_nevermore_special_raze_multi") then
		local raze_angle = caster:FindAbilityByName("pathfinder_nevermore_special_raze_multi"):GetLevelSpecialValueFor("angle",1)
		local left_qangle = QAngle(0, raze_angle, 0)
		local right_qangle = QAngle(0, raze_angle * (-1), 0)

		local left = RotatePosition(caster:GetAbsOrigin(), left_qangle, raze_point)
		local right = RotatePosition(caster:GetAbsOrigin(), right_qangle, raze_point)

		CastShadowRazeOnPoint(caster, ability, left, raze_radius)
		CastShadowRazeOnPoint(caster, ability, right, raze_radius)		
	end
end

pathfinder_nevermore_shadowraze_far = pathfinder_nevermore_shadowraze_far or class({})
LinkLuaModifier("modifier_pathfinder_shadowraze_debuff", "pathfinder/pathfinder_nevermore.lua", LUA_MODIFIER_MOTION_NONE)

function pathfinder_nevermore_shadowraze_far:GetCooldown()
	if IsServer() then
		return self:GetCaster():FindAbilityByName("pathfinder_nevermore_shadowraze_cooldown"):GetLevelSpecialValueFor("value",1)
	end
end

function pathfinder_nevermore_shadowraze_far:OnSpellStart()
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local sound_raze = "Hero_Nevermore.Shadowraze"

	-- Ability specials
	local raze_radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() -1)
	local raze_distance = ability:GetLevelSpecialValueFor("distance", ability:GetLevel() - 1)

	-- Play cast sound
	EmitSoundOn(sound_raze, caster)

	-- Calculate the center point of the raze
	local raze_point = caster:GetAbsOrigin() + caster:GetForwardVector() * raze_distance
	CastShadowRazeOnPoint(caster, ability, raze_point, raze_radius)

	if caster:HasAbility("pathfinder_nevermore_special_raze_multi") then
		local raze_angle = caster:FindAbilityByName("pathfinder_nevermore_special_raze_multi"):GetLevelSpecialValueFor("angle",1)
		local left_qangle = QAngle(0, raze_angle, 0)
		local right_qangle = QAngle(0, raze_angle * (-1), 0)

		local left = RotatePosition(caster:GetAbsOrigin(), left_qangle, raze_point)
		local right = RotatePosition(caster:GetAbsOrigin(), right_qangle, raze_point)

		CastShadowRazeOnPoint(caster, ability, left, raze_radius)
		CastShadowRazeOnPoint(caster, ability, right, raze_radius)				

		left = RotatePosition(caster:GetAbsOrigin(), left_qangle, left)
		right = RotatePosition(caster:GetAbsOrigin(), right_qangle, right)

		CastShadowRazeOnPoint(caster, ability, left, raze_radius)
		CastShadowRazeOnPoint(caster, ability, right, raze_radius)	
	end
end

function CastShadowRazeOnPoint(caster, ability, point, radius)
	-- Ability properties
	local particle_raze = "particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf"

	-- Add particle effects. CP0 is location, CP1 is radius
	local particle_raze_fx = ParticleManager:CreateParticle(particle_raze, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(particle_raze_fx, 0, point)
	ParticleManager:SetParticleControl(particle_raze_fx, 1, Vector(radius, 1, 1))
	ParticleManager:ReleaseParticleIndex(particle_raze_fx)

	-- Find enemy units in radius
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
									  point,
									  nil,
									  radius,
									  DOTA_UNIT_TARGET_TEAM_ENEMY,
									  DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
									  DOTA_UNIT_TARGET_FLAG_NONE,
									  FIND_ANY_ORDER,
									  false)

	for _,enemy in pairs(enemies) do
		if not enemy:IsMagicImmune() then
			ApplyShadowRazeDamage(caster, ability, enemy)
		end
	end
end

function ApplyShadowRazeDamage(caster, ability, enemy)
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() -1) + caster:FindAbilityByName("pathfinder_nevermore_shadowraze_damage"):GetLevelSpecialValueFor("value", 1)
	local modifier_debuff = "modifier_pathfinder_shadowraze_debuff"
	local stack_damage = ability:GetLevelSpecialValueFor("stack_damage", ability:GetLevel() -1) + caster:FindAbilityByName("pathfinder_nevermore_shadowraze_stack_damage"):GetLevelSpecialValueFor("value", 1)
	local stack_duration = ability:GetSpecialValueFor("stack_duration")

	local debuff_boost = 0		
	if enemy:HasModifier(modifier_debuff) then
		debuff_boost	= stack_damage * enemy:FindModifierByName(modifier_debuff):GetStackCount()
		damage 			= damage + debuff_boost
	end

	local damageTable = {victim = enemy,
						damage = damage,
						damage_type = DAMAGE_TYPE_MAGICAL,
						attacker = caster,
						ability = ability
						}
	local actualy_damage = ApplyDamage(damageTable)    

	if not enemy:HasModifier(modifier_debuff) then
		enemy:AddNewModifier(caster, ability, modifier_debuff, {duration = stack_duration})
	end
	local debuff = enemy:FindModifierByName(modifier_debuff)
	if debuff then
		debuff:IncrementStackCount()
		debuff:ForceRefresh()
	end

end


-----------
modifier_pathfinder_nevermore_necromastery_revenant = modifier_pathfinder_nevermore_necromastery_revenant or class({})

function modifier_pathfinder_nevermore_necromastery_revenant:IsHidden() return true end
function modifier_pathfinder_nevermore_necromastery_revenant:RemoveOnDeath() return false end

pathfinder_nevermore_necromastery = pathfinder_nevermore_necromastery or class({})
LinkLuaModifier("modifier_pathfinder_necromastery_souls", "pathfinder/pathfinder_nevermore.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pathfinder_revenant_status", "pathfinder/pathfinder_nevermore.lua", LUA_MODIFIER_MOTION_NONE)


function pathfinder_nevermore_necromastery:GetIntrinsicModifierName()	
	return "modifier_pathfinder_necromastery_souls"
end

function pathfinder_nevermore_necromastery:GetBehavior()		
	if self:GetCaster():HasModifier("modifier_pathfinder_nevermore_necromastery_revenant") then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	else		
		return DOTA_ABILITY_BEHAVIOR_PASSIVE	
	end
end

function pathfinder_nevermore_necromastery:CastFilterResultTarget(target)
	if IsServer() and self:GetCaster():HasAbility("pathfinder_nevermore_special_necromastery_revenant") and self:GetCaster():FindModifierByName("modifier_pathfinder_necromastery_souls"):GetStackCount() < self:GetCaster():FindAbilityByName("pathfinder_nevermore_special_necromastery_revenant"):GetLevelSpecialValueFor("soul_cost",1) then
		return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end

function pathfinder_nevermore_necromastery:GetCustomCastErrorTarget(hTarget)
	--print("Error")
	if IsServer() then
		if self:GetCaster():HasAbility("pathfinder_nevermore_special_necromastery_revenant") and self:GetCaster():FindModifierByName("modifier_pathfinder_necromastery_souls"):GetStackCount() < self:GetCaster():FindAbilityByName("pathfinder_nevermore_special_necromastery_revenant"):GetLevelSpecialValueFor("soul_cost",1) then
			return "NEED MORE SOULS, FOOL"
		end

		return UF_SUCCESS
	end
end

function pathfinder_nevermore_necromastery:GetCooldown(iLevel)
	if self:GetCaster():HasModifier("modifier_pathfinder_nevermore_necromastery_revenant") then
		return 17
	end
end

function pathfinder_nevermore_necromastery:GetManaCost(iLevel)
	if self:GetCaster():HasModifier("modifier_pathfinder_nevermore_necromastery_revenant") then
		return 100
	end
end

function pathfinder_nevermore_necromastery:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasModifier("modifier_pathfinder_nevermore_necromastery_revenant") then
		return 700
	end
end

function pathfinder_nevermore_necromastery:GetCastPoint()
	if self:GetCaster():HasModifier("modifier_pathfinder_nevermore_necromastery_revenant") then
		return 0.6
	end
end

function pathfinder_nevermore_necromastery:GetAbilityTargetFlags()
	if self:GetCaster():HasModifier("modifier_pathfinder_nevermore_necromastery_revenant") then
		return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
end

function pathfinder_nevermore_necromastery:GetAbilityTargetTeam()
	if self:GetCaster():HasModifier("modifier_pathfinder_nevermore_necromastery_revenant") then
		return DOTA_UNIT_TARGET_TEAM_ENEMY
	end
end

require("libraries.has_shard")

function pathfinder_nevermore_necromastery:GetAbilityTargetType()
	if self:GetCaster():HasModifier("modifier_pathfinder_nevermore_necromastery_revenant") then
		return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	end
end



function pathfinder_nevermore_necromastery:OnSpellStart()	
	if IsServer() and self:GetCaster():HasAbility("pathfinder_nevermore_special_necromastery_revenant") and self:GetCaster():FindModifierByName("modifier_pathfinder_necromastery_souls"):GetStackCount() >= self:GetCaster():FindAbilityByName("pathfinder_nevermore_special_necromastery_revenant"):GetLevelSpecialValueFor("soul_cost",1) then
		local ability = self:GetCaster():FindAbilityByName("pathfinder_nevermore_shadowraze_near")
		if ability and self:GetCaster():HasAbility("pathfinder_nevermore_special_necromastery_revenant") then
			local target = self:GetCaster():GetCursorCastTarget()		
			local raze_radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() -1)
			local sound_raze = "Hero_Nevermore.Shadowraze"	
			EmitSoundOn(sound_raze, target)

			if target then
				RemoveNecromasterySouls(self:GetCaster(), self:GetCaster():FindAbilityByName("pathfinder_nevermore_special_necromastery_revenant"):GetLevelSpecialValueFor("soul_cost",1))
				Timers:CreateTimer(0.05, function()
					local particle_raze_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_WORLDORIGIN, nil)
					ParticleManager:SetParticleControl(particle_raze_fx, 0, target:GetAbsOrigin())
					ParticleManager:SetParticleControl(particle_raze_fx, 1, Vector(250, 1, 1))
					ParticleManager:SetParticleControl(particle_raze_fx, 60, Vector(255, 255, 1))
					ParticleManager:SetParticleControl(particle_raze_fx, 61, Vector(1, 1, 1))
					ParticleManager:ReleaseParticleIndex(particle_raze_fx)
				end)
				target:AddNewModifier(self:GetCaster(), self, "modifier_pathfinder_revenant_status", {duration = 0.5})
				local raze_point = target:GetAbsOrigin()
				CastShadowRazeOnPoint(self:GetCaster(), ability, raze_point, raze_radius)
				
				Timers:CreateTimer(0.5, function()
					local particle_raze_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_WORLDORIGIN, nil)
					ParticleManager:SetParticleControl(particle_raze_fx, 0, target:GetAbsOrigin())
					ParticleManager:SetParticleControl(particle_raze_fx, 1, Vector(250, 1, 1))
					ParticleManager:SetParticleControl(particle_raze_fx, 60, Vector(255, 255, 1))
					ParticleManager:SetParticleControl(particle_raze_fx, 61, Vector(1, 1, 1))
					ParticleManager:ReleaseParticleIndex(particle_raze_fx)
					target:AddNewModifier(self:GetCaster(), self, "modifier_pathfinder_revenant_status", {duration = 0.5})
					local raze_point = target:GetAbsOrigin()
					CastShadowRazeOnPoint(self:GetCaster(), ability, raze_point, raze_radius)
				end)					
			end
		end
	end
end

-- function pathfinder_nevermore_necromastery:OnProjectileHit_ExtraData(target, location, extra_data)
-- 	local req = self:GetCaster():FindAbilityByName("pathfinder_nevermore_requiem")
-- 	if not target and not (self.caster:HasAbility("pathfinder_nevermore_special_requiem_soul_projectile") and req and req:GetLevel() > 0) then	
-- 	-- If there was no target, do nothing
-- 		return nil
-- 	end

-- 	-- Ability properties
-- 	local caster = self:GetCaster()
-- 	local ability = req
-- 	local modifier_debuff = "modifier_pathfinder_nevermore_requiem_debuff"

-- 	-- Ability specials
-- 	local damage = ability:GetSpecialValueFor("damage")

-- 	print(damage)
-- 	local slow_duration = ability:GetSpecialValueFor("slow_duration")


-- 	-- Apply the debuff on enemies hit
-- 	target:AddNewModifier(caster, ability, modifier_debuff, {duration = slow_duration * (1 - target:GetStatusResistance())})

	
-- 	target:EmitSound("Hero_Nevermore.RequiemOfSouls.Damage")
	
-- 	-- Damage the target
-- 	local damageTable = {victim = target,
-- 						damage = damage,
-- 						damage_type = DAMAGE_TYPE_MAGICAL,
-- 						attacker = caster,
-- 						ability = ability
-- 						}

-- 	local damage_dealt = ApplyDamage(damageTable)

-- 	if IsServer() and caster:HasAbility("pathfinder_nevermore_special_requiem_attack") then
-- 		local special = caster:FindAbilityByName("pathfinder_nevermore_special_requiem_attack")
-- 		if not caster:HasModifier("modifier_pathfinder_requiem_attack") then
-- 			caster:AddNewModifier(caster, ability, "modifier_pathfinder_requiem_attack", {duration = special:GetLevelSpecialValueFor("stacks_duration",1)})
-- 		end
-- 		for i=1,special:GetLevelSpecialValueFor("stacks_per_hit",1) do			
-- 			local mod = caster:FindModifierByName("modifier_pathfinder_requiem_attack")
-- 			if mod then
-- 				mod:IncrementStackCount()			
-- 				mod:ForceRefresh()
-- 			end
-- 		end
-- 	end
-- end

modifier_pathfinder_nevermore_special_necromastery_lifesteal						= class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,
	RemoveOnDeath 			= function(self) return false end,
})



-- Necromastery souls modifier
modifier_pathfinder_necromastery_souls = modifier_pathfinder_necromastery_souls or class({})
LinkLuaModifier("modifier_pathfinder_nevermore_requiem_debuff", "pathfinder/pathfinder_nevermore.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pathfinder_nevermore_necromastery_revenant", "pathfinder/pathfinder_nevermore.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pathfinder_nevermore_special_necromastery_lifesteal", "pathfinder/pathfinder_nevermore.lua", LUA_MODIFIER_MOTION_NONE)



function modifier_pathfinder_necromastery_souls:OnCreated()	
	-- Ability properties
	self.caster = self:GetCaster()
	self.requiem_ability = "pathfinder_nevermore_requiem"
	
	self.ability = self:GetAbility()
	self.particle_soul = "particles/units/heroes/hero_nevermore/nevermore_necro_souls.vpcf"

	-- Ability specials
	self.damage_per_soul = self.ability:GetLevelSpecialValueFor("damage_per_soul", self.ability:GetLevel() - 1)
	self.max_souls = self.ability:GetLevelSpecialValueFor("max_souls", self.ability:GetLevel() - 1)

	self.souls_per_kill = self.ability:GetLevelSpecialValueFor("souls_per_kill", self.ability:GetLevel() - 1)


	self.soul_projectile_speed = self.ability:GetLevelSpecialValueFor("soul_projectile_speed", self.ability:GetLevel() - 1)
	self.souls_lost_on_death_pct = self.ability:GetLevelSpecialValueFor("souls_lost_on_death_pct", self.ability:GetLevel() - 1)


	self:StartIntervalThink(1.5)
end


function modifier_pathfinder_necromastery_souls:OnIntervalThink()
	if IsServer() and self:GetCaster():HasAbility("pathfinder_nevermore_special_necromastery_revenant") then		
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_pathfinder_nevermore_necromastery_revenant", {})		
	end

	if IsServer() and self.caster:HasAbility("pathfinder_nevermore_special_necromastery_lifesteal") and not self.caster:HasModifier("modifier_pathfinder_nevermore_special_necromastery_lifesteal") then		
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_pathfinder_nevermore_special_necromastery_lifesteal", {})		
	end
end

function modifier_pathfinder_necromastery_souls:GetHeroEffectName()
	return "particles/units/heroes/hero_nevermore/nevermore_souls_hero_effect.vpcf"
end



function modifier_pathfinder_necromastery_souls:OnRefresh()
	self:OnCreated()
end

function modifier_pathfinder_necromastery_souls:DestroyOnExpire()
	return false
end

function modifier_pathfinder_necromastery_souls:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}
end

function modifier_pathfinder_necromastery_souls:GetModifierPreAttack_BonusDamage()
	local stacks = self:GetStackCount()
	return self.damage_per_soul * stacks
end

function modifier_pathfinder_necromastery_souls:OnAttackLanded(keys)
	if IsServer() then		
		local attacker = keys.attacker
		local target = keys.target
		
		if self:GetCaster() ~= attacker or self:GetCaster() == target then
			return
		elseif not self:GetCaster():HasAbility("pathfinder_nevermore_special_necromastery_attack_soul") or self:GetCaster():PassivesDisabled() then
			return
		end
		local special = self:GetCaster():FindAbilityByName("pathfinder_nevermore_special_necromastery_attack_soul")
		if RandomInt(1,100) > special:GetLevelSpecialValueFor("chance",1) then
			return
		end
		local soul_count = special:GetLevelSpecialValueFor("amount",1)
									
		-- Increase souls appropriately

		AddNecromasterySouls(self:GetCaster(), soul_count)

		-- If caster is not disabled and is visible, launch a soul
		if IsServer() and not self.caster:PassivesDisabled() then		
			-- Launch a creep soul to the caster
			local soul_projectile = {Target = attacker,
											Source = target,
											Ability = self.ability,
											EffectName = self.particle_soul,
											bDodgeable = false,
											bProvidesVision = false,
											iMoveSpeed = self.soul_projectile_speed,
											iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
											}

			ProjectileManager:CreateTrackingProjectile(soul_projectile)			
			if self.caster:HasAbility("pathfinder_nevermore_special_requiem_soul_projectile") then						
				local req = self:GetCaster():FindAbilityByName("pathfinder_nevermore_requiem")
				if self.caster:HasAbility("pathfinder_nevermore_special_requiem_soul_projectile") and req and req:GetLevel() > 0 then	
					self.caster:SetCursorCastTarget(target)
					self.caster:FindAbilityByName("pathfinder_nevermore_special_requiem_soul_projectile"):OnSpellStart()
				end
			end
		end	
	end
end

function modifier_pathfinder_necromastery_souls:OnDeath(keys)
	if IsServer() then
		local target = keys.unit
		local attacker = keys.attacker

		-- Only apply if the caster is the attacker (and NOT the victim)
		if self.caster == attacker and self.caster ~= target then			
			-- If the target was a building, do nothing
			if target:IsBuilding() then
				return nil
			end

			-- Decide how many souls should the caster get
			local soul_count = self.souls_per_kill
									
			-- Increase souls appropriately
	
			AddNecromasterySouls(self.caster, soul_count)

			-- If caster is not disabled and is visible, launch a soul
			if IsServer() and not self.caster:PassivesDisabled() then		
				-- Launch a creep soul to the caster
				local soul_projectile = {Target = self.caster,
											Source = target,
											Ability = self.ability,
											EffectName = self.particle_soul,
											bDodgeable = false,
											bProvidesVision = false,
											iMoveSpeed = self.soul_projectile_speed,
											iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
											}

				ProjectileManager:CreateTrackingProjectile(soul_projectile)	
				if self.caster:HasAbility("pathfinder_nevermore_special_requiem_soul_projectile") then					
					local req = self:GetCaster():FindAbilityByName("pathfinder_nevermore_requiem")
					if req and req:GetLevel() > 0 then	
						self.caster:SetCursorCastTarget(target)
						self.caster:FindAbilityByName("pathfinder_nevermore_special_requiem_soul_projectile"):OnSpellStart()
					end
				end
			end
		end


		-- If the caster was the one who died, he loses half his stacks
		if self.caster == target and not target:IsIllusion() then
			local stacks = self:GetStackCount()
			local stacks_lost = math.floor(stacks * (self.souls_lost_on_death_pct * 0.01))
			RemoveNecromasterySouls(self.caster, stacks_lost)

			-- If the caster has Requiem of Souls, use the spell with a death cast tag
			if IsServer() and self.caster:HasAbility(self.requiem_ability) then
				local requiem_ability_handler = self.caster:FindAbilityByName(self.requiem_ability)
				if requiem_ability_handler then
					if requiem_ability_handler:GetLevel() >= 1 then
						requiem_ability_handler:OnSpellStart(true)
					end
				end
			end
		end
	end
end

function modifier_pathfinder_necromastery_souls:GetModifierSpellLifestealRegenAmplify_Percentage( params )
	if self:GetParent():HasModifier("modifier_pathfinder_nevermore_special_necromastery_lifesteal") then
		return self:GetStackCount() * 2
	end
end

function modifier_pathfinder_necromastery_souls:GetModifierSpellAmplify_Percentage( params )
	if self:GetParent():HasModifier("modifier_pathfinder_nevermore_special_necromastery_lifesteal") then		
		return self:GetStackCount()	
	end
end


function modifier_pathfinder_necromastery_souls:RemoveOnDeath() return false end
function modifier_pathfinder_necromastery_souls:IsHidden() return false end
function modifier_pathfinder_necromastery_souls:IsPurgable() return false end
function modifier_pathfinder_necromastery_souls:IsDebuff() return false end
function modifier_pathfinder_necromastery_souls:AllowIllusionDuplicate() return true end

function AddNecromasterySouls(caster, soul_count)
	local modifier_souls = "modifier_pathfinder_necromastery_souls"

	-- If caster is broken, do nothing
	if caster:PassivesDisabled() then
		return nil
	end
	if caster:HasModifier(modifier_souls) then
		local modifier_souls_handler = caster:FindModifierByName(modifier_souls)
		if modifier_souls_handler then
			for i = 1, soul_count do
				if modifier_souls_handler:GetStackCount() < caster:FindAbilityByName("pathfinder_nevermore_necromastery"):GetLevelSpecialValueFor("max_souls",caster:FindAbilityByName("pathfinder_nevermore_necromastery"):GetLevel() -1) then
					modifier_souls_handler:IncrementStackCount()
				end
			end
		end
	end
end

function RemoveNecromasterySouls(caster, soul_count)
	local modifier_souls = "modifier_pathfinder_necromastery_souls"

	if caster:HasModifier(modifier_souls) then
		local modifier_souls_handler = caster:FindModifierByName(modifier_souls)
		if modifier_souls_handler then
			for i = 1, soul_count do
				modifier_souls_handler:DecrementStackCount()
			end
		end
	end
end



pathfinder_nevermore_dark_lord = pathfinder_nevermore_dark_lord or class({})
LinkLuaModifier("modifier_pathfinder_dark_lord_aura", "pathfinder/pathfinder_nevermore.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pathfinder_dark_lord_debuff", "pathfinder/pathfinder_nevermore.lua", LUA_MODIFIER_MOTION_NONE)

function pathfinder_nevermore_dark_lord:GetAbilityTextureName()
   return "nevermore_dark_lord"
end

function pathfinder_nevermore_dark_lord:GetIntrinsicModifierName()
	return "modifier_pathfinder_dark_lord_aura"
end

function pathfinder_nevermore_dark_lord:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("aura_radius")
end

function pathfinder_nevermore_dark_lord:GetBehavior()
	if self:GetCaster():HasModifier("modifier_nevermore_dark_lord_raze") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_TOGGLE + DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL
	end
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end



function pathfinder_nevermore_dark_lord:OnToggle()
end

-- Presence of the Dark Lord aura
modifier_nevermore_dark_lord_raze = modifier_nevermore_dark_lord_raze or class({})
function modifier_nevermore_dark_lord_raze:IsHidden() return true end

modifier_pathfinder_dark_lord_aura = modifier_pathfinder_dark_lord_aura or class({})
LinkLuaModifier("modifier_nevermore_dark_lord_raze", "pathfinder/pathfinder_nevermore.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_pathfinder_dark_lord_aura:OnCreated()
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()

	-- Ability specials
	self.aura_radius = self.ability:GetSpecialValueFor("aura_radius")


	-- Start thinking
	self:StartIntervalThink(1)
end

function modifier_pathfinder_dark_lord_aura:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_pathfinder_dark_lord_aura:OnAttack(keys)
	if not IsServer() or not self:GetAbility():GetCaster():HasAbility("pathfinder_nevermore_special_dark_lord_split_attack") then return end

	local special = self:GetCaster():FindAbilityByName("pathfinder_nevermore_special_dark_lord_split_attack") 
	
	if keys.attacker == self:GetParent() and keys.target and keys.target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and not keys.no_attack_cooldown and not self:GetParent():PassivesDisabled() and self:GetAbility():IsTrained() then	
		local enemies = FindRadius(self:GetCaster(), self:GetAbility():GetLevelSpecialValueFor("aura_radius", self:GetAbility():GetLevel() -1),true)
		
		local target_number = special:GetLevelSpecialValueFor("target_number", 1)			
		
		for _, enemy in pairs(enemies) do
			if enemy ~= keys.target then
				self.split_shot_target = true
				
				self:GetParent():PerformAttack(enemy, false, true, true, true, true, false, false)
				
				self.split_shot_target = false
				
				target_number = target_number - 1
				
				if target_number <= 0 then
					break
				end
			end
		end
	end
end

function modifier_pathfinder_dark_lord_aura:OnAttackLanded(keys)
	if IsServer() then		
		local attacker = keys.attacker
		local target = keys.target
		
		if self:GetParent() ~= attacker or self:GetParent() == target then
			return
		elseif self:GetParent():PassivesDisabled() then
			return
		end
		
		if IsServer() and attacker:HasAbility("pathfinder_nevermore_special_requiem_attack") and target:HasModifier("modifier_pathfinder_dark_lord_debuff") then
			print('addin stack')
			local special = attacker:FindAbilityByName("pathfinder_nevermore_special_requiem_attack")
			if not attacker:HasModifier("modifier_pathfinder_requiem_attack") then
				attacker:AddNewModifier(attacker, ability, "modifier_pathfinder_requiem_attack", {})
			end
			for i=1,special:GetLevelSpecialValueFor("stacks_per_hit",1) do			
				local mod = attacker:FindModifierByName("modifier_pathfinder_requiem_attack")
				if mod then
					mod:IncrementStackCount()			
					mod:ForceRefresh()
				end
			end
		end
	end
end

function modifier_pathfinder_dark_lord_aura:GetModifierDamageOutgoing_Percentage()
	if not IsServer() then return end
	local special = self:GetCaster():FindAbilityByName("pathfinder_nevermore_special_dark_lord_split_attack") 
	
	if self.split_shot_target then
		return -1 * special:GetLevelSpecialValueFor("damage_percent", 1)
	else
		return 0
	end
end

function modifier_pathfinder_dark_lord_aura:OnIntervalThink()	
	if IsServer() and not self:GetCaster():HasModifier("modifier_nevermore_dark_lord_raze") and self:GetCaster():HasAbility("pathfinder_nevermore_special_dark_lord_raze") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_nevermore_dark_lord_raze", {})
	end
	if IsServer() then		
		if self:GetCaster():HasAbility("pathfinder_nevermore_special_dark_lord_raze") then			
			if self:GetAbility():GetToggleState() then				
				if self:GetCaster():HasModifier("modifier_pathfinder_necromastery_souls") and self:GetCaster():FindModifierByName("modifier_pathfinder_necromastery_souls"):GetStackCount() >= self:GetCaster():FindAbilityByName("pathfinder_nevermore_special_dark_lord_raze"):GetLevelSpecialValueFor("soul_cost",1) and self:GetCaster():FindAbilityByName("pathfinder_nevermore_shadowraze_far"):GetLevel() > 0 then										
					local enemies = FindRadius(self:GetCaster(), self:GetAbility():GetLevelSpecialValueFor("aura_radius",1),true)
					if #enemies > 0 then
						EmitSoundOn("Hero_Nevermore.Shadowraze", self:GetCaster())
						RemoveNecromasterySouls(self:GetCaster(), self:GetCaster():FindAbilityByName("pathfinder_nevermore_special_dark_lord_raze"):GetLevelSpecialValueFor("soul_cost",1))
						CastShadowRazeOnPoint(self:GetCaster(), self:GetCaster():FindAbilityByName("pathfinder_nevermore_shadowraze_far"), enemies[1]:GetAbsOrigin(), self:GetCaster():FindAbilityByName("pathfinder_nevermore_shadowraze_far"):GetLevelSpecialValueFor("radius", self:GetCaster():FindAbilityByName("pathfinder_nevermore_shadowraze_far"):GetLevel() -1))						
					end
				else
					self:GetAbility():ToggleAbility()
				end			
			end
		end
	end
end

function modifier_pathfinder_dark_lord_aura:IsHidden() return true end
function modifier_pathfinder_dark_lord_aura:IsPurgable() return false end
function modifier_pathfinder_dark_lord_aura:IsDebuff() return false end

function modifier_pathfinder_dark_lord_aura:OnRefresh()
	self:OnCreated()
end

function modifier_pathfinder_dark_lord_aura:AllowIllusionDuplicate()
	return true
end


function modifier_pathfinder_dark_lord_aura:GetAuraRadius()
	return self.aura_radius
end


function modifier_pathfinder_dark_lord_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_pathfinder_dark_lord_aura:GetAuraSearchTeam()
	if self:GetAbility():GetCaster():HasAbility("pathfinder_nevermore_special_dark_lord_friendly") then
		return DOTA_UNIT_TARGET_TEAM_BOTH
	else
		return DOTA_UNIT_TARGET_TEAM_ENEMY
	end
end

function modifier_pathfinder_dark_lord_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_pathfinder_dark_lord_aura:GetModifierAura()
	return "modifier_pathfinder_dark_lord_debuff"
end

function modifier_pathfinder_dark_lord_aura:IsAura()
	-- If caster is broken, aura stops emitting itself
	if self.caster:PassivesDisabled() then
		return false
	end

	return true
end


-- Presence of the Dark Lord armor reduction debuff modifier
modifier_pathfinder_dark_lord_debuff = modifier_pathfinder_dark_lord_debuff or class({})

function modifier_pathfinder_dark_lord_debuff:OnCreated()
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()

	-- Ability specials
	self.armor_reduction = self.ability:GetSpecialValueFor("armor_reduction")
end


function modifier_pathfinder_dark_lord_debuff:IsHidden() return false end
function modifier_pathfinder_dark_lord_debuff:IsPurgable() return false end
function modifier_pathfinder_dark_lord_debuff:IsDebuff() return self:GetParent():GetTeamNumber() ~= DOTA_TEAM_GOODGUYS end

function modifier_pathfinder_dark_lord_debuff:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}

	return decFuncs
end

function modifier_pathfinder_dark_lord_debuff:GetModifierPhysicalArmorBonus()	
	local total_armor_reduction = self.armor_reduction

	if self:GetParent():GetTeamNumber() ~= DOTA_TEAM_GOODGUYS then
		return total_armor_reduction * (-1)
	else
		return total_armor_reduction
	end
end

function modifier_pathfinder_dark_lord_debuff:GetEffectName()	
	return "particles/units/heroes/hero_nevermore/nevermore_shadowraze_debuff_ground_embers.vpcf"
end

function modifier_pathfinder_dark_lord_debuff:GetEffectAttachType()	
	return PATTACH_ABSORIGIN_FOLLOW
end



-------------------
------
--
pathfinder_nevermore_requiem = pathfinder_nevermore_requiem or class({})
LinkLuaModifier("modifier_pathfinder_nevermore_requiem_phase", "pathfinder/pathfinder_nevermore.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pathfinder_nevermore_requiem_debuff", "pathfinder/pathfinder_nevermore.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pathfinder_requiem_attack", "pathfinder/pathfinder_nevermore.lua", LUA_MODIFIER_MOTION_NONE)

function pathfinder_nevermore_requiem:GetAbilityTextureName()
   return "nevermore_requiem"
end


function pathfinder_nevermore_requiem:GetAssociatedSecondaryAbilities()
	return "pathfinder_nevermore_necromastery"
end

function pathfinder_nevermore_requiem:OnAbilityPhaseStart()
    self.sound = "Hero_Nevermore.RequiemOfSoulsCast"
	-- Play sound
	self:GetCaster():EmitSound(self.sound)
	
	self.wings_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_wings.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())

	-- Start cast animation
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_6)

	-- Caster becomes phased while casting
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pathfinder_nevermore_requiem_phase", {})

	return true
end

function pathfinder_nevermore_requiem:OnAbilityPhaseInterrupted()
	-- Stop cast animation
	self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_6)

	-- Remove phased movement from caster
	self:GetCaster():RemoveModifierByName("modifier_pathfinder_nevermore_requiem_phase")
	
	self:GetCaster():StopSound(self.sound)
	
	if self.wings_particle then
		ParticleManager:DestroyParticle(self.wings_particle, true)
		ParticleManager:ReleaseParticleIndex(self.wings_particle)
	end
end

function pathfinder_nevermore_requiem:OnSpellStart(death_cast)	
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	
	local sound_cast = "Hero_Nevermore.RequiemOfSouls"
	local particle_caster_souls = "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_a.vpcf"
	local particle_caster_ground = "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf"
	local modifier_phase = "modifier_pathfinder_nevermore_requiem_phase"
	local modifier_souls = "modifier_pathfinder_necromastery_souls"


	local souls_per_line = ability:GetSpecialValueFor("souls_per_line")
	local travel_distance = ability:GetSpecialValueFor("travel_distance")

	-- Play cast sound
	EmitSoundOn(sound_cast, caster)

	if self.wings_particle then
		ParticleManager:ReleaseParticleIndex(self.wings_particle)
	end

	-- Remove phased movement from caster
	caster:RemoveModifierByName(modifier_phase)

	-- Add particles for the caster and the ground
	local particle_caster_souls_fx = ParticleManager:CreateParticle(particle_caster_souls, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_caster_souls_fx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_caster_souls_fx, 1, Vector(lines, 0, 0))
	ParticleManager:SetParticleControl(particle_caster_souls_fx, 2, caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_caster_souls_fx)

	local particle_caster_ground_fx = ParticleManager:CreateParticle(particle_caster_ground, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_caster_ground_fx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_caster_ground_fx, 1, Vector(lines, 0, 0))
	ParticleManager:ReleaseParticleIndex(particle_caster_ground_fx)

	-- Find the Necromastery modifier, its stack count and the ability that used it
	local modifier_souls_handler
	local stacks
	local necro_ability
	local max_souls

	if caster:HasModifier(modifier_souls) then
		modifier_souls_handler = caster:FindModifierByName(modifier_souls)
		if modifier_souls_handler then
			stacks = modifier_souls_handler:GetStackCount()
			necro_ability = modifier_souls_handler:GetAbility()
		max_souls = modifier_souls_handler.max_souls
		end
	end

	-- If the modifier was not found, Requiem fails (no souls to release).
	if not modifier_souls_handler then
		return nil
	end

	-- Talent: Maximum Necromastery soul increase (REMOVED)
	-- max_souls = max_souls + caster:FindTalentValue("special_bonus_imba_nevermore_6")

	local line_count
	line_count = math.floor(stacks / souls_per_line)



	-- Calculate the first line location, in front of the caster
	local line_position = caster:GetAbsOrigin() + caster:GetForwardVector() * travel_distance

	if stacks >= 1 then
		-- Create the first line
		CreateRequiemSoulLine(caster, ability, caster, line_position, death_cast)
	end

	-- Calculate the location of every other line
	local qangle_rotation_rate = 360 / line_count
	for i = 1, line_count - 1 do
		local qangle = QAngle(0, qangle_rotation_rate, 0)
		line_position = RotatePosition(caster:GetAbsOrigin(), qangle, line_position)

		-- Create every other line
		CreateRequiemSoulLine(caster, ability, caster, line_position, death_cast)
	end
end

function pathfinder_nevermore_requiem:OnProjectileHit_ExtraData(target, location, extra_data)
	-- If there was no target, do nothing
	if not target then
		return nil
	end

	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local modifier_debuff = "modifier_pathfinder_nevermore_requiem_debuff"
	local death_cast = extra_data.death_cast

	-- Ability specials
	local damage = ability:GetSpecialValueFor("damage")	
	local slow_duration = ability:GetSpecialValueFor("slow_duration")


	-- Apply the debuff on enemies hit
	target:AddNewModifier(caster, ability, modifier_debuff, {duration = slow_duration * (1 - target:GetStatusResistance())})

	
	target:EmitSound("Hero_Nevermore.RequiemOfSouls.Damage")
	
	-- Damage the target
	local damageTable = {victim = target,
						damage = damage,
						damage_type = DAMAGE_TYPE_MAGICAL,
						attacker = caster,
						ability = ability
						}

	local damage_dealt = ApplyDamage(damageTable)

	-- F.E.A.R.	
	if not death_cast and target.bAbsoluteNoCC ~= true then
		local max_time = self:GetLevelSpecialValueFor("requiem_slow_duration_max", self:GetLevel() - 1)
		if not target:HasModifier("modifier_nevermore_requiem_fear") then
			target:AddNewModifier(self:GetCaster(), self, "modifier_nevermore_requiem_fear", {duration = math.min(self:GetSpecialValueFor("requiem_slow_duration") * (1 - target:GetStatusResistance()), max_time)})
		else
			target:FindModifierByName("modifier_nevermore_requiem_fear"):SetDuration( math.min(max_time, target:FindModifierByName("modifier_nevermore_requiem_fear"):GetRemainingTime() + self:GetSpecialValueFor("requiem_slow_duration") * (1 - target:GetStatusResistance())), true)
		end

		if caster:HasAbility("pathfinder_nevermore_special_requiem_sleep") then
			Timers:CreateTimer(self:GetSpecialValueFor("requiem_slow_duration") * (1 - target:GetStatusResistance()), function()
				local special = caster:FindAbilityByName("pathfinder_nevermore_special_requiem_sleep")
				target:AddNewModifier(caster, self, "modifier_elder_titan_echo_stomp", {duration = special:GetLevelSpecialValueFor("duration",1)})
			end)
		end
	end
end

function CreateRequiemSoulLine(caster, ability, source_unit, line_end_position, death_cast)
	-- Ability properties
	local particle_lines = "particles/nevermore_requiemofsouls_line_copy.vpcf"

	-- Ability specials
	local travel_distance = ability:GetSpecialValueFor("travel_distance")
	local lines_starting_width = ability:GetSpecialValueFor("lines_starting_width")
	local lines_end_width = ability:GetSpecialValueFor("lines_end_width")
	local travel_distance = ability:GetSpecialValueFor("travel_distance")
	local lines_travel_speed = ability:GetSpecialValueFor("lines_travel_speed")

	-- Calculate the time that it would take to reach the maximum distance
	local max_distance_time = travel_distance / lines_travel_speed

	-- Calculate velocity
	local velocity = (line_end_position - source_unit:GetAbsOrigin()):Normalized() * lines_travel_speed

		

	-- Launch the line
	projectile_info = {Ability = ability,
					   EffectName = particle_lines,
					   vSpawnOrigin = caster:GetAbsOrigin(),
					   fDistance = travel_distance,
					   fStartRadius = lines_starting_width,
					   fEndRadius = lines_end_width,
					   Source = source_unit,
					   bHasFrontalCone = false,
					   bReplaceExisting = false,
					   iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
					   iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
					   iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					   bDeleteOnHit = false,
					   vVelocity = velocity,
					   bProvidesVision = false,
					   ExtraData = {scepter_line = false, death_cast = death_cast}
					   }

	-- Create the projectile
	ProjectileManager:CreateLinearProjectile(projectile_info)

	-- Create the particle
	local particle_lines_fx = ParticleManager:CreateParticle(particle_lines, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_lines_fx, 0, source_unit:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_lines_fx, 1, velocity)
	ParticleManager:SetParticleControl(particle_lines_fx, 2, Vector(0, max_distance_time, 0))
	ParticleManager:ReleaseParticleIndex(particle_lines_fx)

end


-- Requiem of Souls caster phased modifier
modifier_pathfinder_nevermore_requiem_phase = modifier_pathfinder_nevermore_requiem_phase or class({})

function modifier_pathfinder_nevermore_requiem_phase:CheckState()
	local state = {[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	return state
end

function modifier_pathfinder_nevermore_requiem_phase:IsHidden() return true end
function modifier_pathfinder_nevermore_requiem_phase:IsPurgable() return false end
function modifier_pathfinder_nevermore_requiem_phase:IsDebuff() return false end



-- Requiem of Souls slow debuff
modifier_pathfinder_nevermore_requiem_debuff = modifier_pathfinder_nevermore_requiem_debuff or class({})

function modifier_pathfinder_nevermore_requiem_debuff:OnCreated()
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	self.duration = self:GetDuration()

	self.ms_slow_pct = self.ability:GetSpecialValueFor("ms_slow_pct") * (-1)

end

function modifier_pathfinder_nevermore_requiem_debuff:IsHidden() return false end
function modifier_pathfinder_nevermore_requiem_debuff:IsPurgable() return true end
function modifier_pathfinder_nevermore_requiem_debuff:IsDebuff() return true end

function modifier_pathfinder_nevermore_requiem_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_pathfinder_nevermore_requiem_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_slow_pct
end

modifier_pathfinder_requiem_attack = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_requiem_attack:IsHidden()
	return false
end

function modifier_pathfinder_requiem_attack:IsDebuff()
	return false
end

function modifier_pathfinder_requiem_attack:GetTexture()
	return "nevermore_requiem"
end

function modifier_pathfinder_requiem_attack:OnRefresh()
	if not IsServer() then return end
	local req = self:GetParent():FindAbilityByName("pathfinder_nevermore_requiem")
	local special = self:GetParent():FindAbilityByName("pathfinder_nevermore_special_requiem_attack")
	if req and special and req:GetLevel() > 0 and self:GetStackCount() > special:GetLevelSpecialValueFor("trigger_threshold",1) then
		req:OnSpellStart()
		self:SetStackCount(0)
	end
end


--------------------------------------------------------------------------------
-- function modifier_pathfinder_requiem_attack:DeclareFunctions()
--     local funcs_array = {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT   }
--     return funcs_array
-- end



-- function modifier_pathfinder_requiem_attack:GetModifierAttackSpeedBonus_Constant()	
--     return self:GetStackCount()
-- end








pathfinder_nevermore_special_requiem_soul_projectile = pathfinder_nevermore_special_requiem_soul_projectile or class({})
LinkLuaModifier("modifier_pathfinder_nevermore_requiem_debuff", "pathfinder/pathfinder_nevermore.lua", LUA_MODIFIER_MOTION_NONE)

function pathfinder_nevermore_special_requiem_soul_projectile:OnSpellStart()
	-- Ability properties
	local particle_lines = "particles/nevermore_requiemofsouls_line_copy.vpcf"
	local ability = self:GetCaster():FindAbilityByName("pathfinder_nevermore_requiem")

	local caster = self:GetCaster()
	if not caster or not ability or ability:GetLevel() < 1 then
		return
	end
	
	local source_unit = self:GetCaster():GetCursorCastTarget()

	-- Ability specials
	local travel_distance = ability:GetSpecialValueFor("travel_distance")
	local lines_starting_width = 200
	local lines_end_width = 200
	local travel_distance = ability:GetSpecialValueFor("travel_distance")
	local lines_travel_speed = ability:GetSpecialValueFor("lines_travel_speed")

	-- Calculate the time that it would take to reach the maximum distance
	local max_distance_time = travel_distance / lines_travel_speed

	-- Calculate velocity
	-- local velocity = (caster:GetAbsOrigin() - source_unit:GetAbsOrigin()):Normalized() * lines_travel_speed

	local line_end_position = source_unit:GetAbsOrigin() + caster:GetForwardVector() * travel_distance
	local velocity = (line_end_position - source_unit:GetAbsOrigin()):Normalized() * lines_travel_speed

	-- Launch the line
	projectile_info = {Ability = self,
					   EffectName = particle_lines,
					   vSpawnOrigin = caster:GetAbsOrigin(),
					   fDistance = travel_distance,
					   fStartRadius = lines_starting_width,
					   fEndRadius = lines_end_width,
					   Source = source_unit,
					   bHasFrontalCone = false,
					   bReplaceExisting = false,
					   iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
					   iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
					   iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					   bDeleteOnHit = false,
					   vVelocity = velocity,
					   bProvidesVision = false,			
					   }

	-- Create the projectile
	ProjectileManager:CreateLinearProjectile(projectile_info)

	-- Create the particle
	local particle_lines_fx = ParticleManager:CreateParticle(particle_lines, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_lines_fx, 0, source_unit:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_lines_fx, 1, velocity)
	ParticleManager:SetParticleControl(particle_lines_fx, 2, Vector(0, max_distance_time, 0))
	ParticleManager:ReleaseParticleIndex(particle_lines_fx)

end

function pathfinder_nevermore_special_requiem_soul_projectile:OnProjectileHit_ExtraData(target, location)	
	local req = self:GetCaster():FindAbilityByName("pathfinder_nevermore_requiem")
	local caster = self:GetCaster()

	if not caster or not target or not (caster:HasAbility("pathfinder_nevermore_special_requiem_soul_projectile") and req and req:GetLevel() > 0) then	
	-- If there was no target, do nothing
		return nil
	end

	
	-- Ability properties	
	local ability = req
	local modifier_debuff = "modifier_pathfinder_nevermore_requiem_debuff"

	-- Ability specials
	local damage = ability:GetSpecialValueFor("damage")

	-- print(damage)
	local slow_duration = ability:GetSpecialValueFor("slow_duration")


	-- Apply the debuff on enemies hit
	target:AddNewModifier(caster, ability, modifier_debuff, {duration = slow_duration * (1 - target:GetStatusResistance())})

	
	target:EmitSound("Hero_Nevermore.RequiemOfSouls.Damage")
	
	-- Damage the target
	local damageTable = {victim = target,
						damage = damage,
						damage_type = DAMAGE_TYPE_MAGICAL,
						attacker = caster,
						ability = ability
						}

	local damage_dealt = ApplyDamage(damageTable)	

	if not target:HasModifier("modifier_absolute_no_cc") then
		-- if not target:HasModifier("modifier_nevermore_requiem_fear") then
		-- 	target:AddNewModifier(self:GetCaster(), self, "modifier_nevermore_requiem_fear", {duration = self:GetSpecialValueFor("requiem_slow_duration") * (1 - target:GetStatusResistance())})
		-- else
		-- 	target:FindModifierByName("modifier_nevermore_requiem_fear"):SetDuration(target:FindModifierByName("modifier_nevermore_requiem_fear"):GetRemainingTime() + self:GetSpecialValueFor("requiem_slow_duration") * (1 - target:GetStatusResistance()), true)
		-- end

		if caster:HasAbility("pathfinder_nevermore_special_requiem_sleep") then
			Timers:CreateTimer(self:GetSpecialValueFor("requiem_slow_duration") * (1 - target:GetStatusResistance()), function()
				local special = caster:FindAbilityByName("pathfinder_nevermore_special_requiem_sleep")
				target:AddNewModifier(caster, self, "modifier_elder_titan_echo_stomp", {duration = special:GetLevelSpecialValueFor("duration",1)})
			end)
		end
	end
end