--------------------------------------------------------------------------------------------------------------------------------------------------

pangolier_rolling_thunder_lua = pangolier_rolling_thunder_lua or class({})
modifier_imba_gyroshell_impact_check = modifier_imba_gyroshell_impact_check or class({})
pangolier_rolling_thunder_lua_stop = pangolier_rolling_thunder_lua_stop or class ({})
modifier_pangolier_rolling_thunder_timeout = modifier_pangolier_rolling_thunder_timeout or class({})

LinkLuaModifier("modifier_imba_gyroshell_impact_check", "pathfinder/pangolier/pangolier_rolling_thunder_lua", LUA_MODIFIER_MOTION_NONE) 
LinkLuaModifier("modifier_pangolier_rolling_thunder_timeout", "pathfinder/pangolier/pangolier_rolling_thunder_lua", LUA_MODIFIER_MOTION_NONE) 

--------------------------------------------------------------------------------------------------------------------------------------------------

--[[---------------------------------------------------------------------
						ROLLING THUNDER
]]------------------------------------------------------------------------

function pangolier_rolling_thunder_lua:IsHiddenWhenStolen() return false end
function pangolier_rolling_thunder_lua:IsStealable() return true end
function pangolier_rolling_thunder_lua:IsNetherWardStealable() return false end
function pangolier_rolling_thunder_lua:GetAssociatedSecondaryAbilities()	return "pangolier_rolling_thunder_lua_stop" end

function pangolier_rolling_thunder_lua:GetManaCost(level)
	local manacost = self.BaseClass.GetManaCost(self, level)
	return manacost
end

function pangolier_rolling_thunder_lua:GetCastPoint()
	local cast_point = self:GetSpecialValueFor("cast_time_tooltip")
	return cast_point
end

function pangolier_rolling_thunder_lua:OnAbilityPhaseStart()

	local sound_cast = "Hero_Pangolier.Gyroshell.Cast"
	local cast_particle = "particles/units/heroes/hero_pangolier/pangolier_gyroshell_cast.vpcf"
	local caster = self:GetCaster()

	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), sound_cast, caster)

	self.cast_effect = ParticleManager:CreateParticle(cast_particle, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(self.cast_effect, 0, caster:GetAbsOrigin()) 
	ParticleManager:SetParticleControl(self.cast_effect, 3, caster:GetAbsOrigin()) 
	ParticleManager:SetParticleControl(self.cast_effect, 5, caster:GetAbsOrigin())

	return true
end

function pangolier_rolling_thunder_lua:OnAbilityPhaseInterrupted()

	ParticleManager:DestroyParticle(self.cast_effect, true)
	ParticleManager:ReleaseParticleIndex(self.cast_effect)
	
	self:GetCaster():StopSound("Imba.PangolierRollin")
end

function pangolier_rolling_thunder_lua:OnSpellEnd()
	self:GetCaster():SwapAbilities("pangolier_rolling_thunder_lua", "pangolier_rolling_thunder_lua_stop", true, false)
end

function pangolier_rolling_thunder_lua:OnSpellStart()

	local caster = self:GetCaster()
	local ability = self
	local loop_sound = "Hero_Pangolier.Gyroshell.Loop"
	local roll_modifier = "modifier_pangolier_gyroshell"

	local ability_duration = ability:GetSpecialValueFor("duration")
	---------------- ROLLING THUNDER DURATION TALENT -----------------------------------------------------------
	if self:GetCaster():FindAbilityByName("special_bonus_pathfinder_rolling_thunder+duration"):IsTrained() then
		ability_duration = ability_duration + self:GetCaster():FindAbilityByName("special_bonus_pathfinder_rolling_thunder+duration"):GetSpecialValueFor("duration")
	end
	--------------------------------------------------------------------------------------------------------------

	caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)

	ParticleManager:DestroyParticle(self.cast_effect, false)
	ParticleManager:ReleaseParticleIndex(self.cast_effect)

	caster:Purge(false, true, false, false, false)

	caster:AddNewModifier(caster, ability, roll_modifier, {duration = ability_duration})

	caster:AddNewModifier(caster, ability, "modifier_imba_gyroshell_impact_check", {duration = ability_duration })

	EmitSoundOn(loop_sound, caster)

	caster:SetContextThink("Loop_sound_replay", function ()

			if caster:HasModifier("modifier_pangolier_gyroshell") then
				StopSoundOn(loop_sound, caster)
				EmitSoundOn(loop_sound, caster)

				return 8.6
			else
				return nil
			end
	end, 8.6)

	caster:SwapAbilities("pangolier_rolling_thunder_lua", "pangolier_rolling_thunder_lua_stop", false, true)
