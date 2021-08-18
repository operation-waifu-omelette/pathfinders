modifier_pathfinder_axe_special_culling_blade_leap_checker = class({})
function modifier_pathfinder_axe_special_culling_blade_leap_checker:IsDebuff()	
	return false
end

function modifier_pathfinder_axe_special_culling_blade_leap_checker:IsHidden()	
	return true
end

function modifier_pathfinder_axe_special_culling_blade_leap_checker:RemoveOnDeath()	
	return false
end

function modifier_pathfinder_axe_special_culling_blade_leap_checker:IsPurgable()	
	return false
end

modifier_pathfinder_axe_special_culling_blade_thinker= class({})
LinkLuaModifier( "modifier_pathfinder_axe_special_culling_blade_leap_checker", "pathfinder/axe/axe_culling_blade_lua", LUA_MODIFIER_MOTION_NONE )

function modifier_pathfinder_axe_special_culling_blade_thinker:IsDebuff()	
	return false
end

function modifier_pathfinder_axe_special_culling_blade_thinker:IsHidden()	
	return true
end

function modifier_pathfinder_axe_special_culling_blade_thinker:RemoveOnDeath()	
	return false
end

function modifier_pathfinder_axe_special_culling_blade_thinker:IsPurgable()	
	return false
end

function modifier_pathfinder_axe_special_culling_blade_thinker:OnIntervalThink()
	if IsServer() and self:GetCaster():HasAbility("pathfinder_axe_special_culling_blade_leap") and not self:GetCaster():HasModifier("modifier_pathfinder_axe_special_culling_blade_leap_checker") then				
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_pathfinder_axe_special_culling_blade_leap_checker", {})
	end
end

function modifier_pathfinder_axe_special_culling_blade_thinker:OnCreated(table)
	self:StartIntervalThink(1)
end

axe_culling_blade_lua = class({})
LinkLuaModifier( "modifier_axe_culling_blade_lua", "pathfinder/axe/modifier_axe_culling_blade_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_axe_culling_blade_delay", "pathfinder/axe/axe_culling_blade_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_earthshaker_enchant_totem_lua_leap", "pathfinder/axe/axe_culling_blade_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_pathfinder_axe_special_culling_blade_thinker", "pathfinder/axe/axe_culling_blade_lua", LUA_MODIFIER_MOTION_NONE )

require("libraries.timers")

function axe_culling_blade_lua:Precache( hContext )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_necrolyte.vsndevts", hContext )
end

function axe_culling_blade_lua:OnUpgrade()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pathfinder_axe_special_culling_blade_thinker", {})
end

--------------------------------------------------------------------------------
function axe_culling_blade_lua:OnAbilityPhaseStart()
	local caster = self:GetCaster()	
	local target_unit = self:GetCursorTarget()
	if caster:HasAbility("pathfinder_axe_special_culling_blade_leap") then				
		local target_to_caster = target_unit:GetAbsOrigin() - caster:GetAbsOrigin()
		local target = caster:GetAbsOrigin() + target_to_caster:Normalized() * (target_to_caster:Length2D() - 200)
		caster:FaceTowards(target_unit:GetAbsOrigin())		

		Timers:CreateTimer(0.1, function() 
			self:UseResources(true, false, true)						
			caster:StartGesture(ACT_DOTA_FLAIL)
			EmitSoundOn("Hero_Necrolyte.Attack", caster)
			
			
			self:SetOverrideCastPoint(1.3)
			-- self:GetCaster():SetForwardVector(target_to_caster)		
			
			local modifier_movement_handler = caster:AddNewModifier(caster, self, "modifier_earthshaker_enchant_totem_lua_leap",
				{
					duration	= 1,
					x			= target.x,
					y			= target.y,
					z			= target.z,
				})

			if modifier_movement_handler then
				modifier_movement_handler.target_point = target
			end
			Timers:CreateTimer(0.7, function()
				caster:FadeGesture(ACT_DOTA_FLAIL)
				caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
			end)
			Timers:CreateTimer(1, function()	
				EmitSoundOn("Hero_Necrolyte.DeathPulse", caster)
				caster:SetCursorCastTarget(target_unit)
				self:OnSpellStart()
			end)
		end)
	else
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
		Timers:CreateTimer(self:GetCastPoint(), function()
			self:UseResources(true, false, true)						
			caster:SetCursorCastTarget(target_unit)
			self:OnSpellStart()
		end)
	end
