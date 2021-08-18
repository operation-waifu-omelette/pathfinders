modifier_axe_counter_helix_lua = class({})
LinkLuaModifier( "modifier_axe_counter_helix_special_fury_checker", "pathfinder/axe/modifier_axe_counter_helix_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_axe_counter_helix_aura", "pathfinder/axe/axe_counter_helix_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_axe_counter_helix_special_reduce_damage", "pathfinder/axe/modifier_axe_counter_helix_lua", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
-- Classifications
function modifier_axe_counter_helix_lua:IsHidden()
	return true
end

function modifier_axe_counter_helix_lua:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_axe_counter_helix_lua:OnCreated( kv )
	-- references
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.chance = self:GetAbility():GetSpecialValueFor( "trigger_chance" )

	if IsServer() then
		-- self.damage = self:GetAbility():GetLevelSpecialValueFor( "damage", self:GetAbility():GetLevel() )		


		-- precache damage
		
		-- ApplyDamage(damageTable)
	end
	self:StartIntervalThink(1.5)
end



-- function modifier_axe_counter_helix_lua:OnRefresh( kv )
-- 	if IsServer() then
-- 		self.damage =  self:GetAbility():GetLevelSpecialValueFor( "damage", self:GetAbility():GetLevel() - 1 )		

-- 		self.damageTable.damage = self.damage
-- 	end
-- end

function modifier_axe_counter_helix_lua:OnIntervalThink()
	if IsServer() and self:GetCaster():HasAbility("pathfinder_axe_special_counter_helix_fury") and not self:GetCaster():HasModifier("modifier_axe_counter_helix_special_fury") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_axe_counter_helix_special_fury_checker", {})
	end

	if IsServer() and self:GetCaster():HasAbility("pathfinder_axe_special_berseker_call_blink") and not self:GetCaster():HasModifier("modifier_axe_berserkers_call_lua_blink_checker") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_axe_berserkers_call_lua_blink_checker", {})
	end

	if IsServer() and self:GetCaster():HasAbility("pathfinder_axe_special_counter_helix_allies") and not self:GetCaster():HasModifier("modifier_axe_counter_helix_aura") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_axe_counter_helix_aura", {})
	end
end

function modifier_axe_counter_helix_lua:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_axe_counter_helix_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end

function modifier_axe_counter_helix_lua:OnAttackLanded( params )	
	if IsServer() and self:GetAbility():IsCooldownReady() then
		if self:GetCaster():PassivesDisabled() then return end

		if self:GetParent():HasAbility("special_bonus_unique_counter_helix_attack") then
			if params.target~=self:GetParent() then return end		
			if params.attacker:GetTeamNumber()==params.target:GetTeamNumber() then return end
		end
		
		if params.attacker:IsOther() or params.attacker:IsBuilding() then return end

		-- roll dice
		if RandomInt(1,100)>self.chance then return end

		-- find enemies
		local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			self:GetParent():GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		-- damage
		for _,enemy in pairs(enemies) do
			self.damageTable = {
				victim = enemy,
				attacker = self:GetParent(),
				damage = self:GetAbility():GetLevelSpecialValueFor( "damage", self:GetAbility():GetLevel() - 1 ),
				damage_type = DAMAGE_TYPE_PURE,
				ability = self:GetAbility(), --Optional.
				damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
			}
			ApplyDamage( self.damageTable )			
			
			if self:GetCaster():HasAbility("pathfinder_axe_special_counter_helix_reduce_damage") then
				local special = self:GetCaster():FindAbilityByName("pathfinder_axe_special_counter_helix_reduce_damage")
				if special then
					enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_axe_counter_helix_special_reduce_damage", {duration =special:GetLevelSpecialValueFor("duration",1)})
				end
			end
		end

		-- cooldown
		if self:GetParent():GetUnitName()  == "npc_dota_hero_axe" then
			self:GetAbility():UseResources( false, false, true )
		end

		-- effects
		self:PlayEffects()
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_axe_counter_helix_lua:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_axe/axe_attack_blur_counterhelix.vpcf"		
	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
		
	local sound_cast = "Hero_Axe.CounterHelix"

	if self:GetParent():GetUnitName() == "npc_dota_hero_axe" then
		self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_3)
	end

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetParent() )
end


function modifier_axe_counter_helix_lua:GetEffectName()
	if self:GetParent():GetUnitName() ~= "npc_dota_hero_axe" then
		return "particles/units/heroes/hero_axe/axe_beserkers_call.vpcf"
	end
end

function modifier_axe_counter_helix_lua:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


------------------------------------------
modifier_axe_counter_helix_special_fury_checker = class({})
function modifier_axe_counter_helix_special_fury_checker:IsDebuff()	
	return false
end

function modifier_axe_counter_helix_special_fury_checker:IsHidden()	
	return true
end

function modifier_axe_counter_helix_special_fury_checker:RemoveOnDeath()	
	return false
end
function modifier_axe_counter_helix_special_fury_checker:IsPurgable()	
	return false
end

modifier_axe_counter_helix_special_fury = class({})

function modifier_axe_counter_helix_special_fury:IsDebuff()	
	return false
end

