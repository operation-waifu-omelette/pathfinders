
------------------------------------
-----    ROLLING THUNDER       -----
------------------------------------
pangolier_rolling_thunder_lua = pangolier_rolling_thunder_lua or class({})

LinkLuaModifier("modifier_imba_gyroshell_impact_check", "pathfinder/pangolier/pangolier_rolling_thunder_lua", LUA_MODIFIER_MOTION_NONE) 
LinkLuaModifier("modifier_gyroshell_bounce_check", "pathfinder/pangolier/pangolier_rolling_thunder_lua", LUA_MODIFIER_MOTION_NONE) 


function pangolier_rolling_thunder_lua:IsHiddenWhenStolen() return false end
function pangolier_rolling_thunder_lua:IsStealable() return true end
function pangolier_rolling_thunder_lua:IsNetherWardStealable() return false end
function pangolier_rolling_thunder_lua:GetAssociatedSecondaryAbilities()	return "pangolier_rolling_thunder_lua_stop" end

function pangolier_rolling_thunder_lua:GetManaCost(level)
	local manacost = self:GetSpecialValueFor("mana_cost")

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

	--Play ability cast sound
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), sound_cast, caster)

	if USE_MEME_SOUNDS and RollPercentage(30) then
		caster:EmitSound("Imba.PangolierRollin")
	end

	--Play the effect and animation
	self.cast_effect = ParticleManager:CreateParticle(cast_particle, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(self.cast_effect, 0, caster:GetAbsOrigin()) -- 0: Spotlight position,
	ParticleManager:SetParticleControl(self.cast_effect, 3, caster:GetAbsOrigin()) --3: shell and sprint effect position,
	ParticleManager:SetParticleControl(self.cast_effect, 5, caster:GetAbsOrigin()) --5: roses landing point

	return true
end

function pangolier_rolling_thunder_lua:OnAbilityPhaseInterrupted()

	--Destroy cast particle
	ParticleManager:DestroyParticle(self.cast_effect, true)
	ParticleManager:ReleaseParticleIndex(self.cast_effect)
	
	self:GetCaster():StopSound("Imba.PangolierRollin")
end

function pangolier_rolling_thunder_lua:OnSpellEnd()
	self:GetCaster():SwapAbilities("pangolier_rolling_thunder_lua", "pangolier_rolling_thunder_lua_stop", true, false)
	-- body
end



function pangolier_rolling_thunder_lua:OnSpellStart()
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local loop_sound = "Hero_Pangolier.Gyroshell.Loop"
	local roll_modifier = "modifier_pangolier_gyroshell" --Vanilla
	--local roll_modifier = "modifier_imba_gyroshell_roll" --Imba

	
	-- Ability specials
	local tick_interval = ability:GetSpecialValueFor("tick_interval")
	local forward_move_speed = ability:GetSpecialValueFor("forward_move_speed")
	local turn_rate_boosted = ability:GetSpecialValueFor("turn_rate_boosted")
	local turn_rate = ability:GetSpecialValueFor("turn_rate")
	local radius = ability:GetSpecialValueFor("radius")
	local hit_radius = ability:GetSpecialValueFor("hit_radius")
	local bounce_duration = ability:GetSpecialValueFor("bounce_duration")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	local knockback_radius = ability:GetSpecialValueFor("knockback_radius")
	local ability_duration = ability:GetSpecialValueFor("duration")
	local jump_recover_time = ability:GetSpecialValueFor("jump_recover_time")


	-- Play animation
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)



	--Stop the cast effect and animation
	ParticleManager:DestroyParticle(self.cast_effect, false)
	ParticleManager:ReleaseParticleIndex(self.cast_effect)

	--Apply a basic purge
	caster:Purge(false, true, false, false, false)

	--Starts rolling (Vanilla modifier for now)
	caster:AddNewModifier(caster, ability, roll_modifier, {duration = ability_duration})

	--starts checking for hero impacts
	caster:AddNewModifier(caster, ability, "modifier_imba_gyroshell_impact_check", {duration = ability_duration })


	--Play Loop sound
	EmitSoundOn(loop_sound, caster)

	--Replay loop sound if pango didn't finish rolling
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