end

function axe_culling_blade_lua:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasModifier("modifier_pathfinder_axe_special_culling_blade_leap_checker") then		
		return 1200
	end	
	return 150
end


-- Ability Start
function axe_culling_blade_lua:OnSpellStart()	
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()	

	-- load data
	local damage = self:GetSpecialValueFor("damage")
	local threshold = self:GetSpecialValueFor("kill_threshold")
	local radius = self:GetSpecialValueFor("speed_aoe")
	local duration = self:GetSpecialValueFor("speed_duration")

	-- Check success / not
	local success = false
	if target:GetHealth()<=threshold then success = true end

	-- effects
	self:PlayEffects( target, success )	

	if caster:HasAbility("pathfinder_axe_special_culling_blade_leap") then
		local spec = caster:FindAbilityByName("pathfinder_axe_special_culling_blade_leap")
		local stun_radius = spec:GetLevelSpecialValueFor("stun_radius",1)
		local stun_duration = spec:GetLevelSpecialValueFor("stun_duration",1)		
		local enemies = FindRadius(target, stun_radius, false)
		for _,enemy in pairs(enemies) do	
			if enemy ~= target then		
				enemy:AddNewModifier(caster, self, "modifier_stunned", {duration = stun_duration})

				local damageTable = {
					victim = enemy,
					attacker = caster,
					damage = damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
					ability = self, --Optional.
				}
				ApplyDamage(damageTable)	
				
				if self:GetCaster():HasAbility("pathfinder_axe_special_culling_blade_delay") then
					local dur = self:GetCaster():FindAbilityByName("pathfinder_axe_special_culling_blade_delay"):GetLevelSpecialValueFor("duration", 1)
					target:AddNewModifier(self:GetCaster(), self, "modifier_axe_culling_blade_delay", {duration=dur})
					-- target:AddNewModifier(self:GetCaster(), self, "modifier_nyx_assassin_vendetta_break", {duration=dur})
				end
			end
		end
		local fx = ParticleManager:CreateParticle("particles/econ/items/centaur/centaur_ti6/centaur_ti6_warstomp.vpcf", PATTACH_ABSORIGIN, target)
		ParticleManager:SetParticleControl(fx, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(fx, 1, Vector(stun_radius,stun_radius,stun_radius))
		ParticleManager:ReleaseParticleIndex(fx)
	end

	if success then
				
		-- Success:
		-- Damage as HPLoss 
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = threshold,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self, --Optional.
			damage_flags = DOTA_DAMAGE_FLAG_HPLOSS, --Optional.
		}
		ApplyDamage(damageTable)

		-- Resets cooldown
		self:EndCooldown()

		-- Apply modifier
		local allies = FindUnitsInRadius(
			caster:GetTeamNumber(),	-- int, your team number
			caster:GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)
		for _,ally in pairs(allies) do
			ally:AddNewModifier(
				caster, -- player source
				self, -- ability source
				"modifier_axe_culling_blade_lua", -- modifier name
				{ duration = duration } -- kv
			)
		end

		if self:GetCaster():HasAbility("pathfinder_axe_special_culling_blade_heal") then
			local spec = self:GetCaster():FindAbilityByName("pathfinder_axe_special_culling_blade_heal")
			local heal = target:GetMaxHealth() / 100 * spec:GetLevelSpecialValueFor("health_pct",1)
			local mana = self:GetManaCost(self:GetLevel()) * spec:GetLevelSpecialValueFor("mana_mult",1)

			caster:Heal(heal, self)
			caster:GiveMana(mana)
		end

		if caster:HasAbility("pathfinder_axe_special_culling_blade_omnislash") then
			local search_radius = self:GetCaster():FindAbilityByName("pathfinder_axe_special_culling_blade_omnislash"):GetLevelSpecialValueFor("search_radius",1)
			local enemies = FindUnitsInRadius(
				caster:GetTeamNumber(),	-- int, your team number
				caster:GetOrigin(),	-- point, center point
				nil,	-- handle, cacheUnit. (not known)
				search_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
				DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
				0,	-- int, flag filter
				FIND_CLOSEST ,	-- int, order filter
				false	-- bool, can grow cache
			)
			local chosen = nil
			for _,enemy in pairs(enemies) do
				chosen = enemy
				if enemy:GetHealth()<=threshold then 
					break
				end
			end
			
			Timers:CreateTimer(0.3, function()				
				if chosen then			
					
					local fx = ParticleManager:CreateParticle("particles/econ/events/ti6/blink_dagger_start_ti6_lvl2.vpcf", PATTACH_ABSORIGIN, caster)
					ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())
					ParticleManager:ReleaseParticleIndex(fx)

					
					caster:SetAbsOrigin(chosen:GetAbsOrigin() + RandomVector(170))
					FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
					caster:FaceTowards(chosen:GetAbsOrigin())					
					caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)

					fx = ParticleManager:CreateParticle("particles/econ/events/ti6/blink_dagger_end_ti6_lvl2.vpcf", PATTACH_ABSORIGIN, caster)
					ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())
					ParticleManager:ReleaseParticleIndex(fx)

					Timers:CreateTimer(0.3, function()	
						caster:SetCursorCastTarget(chosen)
						self:OnSpellStart()
					end)
				end
			end)
		end

	else
		-- Failed
		-- Magical damage
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self, --Optional.
		}
		ApplyDamage(damageTable)	
		
		if self:GetCaster():HasAbility("pathfinder_axe_special_culling_blade_delay") then
			local dur = self:GetCaster():FindAbilityByName("pathfinder_axe_special_culling_blade_delay"):GetLevelSpecialValueFor("duration", 1)
			target:AddNewModifier(self:GetCaster(), self, "modifier_axe_culling_blade_delay", {duration=dur})
			target:AddNewModifier(self:GetCaster(), self, "modifier_nyx_assassin_vendetta_break", {duration=dur})
		end		
	end