end


--[[---------------------------------------------------------------------
						ROLLING THUNDER IMPACT CHECK
]]------------------------------------------------------------------------

function modifier_imba_gyroshell_impact_check:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_MODEL_SCALE,
	}
	return funcs
end

function modifier_imba_gyroshell_impact_check:IsHidden() return true end
function modifier_imba_gyroshell_impact_check:IsPurgable() return false end
function modifier_imba_gyroshell_impact_check:IsDebuff() return false end

--------------------- MEGA BALL SHARD ---------------------------------------------
function modifier_imba_gyroshell_impact_check:GetModifierModelScale( params )
	if self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_mega_ball") then
		return 50
	end	
	return self.modelscale
end
---------------------------------------------------------------------------

function modifier_imba_gyroshell_impact_check:OnCreated()
	if IsServer() then
		self.gyroshell = self:GetCaster():FindModifierByName("modifier_pangolier_gyroshell")
		self.targets = self.targets or {}
		self.collided = 0
		self.hit_radius = self:GetAbility():GetSpecialValueFor("hit_radius")
		--------------------- MEGA BALL SHARD ---------------------------------------------
		if self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_mega_ball") then
			self.hit_radius = self.hit_radius * 1.5
		end	
		--------------------------------------------------------------------------------
		self:StartIntervalThink(0.05)
	end
end

function modifier_imba_gyroshell_impact_check:OnIntervalThink()
	if IsServer() then		
		--------------------------- MULTI BALL SHARD -------------------------------------------------------
		if self:GetParent():FindAbilityByName("pangolier_rolling_thunder_multi_ball") then
			if self:GetParent():HasModifier("modifier_pangolier_gyroshell_ricochet") then
				if self.collided == 0 then
					self.collided = 1
					new_roller = CreateUnitByName("npc_dota_creature_pangolier_rolling_summon", self:GetCaster():GetOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)
					new_roller:AddNewModifier(
						self:GetCaster(), -- player source
						self, -- ability source
						"modifier_pangolier_npc_gyroshell_lua", -- modifier name
						{ duration = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("duration") } -- kv
					)
				end
			else
				self.collided = 0
			end
		end
		-----------------------------------------------------------------------------------------------------
		if not self:GetCaster():HasModifier("modifier_pangolier_gyroshell") then
			self:Destroy()
		end

		local damage = self:GetAbility():GetSpecialValueFor("actual_damage")
		----------------------- ROLLING THUNDER MEGA BALL SHARD ------------------------------------------------------------
		if self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_mega_ball") then
			damage = damage * self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_mega_ball"):GetSpecialValueFor("damage_multiplier")
		end	

		local enemies_hit = 0

		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
			self:GetCaster():GetAbsOrigin(),
			nil,
			self.hit_radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false)

		for _,enemy in pairs(enemies) do
			if not enemy:IsMagicImmune() then
				if not enemy:HasModifier("modifier_pangolier_rolling_thunder_timeout") then
					enemy:AddNewModifier(self:GetCaster(), self, "modifier_pangolier_rolling_thunder_timeout", {duration = 1.5})
					enemies_hit = enemies_hit + 1
					
						local found = false

						for k,v in pairs(self.targets) do
							if v == enemy then
								found = true
							end
						end
						
						-----------------------------------------------------------------------------------------------------
						local extra_damage = damage
						if found then
							
							local times_hit = enemy.hit_times
						
							extra_damage = extra_damage + damage
							
							if times_hit > 1 then
								times_hit = times_hit - 1
								for i=1,times_hit do
									extra_damage = extra_damage + damage
								end
							end
							---------------------- RICHOCHET SHARD -------------------------------------------------
							if not self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_ricochet") then
								extra_damage = damage
							end
							-------------------------------------------------------------------------------------

							local damageTable = {victim = enemy,
								damage = extra_damage,
								damage_type = DAMAGE_TYPE_MAGICAL,
								damage_flags = DOTA_DAMAGE_FLAG_NONE,
								attacker = self:GetCaster(),
								ability = self:GetAbility()
							}

							ApplyDamage(damageTable)
							if enemy:GetHealth() <= 0  then
								EmitSoundOn("Hero_Pangolier.Gyroshell.Carom", self:GetCaster())
							end
							enemy.hit_times = enemy.hit_times + 1 
					
						else 
							local damageTable = {victim = enemy,
								damage = extra_damage,
								damage_type = DAMAGE_TYPE_MAGICAL,
								damage_flags = DOTA_DAMAGE_FLAG_NONE,
								attacker = self:GetCaster(),
								ability = self:GetAbility()
							}
							ApplyDamage(damageTable)
							if enemy:GetHealth() <= 0 then
								EmitSoundOn("Hero_Pangolier.Gyroshell.Carom", self:GetCaster())
							end
							enemy.hit_times = 1
							table.insert(self.targets, enemy)

						end
					
				end
			end
		end
		
	end
