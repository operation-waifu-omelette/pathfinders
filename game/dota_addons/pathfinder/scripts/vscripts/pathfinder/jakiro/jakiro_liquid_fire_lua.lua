jakiro_liquid_fire_lua = class({
	GetIntrinsicModifierName = function(self) return "modifier_imba_liquid_fire_caster" end
})
LinkLuaModifier("modifier_imba_liquid_fire_caster", "pathfinder/jakiro/jakiro_liquid_fire_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_liquid_fire_animate", "pathfinder/jakiro/jakiro_liquid_fire_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jakiro_liquid_fire_lua", "pathfinder/jakiro/modifier_jakiro_liquid_fire_lua", LUA_MODIFIER_MOTION_NONE)

function jakiro_liquid_fire_lua:GetAOERadius()
	return self:GetLevelSpecialValueFor("radius", self:GetLevel())
end

function jakiro_liquid_fire_lua:GetCastRange(vLocation, hTarget)
	return self:GetCaster():GetCastRangeBonus() +  self:GetCaster():Script_GetAttackRange()--self:GetLevelSpecialValueFor("range", self:GetLevel())
end

function jakiro_liquid_fire_lua:CastFilterResultTarget(target)
	if target:GetTeamNumber() == self:GetCaster():GetTeamNumber() and self:GetCaster():HasModifier("pathfinder_jakiro_liquid_fire_allies_checker") then
		return UF_SUCCESS
	elseif target:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		return UF_SUCCESS
	end
	return UF_FAIL_OTHER
end

function jakiro_liquid_fire_lua:GetAbilityTargetTeam()
	if self:GetCaster():HasModifier("pathfinder_jakiro_liquid_fire_allies_checker") then
		return DOTA_UNIT_TARGET_TEAM_BOTH
	end	
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end



function jakiro_liquid_fire_lua:GetAbilityTextureName()
	return "jakiro_liquid_fire"
end

function jakiro_liquid_fire_lua:OnCreated()
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	--cast_liquid_fire used as indicator to apply liquid fire to next attack
	self.cast_liquid_fire = false	
end

function jakiro_liquid_fire_lua:OnAbilityPhaseStart()
	local caster = self:GetCaster()	
	-- Special animation for jakiro
	if caster:GetUnitName() == "npc_dota_hero_jakiro" then
		caster:AddNewModifier(caster, self.ability, "modifier_imba_liquid_fire_animate", {})
		caster:StartGesture(ACT_DOTA_ATTACK)	
	end

	-- Needs to return true for successful cast
	return true
end

function jakiro_liquid_fire_lua:OnAbilityPhaseInterrupted()
	local caster = self:GetCaster()
	caster:RemoveModifierByNameAndCaster("modifier_imba_liquid_fire_animate", caster)
end

function jakiro_liquid_fire_lua:OnSpellStart()
	if IsServer() then
		local target = self:GetCursorTarget()
		local caster = self:GetCaster()

		self.cast_liquid_fire = true

		caster:SetRangedProjectileName("particles/units/heroes/hero_jakiro/jakiro_base_attack_fire.vpcf")

		-- Attack the main target
		if target:GetTeamNumber() == caster:GetTeamNumber() then
			caster:PerformAttack(target, true, true, true, true, true, true, true)
		else
			caster:PerformAttack(target, true, true, true, true, true, false, false)
		end
	end
end

pathfinder_jakiro_liquid_fire_allies_checker = class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,
	RemoveOnDeath 			= function(self) return false end,
	AllowIllusionDuplicate	= function(self) return false end
})

modifier_imba_liquid_fire_caster = class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,
	RemoveOnDeath 			= function(self) return false end,
	AllowIllusionDuplicate	= function(self) return false end
})
LinkLuaModifier("pathfinder_jakiro_liquid_fire_allies_checker", "pathfinder/jakiro/jakiro_liquid_fire_lua", LUA_MODIFIER_MOTION_NONE)


function modifier_imba_liquid_fire_caster:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ORDER
	}

	return funcs
end

function modifier_imba_liquid_fire_caster:OnIntervalThink()
	if IsServer() and self:GetParent():HasAbility("pathfinder_jakiro_liquid_fire_allies") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "pathfinder_jakiro_liquid_fire_allies_checker", {})
	end
end

function modifier_imba_liquid_fire_caster:OnCreated()

	self.parent = self:GetParent()
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	-- apply_aoe_modifier_debuff_on_hit used as indicator to apply AOE modifier on target hit
	-- { target(key) : times_to_apply_liquid_fire_on_attack_lands (value)}
	-- This is done to allow attacking with liquid fire on correct targets if refresher orb is used
	self.apply_aoe_modifier_debuff_on_hit = {}
	self:StartIntervalThink(1.5)
end

function modifier_imba_liquid_fire_caster:_IsLiquidFireProjectile()
	local caster = self.caster
	return caster:GetRangedProjectileName() == "particles/units/heroes/hero_jakiro/jakiro_base_attack_fire.vpcf"
end

function modifier_imba_liquid_fire_caster:OnAttackStart(keys)
	if IsServer() then
		local caster = self.caster
		local ability = self.ability
		local target = keys.target
		local attacker = keys.attacker

		if caster == attacker then
			if not ability:IsHidden() and not target:IsMagicImmune() and ability:GetAutoCastState() and ability:IsCooldownReady() then

				-- Special animation for jakiro
				if caster:GetUnitName() == "npc_dota_hero_jakiro" then
					caster:AddNewModifier(caster, self.ability, "modifier_imba_liquid_fire_animate", {})
				end

				-- Change projectile
				caster:SetRangedProjectileName("particles/units/heroes/hero_jakiro/jakiro_base_attack_fire.vpcf")
			elseif self:_IsLiquidFireProjectile() then
				-- Revert projectile
				caster:SetRangedProjectileName("particles/units/heroes/hero_jakiro/jakiro_base_attack.vpcf")
			end
		end
	end