function modifier_axe_counter_helix_special_fury:IsHidden()	
	return true
end

function modifier_axe_counter_helix_special_fury:IsPurgable()	
	return false
end

function modifier_axe_counter_helix_special_fury:RemoveOnDeath()	
	return true
end


function modifier_axe_counter_helix_special_fury:OnCreated()	
	if IsServer() then 
		self.radius = self:GetAbility():GetSpecialValueFor( "radius" )	
		local special = self:GetCaster():FindAbilityByName("pathfinder_axe_special_counter_helix_fury")
		self.tick = special:GetLevelSpecialValueFor("tick", 1)
		self.damage = self:GetAbility():GetLevelSpecialValueFor( "damage", self:GetAbility():GetLevel() - 1 ) / (1 / self.tick)		

		self.damageTable = {
				-- victim = target,
				attacker = self:GetCaster(),
				damage = self.damage,
				damage_type = DAMAGE_TYPE_PURE,
				ability = self:GetAbility(), --Optional.
				damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
			}
	

		self:StartIntervalThink(self.tick)	
	end
end

function modifier_axe_counter_helix_special_fury:OnIntervalThink()	
	self:PlayEffects()	
	self.hp_cost = self:GetCaster():GetMaxHealth() * self:GetCaster():FindAbilityByName("pathfinder_axe_special_counter_helix_fury"):GetLevelSpecialValueFor("hp_per_tick",1)

	if self:GetCaster():GetHealth() > self.hp_cost then
		local hp_cost_per_tick = {
					victim = self:GetCaster(),
					attacker = self:GetCaster(),
					damage = self.hp_cost,
					damage_type = DAMAGE_TYPE_PURE,
					ability = self:GetAbility(), --Optional.
					damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
				}
		ApplyDamage(hp_cost_per_tick)
	else
		self:GetAbility():ToggleAbility()
	end

	if not self:GetCaster():IsAlive() and self:GetAbility():GetToggleState() then		
		self:GetAbility():ToggleAbility()
	end
end

function modifier_axe_counter_helix_special_fury:GetOverrideAnimation()	
	return ACT_DOTA_CAST3_STATUE
end

function modifier_axe_counter_helix_special_fury:PlayEffects()
	-- Get Resources
	if IsServer() then		
		self:GetParent():FadeGesture(ACT_DOTA_CAST_ABILITY_3)
		local particle_cast = "particles/econ/items/axe/ti9_jungle_axe/ti9_jungle_axe_attack_blur_counterhelix.vpcf"
		local particle_cast2 = "particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser.vpcf"

		local sound_cast = "Hero_Axe.CounterHelix"

		-- Create Particle
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:ReleaseParticleIndex( effect_cast )
		effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:ReleaseParticleIndex( effect_cast )


		self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_3)

		-- Create Sound
		self:GetParent():EmitSoundParams( sound_cast, 0,0.5,0 )

		local enemies = FindUnitsInRadius(
				self:GetCaster():GetTeamNumber(),	-- int, your team number
				self:GetCaster():GetOrigin(),	-- point, center point
				nil,	-- handle, cacheUnit. (not known)
				self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
				DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
				DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
				0,	-- int, order filter
				false	-- bool, can grow cache
			)

			-- damage
		for _,enemy in pairs(enemies) do
			if enemy:GetUnitName() ~= "npc_dota_creature_bonus_greevil" then
				self.damageTable.victim = enemy
				ApplyDamage( self.damageTable )
				if self:GetCaster():HasAbility("pathfinder_axe_special_counter_helix_reduce_damage") then
					local special = self:GetCaster():FindAbilityByName("pathfinder_axe_special_counter_helix_reduce_damage")
					if special then
						enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_axe_counter_helix_special_reduce_damage", {duration =special:GetLevelSpecialValueFor("duration",1)})
					end
				end
			end
		end	
	end
end

function modifier_axe_counter_helix_special_fury:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_axe_counter_helix_special_fury:GetModifierMoveSpeedBonus_Percentage()	
	return -1 * self:GetCaster():FindAbilityByName("pathfinder_axe_special_counter_helix_fury"):GetLevelSpecialValueFor("self_slow",1)
end


---------------------------


modifier_axe_counter_helix_special_reduce_damage = class({})
function modifier_axe_counter_helix_special_reduce_damage:IsDebuff()	
	return true
end

function modifier_axe_counter_helix_special_reduce_damage:IsHidden()	
	return false
end

function modifier_axe_counter_helix_special_reduce_damage:RemoveOnDeath()	
	return true
end

function modifier_axe_counter_helix_special_reduce_damage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE ,
	}
	return funcs
end

function modifier_axe_counter_helix_special_reduce_damage:GetEffectName()
	return "particles/econ/courier/courier_trail_ember/courier_trail_ember.vpcf"
end

function modifier_axe_counter_helix_special_reduce_damage:GetModifierDamageOutgoing_Percentage()
	if IsServer() and self:GetParent():IsAlive() then
		return -1 * self:GetCaster():FindAbilityByName("pathfinder_axe_special_counter_helix_reduce_damage"):GetLevelSpecialValueFor("percent", 1)
	end
end