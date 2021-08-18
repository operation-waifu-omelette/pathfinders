LinkLuaModifier( "modifier_pathfinder_juggernaut_omni_slash", "pathfinder/pathfinder_juggernaut_omni_slash", LUA_MODIFIER_MOTION_NONE )

pathfinder_juggernaut_omni_slash = class({})

--------------------------------------------------------------------------------
-- Ability Start
function pathfinder_juggernaut_omni_slash:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local bDuration = self:GetSpecialValueFor("duration")	

	-- Add modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_pathfinder_juggernaut_omni_slash", -- modifier name
		{ duration = bDuration } -- kv
	)	

	if caster:HasModifier("modifier_pathfinder_juggernaut_blade_fury") then
		caster:RemoveModifierByName("modifier_pathfinder_juggernaut_blade_fury")
	end
end

modifier_pathfinder_juggernaut_omni_slash = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_juggernaut_omni_slash:IsHidden()
	return false
end

function modifier_pathfinder_juggernaut_omni_slash:IsDebuff()
	return false
end

function modifier_pathfinder_juggernaut_omni_slash:IsPurgable()
	return false
end

function modifier_pathfinder_juggernaut_omni_slash:DestroyOnExpire()
	return false
end

function modifier_pathfinder_juggernaut_omni_slash:GetStatusEffectName()
	return "particles/status_fx/status_effect_omnislash.vpcf"
end
--------------------------------------------------------------------------------

-- Initializations
function modifier_pathfinder_juggernaut_omni_slash:OnCreated( kv )
	-- references

	local slash_rate_divisor = self:GetAbility():GetLevelSpecialValueFor( "slash_rate_divisor", self:GetAbility():GetLevel() - 1 )
	local damage_bonus = self:GetAbility():GetLevelSpecialValueFor( "damage_bonus", self:GetAbility():GetLevel() - 1 )
	local attack_speed_bonus = self:GetAbility():GetLevelSpecialValueFor( "attack_speed_bonus", self:GetAbility():GetLevel() - 1 )

	self.tick = 1 / self:GetCaster():GetAttacksPerSecond() / slash_rate_divisor - 1 / attack_speed_bonus
	self.radius = self:GetAbility():GetLevelSpecialValueFor( "bounce_radius", self:GetAbility():GetLevel() - 1  ) -- special value
	self.dps = damage_bonus
	
	self.max_count = kv.duration/self.tick
	self.count = 0

	-- Start interval
	if IsServer() then
		-- precache damagetable
		self.damageTable = {
			-- victim = target,
			attacker = self:GetParent(),
			damage = self.dps,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			ability = self:GetAbility(), --Optional.
		}

		self:StartIntervalThink( self.tick )
	end
end

function modifier_pathfinder_juggernaut_omni_slash:OnRefresh( kv )
	-- references
	local slash_rate_divisor = self:GetAbility():GetLevelSpecialValueFor( "slash_rate_divisor", self:GetAbility():GetLevel() - 1 )
	local damage_bonus = self:GetAbility():GetLevelSpecialValueFor( "damage_bonus", self:GetAbility():GetLevel() - 1 )
	local attack_speed_bonus = self:GetAbility():GetLevelSpecialValueFor( "attack_speed_bonus", self:GetAbility():GetLevel() - 1 )

	self.tick = 1 / self:GetCaster():GetAttacksPerSecond() / slash_rate_divisor - 1 / attack_speed_bonus
	self.radius = self:GetAbility():GetLevelSpecialValueFor( "bounce_radius", self:GetAbility():GetLevel() - 1  ) -- special value
	self.dps = damage_bonus
	self.count = 0

	if IsServer() then
		self.damageTable.damage = self.dps * self.tick
	end
end

function modifier_pathfinder_juggernaut_omni_slash:OnDestroy( kv )
	-- Stop effects
	local sound_cast = "Hero_Juggernaut.OmniSlash"
	StopSoundOn( sound_cast, self:GetParent() )
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_phased", {duration = 2})
	end
end

function modifier_pathfinder_juggernaut_omni_slash:CheckState()
	local state = {[MODIFIER_STATE_INVULNERABLE] = true,
				[MODIFIER_STATE_UNSELECTABLE] = true,
				[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
				[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
				[MODIFIER_STATE_NO_HEALTH_BAR] = true,
				[MODIFIER_STATE_FLYING] = false,
				[MODIFIER_STATE_NO_TEAM_MOVE_TO] = true,
				[MODIFIER_STATE_NO_TEAM_SELECT] = true,
				[MODIFIER_STATE_DISARMED] = true,}

	return state
end

function modifier_pathfinder_juggernaut_omni_slash:OnIntervalThink()
	-- Find enemies in radius
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
	
	if IsServer() then

		-- damage enemies
		for _,enemy in pairs(enemies) do  
			local caster = self:GetCaster();
			local direction = enemy:GetForwardVector()

			local prev_pos = caster:GetAbsOrigin()      
			self.damageTable.victim = enemy
			self:GetCaster():PerformAttack(enemy, true, true, true, true, false, false, false)
			ApplyDamage( self.damageTable )
			FindClearSpaceForUnit(caster, enemy:GetAbsOrigin(), true)
			caster:SetForwardVector( direction )
			
			local current_pos = caster:GetAbsOrigin()      
			
			local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_tgt.vpcf", PATTACH_POINT_FOLLOW, enemy)
			ParticleManager:SetParticleControl(effect, 0, enemy:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex( effect )			

			local effect2 = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
			ParticleManager:SetParticleControl(effect2, 0, prev_pos)
			ParticleManager:SetParticleControl(effect2, 1, current_pos)
			ParticleManager:ReleaseParticleIndex( effect2 )
			EmitSoundOn("Hero_Juggernaut.OmniSlash", caster)
			EmitSoundOn("Hero_Juggernaut.OmniSlash.Damage", caster)		

			
			if caster:HasAbility("pathfinder_special_juggernaut_omni_tiny_slash") and RandomInt(1,100) < caster:FindAbilityByName("pathfinder_special_juggernaut_omni_tiny_slash"):GetSpecialValueFor("spawn_chance") then
			
				
				local omni = CreateUnitByName("pathfinder_omni_tiny", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeam()) 	
				omni:SetBaseDamageMin(caster:GetBaseDamageMin() * (caster:FindAbilityByName("pathfinder_special_juggernaut_omni_tiny_slash"):GetSpecialValueFor("damage_percent")/100))
				omni:SetBaseDamageMax(caster:GetBaseDamageMax() * (caster:FindAbilityByName("pathfinder_special_juggernaut_omni_tiny_slash"):GetSpecialValueFor("damage_percent")/100))
				omni:AddNewModifier(omni, nil, "modifier_kill", {duration = caster:FindAbilityByName("pathfinder_special_juggernaut_omni_tiny_slash"):GetSpecialValueFor("duration")})	
			end

			break        
		end
	end
    
    if ( not self.damageTable.victim or self.damageTable.victim:IsNull()) or #enemies < 1 then
		self:Destroy()
	end

	-- counter
	self.count = self.count+1
	if self.count>= self.max_count then
		self:Destroy()
	end
end

function modifier_pathfinder_juggernaut_omni_slash:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_pathfinder_juggernaut_omni_slash:GetOverrideAnimation( params )
	return ACT_DOTA_OVERRIDE_ABILITY_4
end

function modifier_pathfinder_juggernaut_omni_slash:GetStatusEffectName()
	return "particles/status_fx/status_effect_omnislash.vpcf"
end