end


function axe_culling_blade_lua:OnSpellStartRemote(victim)
	-- unit identifier
	
	local caster = self:GetCaster()
	local target = victim

	-- load data
	local damage = self:GetSpecialValueFor("damage")	
	local radius = self:GetSpecialValueFor("speed_aoe")
	local threshold = self:GetSpecialValueFor("kill_threshold")
	local duration = self:GetSpecialValueFor("speed_duration")

	if target:GetHealth() > threshold then return end
	local success = true

	-- effects
	self:PlayEffects( target, success )

	if success then
		-- Success:
		-- Damage as HPLoss 
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = threshold,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self, --Optional.
			damage_flags = DOTA_DAMAGE_FLAG_HPLOSS, --Optional.
		}
		ApplyDamage(damageTable)

		-- Resets cooldown
		self:EndCooldown()

		-- Apply modifier
		local allies = FindUnitsInRadius(
			caster:GetTeamNumber(),	-- int, your team number
			caster:GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)
		for _,ally in pairs(allies) do
			ally:AddNewModifier(
				caster, -- player source
				self, -- ability source
				"modifier_axe_culling_blade_lua", -- modifier name
				{ duration = duration } -- kv
			)
		end	
	end
end

--------------------------------------------------------------------------------
function axe_culling_blade_lua:PlayEffects( target, success )
	-- Get Resources
	local particle_cast = ""
	local sound_cast = ""
	if success then		
		particle_cast = "particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf"
		sound_cast = "Hero_Axe.Culling_Blade_Success"
	else
		particle_cast = "particles/units/heroes/hero_axe/axe_culling_blade.vpcf"
		sound_cast = "Hero_Axe.Culling_Blade_Fail"
	end

	-- load data
	local direction = (target:GetOrigin()-self:GetCaster():GetOrigin()):Normalized()

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 4, target:GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 3, direction )
	ParticleManager:SetParticleControlForward( effect_cast, 4, direction )
	-- assert(loadfile("lua_abilities/rubick_spell_steal_lua/rubick_spell_steal_lua_color"))(self,effect_target)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, target )
end



-------------------------

modifier_axe_culling_blade_delay = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_axe_culling_blade_delay:IsHidden()
	return false
end

function modifier_axe_culling_blade_delay:OnCreated(table)
	self:StartIntervalThink(0.3)
end

function modifier_axe_culling_blade_delay:OnIntervalThink()
	self:GetCaster():FindAbilityByName("axe_culling_blade_lua"):OnSpellStartRemote(self:GetParent())
end

function modifier_axe_culling_blade_delay:IsDebuff()
	return true
end

function modifier_axe_culling_blade_delay:IsPurgable()
	return true
end


----------------------------------------------------