end

function modifier_imba_liquid_fire_caster:OnAttack(keys)
	if IsServer() then
		local caster = self.caster
		local target = keys.target
		local attacker = keys.attacker
		local ability = self.ability

		if caster == attacker and (self:_IsLiquidFireProjectile() or ability.cast_liquid_fire) then

			-- Remove manual cast indicator
			ability.cast_liquid_fire = false

			-- Apply modifier on next hit
			if self.apply_aoe_modifier_debuff_on_hit[target] == nil then
				self.apply_aoe_modifier_debuff_on_hit[target] = 1;
			else
				self.apply_aoe_modifier_debuff_on_hit[target] = self.apply_aoe_modifier_debuff_on_hit[target] + 1;
			end

			-- Start cooldown
			ability:UseResources(false, false, true)
		end
	end
end

function modifier_imba_liquid_fire_caster:_ApplyAOELiquidFire( keys )


	if IsServer() then

		local caster = self.caster
		local attacker = keys.attacker
		local target = keys.target
		local target_liquid_fire_counter = self.apply_aoe_modifier_debuff_on_hit[target]

		if caster == attacker and target_liquid_fire_counter and target_liquid_fire_counter > 0 then
			self.apply_aoe_modifier_debuff_on_hit[target] = target_liquid_fire_counter - 1;
			-- Remove key reference
			if self.apply_aoe_modifier_debuff_on_hit[target] == 0 then
				self.apply_aoe_modifier_debuff_on_hit[target] = nil
			end

			local ability = self.ability

			local ability_level = ability:GetLevel() - 1
			local particle_liquid_fire = "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf"
			local modifier_liquid_fire_debuff = "modifier_jakiro_liquid_fire_lua"
			local duration = ability:GetLevelSpecialValueFor("duration", ability_level)

			-- Parameters
			local radius = ability:GetLevelSpecialValueFor("radius", ability_level)

			-- Play sound
			target:EmitSound("Hero_Jakiro.LiquidFire")

			-- Play explosion particle
			local fire_pfx = ParticleManager:CreateParticle( particle_liquid_fire, PATTACH_ABSORIGIN, target )
			ParticleManager:SetParticleControl( fire_pfx, 0, target:GetAbsOrigin() + Vector(0,0,50))
			ParticleManager:SetParticleControl( fire_pfx, 1, Vector( radius, radius, radius ) )
			-- ParticleManager:SetParticleControl( fire_pfx, 1, Vector(radius * 2,0,0) )
			ParticleManager:ReleaseParticleIndex( fire_pfx )

			-- Apply liquid fire modifier to enemies in the area
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _,enemy in pairs(enemies) do
				enemy:AddNewModifier(caster, ability, modifier_liquid_fire_debuff, { duration = duration * (1 - enemy:GetStatusResistance())})
			end
		end
	end
end

function modifier_imba_liquid_fire_caster:OnAttackLanded( keys )	
	self:_ApplyAOELiquidFire(keys)
end

function modifier_imba_liquid_fire_caster:OnAttackFail( keys )
	self:_ApplyAOELiquidFire(keys)
end

function modifier_imba_liquid_fire_caster:OnOrder(keys)
	local order_type = keys.order_type

	-- On any order apart from attacking target, clear the cast_liquid_fire variable.
	if order_type ~= DOTA_UNIT_ORDER_ATTACK_TARGET then
		self.ability.cast_liquid_fire = false
	end
end

-- Modifier to play animation for jakiro's other head
modifier_imba_liquid_fire_animate = class({
	IsHidden					    = function(self) return true end,
	IsPurgable						= function(self) return false end,
	IsDebuff						= function(self) return false end,
	RemoveOnDeath					= function(self) return true end,
	GetActivityTranslationModifiers	= function(self) return "liquid_fire" end
})

function modifier_imba_liquid_fire_animate:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_EVENT_ON_ATTACK
	}

	return funcs
end

function modifier_imba_liquid_fire_animate:OnAttack(keys)
	if IsServer() then
		local attacker = keys.attacker

		if attacker == self:GetCaster() then
			self:Destroy()
		end
	end
end

function jakiro_liquid_fire_lua:OnProjectileHit_ExtraData( hTarget, vLocation, extraData )
	if IsServer() then		
		hTarget:EmitSound("Hero_Jakiro.LiquidFire")
		local radius = self:GetLevelSpecialValueFor("radius", self:GetLevel() - 1)
		local duration = self:GetLevelSpecialValueFor("duration", self:GetLevel() - 1)

		local particle_liquid_fire = "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf"
		local fire_pfx = ParticleManager:CreateParticle( particle_liquid_fire, PATTACH_ABSORIGIN, hTarget )
		ParticleManager:SetParticleControl( fire_pfx, 0, hTarget:GetAbsOrigin() + Vector(0,0,50))
		ParticleManager:SetParticleControl( fire_pfx, 1, Vector( radius, radius, radius ) )		
		ParticleManager:ReleaseParticleIndex( fire_pfx )

		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), hTarget:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _,enemy in pairs(enemies) do
			enemy:AddNewModifier(self:GetCaster(), self, "modifier_jakiro_liquid_fire_lua", { duration = duration * (1 - enemy:GetStatusResistance())})
		end
	end

	return true
end