-- Impact checker, will extend Rolling Thunder duration on each hero hit will also hadle the targets and damage for Talent #7
modifier_imba_gyroshell_impact_check = modifier_imba_gyroshell_impact_check or class({})

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

function modifier_imba_gyroshell_impact_check:GetModifierModelScale( params )
	if self:GetCaster():HasAbility("pangolier_rolling_thunder_ricochet") then
		return 50
	end	
	return self.modelscale
end

function modifier_imba_gyroshell_impact_check:OnCreated()
	if IsServer() then
		--Ability Properties
		self.gyroshell = self:GetCaster():FindModifierByName("modifier_pangolier_gyroshell")
		self.targets = self.targets or {}


		--Ability Specials
		self.duration_extend = self:GetAbility():GetSpecialValueFor("duration_extend")
		self.hit_radius = self:GetAbility():GetSpecialValueFor("hit_radius")
		-- Increase think time so the talent damage hopefully doesn't stack in one instance
		self:StartIntervalThink(0.05)
	end
end

function modifier_imba_gyroshell_impact_check:OnIntervalThink()
	if IsServer() then		

		--If pangolier stopped rolling, remove this modifier
		if not self:GetCaster():HasModifier("modifier_pangolier_gyroshell") then
			--self:GetCaster():SwapAbilities("pangolier_rolling_thunder_lua", "pangolier_rolling_thunder_lua_stop", true, false)
			self:Destroy()
		end

		local enemies_hit = 0

		-- Find all enemies in AoE
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
			self:GetCaster():GetAbsOrigin(),
			nil,
			self.hit_radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false)

		-- Check how many targets are valid (not impacted recently)
		for _,enemy in pairs(enemies) do
			if not enemy:IsMagicImmune() then
				--Is he affected by a previous impact? if so, ignore it
				if not enemy:HasModifier("modifier_pangolier_gyroshell_timeout") then
					enemies_hit = enemies_hit + 1
					--Talent #7: Double damage taken by single targets on subsequent impacts
					if self:GetCaster():HasAbility("pangolier_rolling_thunder_ricochet") then
						local found = false

						for k,v in pairs(self.targets) do
							if v == enemy then
								found = true
							end
						end

						if found then --was this target hit already?
							--Check how many times this target was damaged already
							local times_hit = enemy.hit_times
							print("doing times hit :", times_hit)
							local extra_damage = self:GetAbility():GetAbilityDamage()

							--Multiplies the damage by 2 for each previous impact
							if times_hit > 1 then
								times_hit = times_hit - 1
								for i=1,times_hit do
									extra_damage = extra_damage + self:GetAbility():GetAbilityDamage()
								end
							end

							print("doing damage :", extra_damage)

							local damageTable = {victim = enemy,
								damage = extra_damage,
								damage_type = DAMAGE_TYPE_MAGICAL,
								damage_flags = DOTA_DAMAGE_FLAG_NONE,
								attacker = self:GetCaster(),
								ability = self:GetAbility()
							}

							ApplyDamage(damageTable)

							enemy.hit_times = enemy.hit_times + 1 --increase hit count

						else --New target, add him to the table and set hit_time to 1
							--print("doing new target")
							enemy.hit_times = 1
							table.insert(self.targets, enemy)

						end
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


pangolier_rolling_thunder_lua_stop = class ({})

function pangolier_rolling_thunder_lua_stop:Spawn()
    if IsServer() then
        self:SetLevel(1)
    end
end
function pangolier_rolling_thunder_lua_stop:IsInnateAbility()				return true end
function pangolier_rolling_thunder_lua_stop:IsStealable()					return false end
function pangolier_rolling_thunder_lua_stop:GetAssociatedPrimaryAbilities()	return "pangolier_rolling_thunder_lua" end
function pangolier_rolling_thunder_lua_stop:ProcsMagicStick() return false end

-- Attempts to stop this ability from getting bricked?
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