modifier_earthshaker_enchant_totem_lua_leap	= class({})

function modifier_earthshaker_enchant_totem_lua_leap:IsHidden()	return true end

function modifier_earthshaker_enchant_totem_lua_leap:OnCreated( params )
	if not IsServer() then return end

	self.destination	= Vector(params.x, params.y, params.z)
	self.vector			= (self.destination - self:GetParent():GetAbsOrigin())
	self.direction		= self.vector:Normalized()
	self.speed			= self.vector:Length2D() / self:GetDuration()

	if self:ApplyVerticalMotionController() == false then 
		self:Destroy()
	end
	if self:ApplyHorizontalMotionController() == false then 
		self:Destroy()
	end
	
	self.interval	= FrameTime()
	
	self:StartIntervalThink(self.interval)
end

function modifier_earthshaker_enchant_totem_lua_leap:OnIntervalThink()
	local z_axis = (-1) * self:GetElapsedTime() * (self:GetElapsedTime() - self:GetDuration()) * 562 * 4
	

	self:GetParent():SetOrigin( (self:GetParent():GetOrigin() * Vector(1, 1, 0)) + (((self.direction * self.speed * self.interval) * Vector(1, 1, 0)) + (Vector(0, 0, GetGroundHeight(self:GetParent():GetOrigin(), nil)) + Vector(0, 0, z_axis) )))
end

function modifier_earthshaker_enchant_totem_lua_leap:OnDestroy( kv )
	if not IsServer() then return end
	
	self:GetParent():InterruptMotionControllers( true )
	
	-- "However, getting hit by forced movement causes the ability to not apply Aftershock or the totem buff upon landing."
	-- if not self.aftershock_interrupt then
	-- 	EmitSoundOn("Hero_EarthShaker.Totem", self:GetCaster())
	
	-- 	self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_earthshaker_enchant_totem_lua", {duration = self:GetAbility():GetDuration()})
		
	-- 	if self:GetParent():HasModifier("modifier_earthshaker_aftershock_lua") then
	-- 		self:GetParent():FindModifierByName("modifier_earthshaker_aftershock_lua"):CastAftershock()
	-- 	end
	-- end
end

function modifier_earthshaker_enchant_totem_lua_leap:UpdateHorizontalMotion( me, dt )
	-- self:GetParent():SetOrigin( self:GetParent():GetOrigin() + (self.direction * self.speed * dt) )
end

function modifier_earthshaker_enchant_totem_lua_leap:OnHorizontalMotionInterrupted()
	if IsServer() and self:GetRemainingTime() > 0 then
		self.aftershock_interrupt = true
	end
end

function modifier_earthshaker_enchant_totem_lua_leap:OnVerticalMotionInterrupted()
	if IsServer() then
		self.aftershock_interrupt = true
		self:Destroy()
	end
end

-- "The leap duration is always the same, so the speed adapts based on the targeted distance. The leap height is always 562 range."
-- I'm forgetting all my parabola math, but multiplying height by 4 here sets it as the max height at mid-point; there's obviously a formula for this
function modifier_earthshaker_enchant_totem_lua_leap:UpdateVerticalMotion( me, dt )
	-- local z_axis = (-1) * self:GetElapsedTime() * (self:GetElapsedTime() - self:GetDuration()) * 562 * 4
	
	-- self:GetParent():SetOrigin( GetGroundPosition(self:GetParent():GetOrigin(), nil) + Vector(0, 0, z_axis) )
end

function modifier_earthshaker_enchant_totem_lua_leap:OnVerticalMotionInterrupted()
	-- if IsServer() then
		-- self:Destroy()
	-- end
end

function modifier_earthshaker_enchant_totem_lua_leap:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}

	return funcs
end

-- add "ultimate_scepter" + "enchant_totem_leap_from_battle"
-- function modifier_earthshaker_enchant_totem_lua_leap:GetActivityTranslationModifiers()
-- 	return "blood_chaser"
-- end

-- function modifier_earthshaker_enchant_totem_lua_leap:GetOverrideAnimation()
-- 	return ACT_DOTA_CAST_ABILITY_3
-- end

function modifier_earthshaker_enchant_totem_lua_leap:GetEffectName()
	return "particles/units/heroes/hero_tiny/tiny_toss_blur.vpcf"
end

function modifier_earthshaker_enchant_totem_lua_leap:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true
	}
end