end

function modifier_imba_gyroshell_impact_check:OnRemoved()
	if IsServer() then	
		self:GetCaster():SwapAbilities("pangolier_rolling_thunder_lua", "pangolier_rolling_thunder_lua_stop", true, false)	
	end
end
function modifier_imba_gyroshell_impact_check:OnDestroy()
	------------------------------ ROLLING THUNDER COOLDOWN TALENT ----------------------------------------
	local roll = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua")
	if self:GetCaster():FindAbilityByName("special_bonus_pathfinder_pangolier_rolling_thunder_lua+cooldown"):IsTrained() and not roll:IsCooldownReady() then	
		roll:EndCooldown()
		local reduce_amount = self:GetCaster():FindAbilityByName("special_bonus_pathfinder_pangolier_rolling_thunder_lua+cooldown"):GetSpecialValueFor("cooldown")
		local current_cooldown = roll:GetCooldown(roll:GetLevel())
		print("rolling boulder current cooldown: ", current_cooldown)
		local new_cooldown = current_cooldown - reduce_amount
		print("rolling boulder current cooldown: ", new_cooldown)
		roll:StartCooldown(new_cooldown)
	end
	-------------------------------------------------------------------------------------------------------
end

--[[---------------------------------------------------------------------
						ROLLING THUNDER STOP
]]------------------------------------------------------------------------

function pangolier_rolling_thunder_lua_stop:Spawn()
    if IsServer() then
        self:SetLevel(1)
    end
end
function pangolier_rolling_thunder_lua_stop:IsInnateAbility()				return true end
function pangolier_rolling_thunder_lua_stop:IsStealable()					return false end
function pangolier_rolling_thunder_lua_stop:GetAssociatedPrimaryAbilities()	return "pangolier_rolling_thunder_lua" end
function pangolier_rolling_thunder_lua_stop:ProcsMagicStick() return false end

function pangolier_rolling_thunder_lua_stop:OnOwnerSpawned()
	local gyroshell_ability = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua")
	if gyroshell_ability and gyroshell_ability:IsHidden() then
		self:GetCaster():SwapAbilities("pangolier_rolling_thunder_lua", "pangolier_rolling_thunder_lua_stop", true, false)
	end
end

function pangolier_rolling_thunder_lua_stop:OnSpellStart()
	if not IsServer() then return end
	
	if self:GetCaster():HasModifier("modifier_pangolier_gyroshell") then
		self:GetCaster():RemoveModifierByName("modifier_pangolier_gyroshell")
	end
end


--------------------------------
-- ROLLING THUNDER STUN --
--------------------------------

function modifier_pangolier_rolling_thunder_timeout:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_pangolier_rolling_thunder_timeout:GetEffectAttachType()
end

function modifier_pangolier_rolling_thunder_timeout:CheckState()
end
