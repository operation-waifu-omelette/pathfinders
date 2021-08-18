-------------------------------------------
--			  Super Nova
-------------------------------------------
LinkLuaModifier( "modifier_ability_black_hole_thinker", "pathfinder/phoenix/phoenix_supernova_pf", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ability_black_hole_debuff", "pathfinder/phoenix/phoenix_supernova_pf", LUA_MODIFIER_MOTION_HORIZONTAL )

LinkLuaModifier( "modifier_generic_2_charges", "pathfinder/generic/modifier_generic_2_charges", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_phoenix_supernova_allies_checker", "pathfinder/phoenix/phoenix_supernova_pf", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_phoenix_supernova_pf_egg_thinker", "pathfinder/phoenix/phoenix_supernova_pf", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phoenix_supernova_pf_caster_dummy", "pathfinder/phoenix/phoenix_supernova_pf", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phoenix_supernova_pf_bird_thinker", "pathfinder/phoenix/phoenix_supernova_pf", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phoenix_supernova_pf_dmg", "pathfinder/phoenix/phoenix_supernova_pf", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phoenix_supernova_pf_scepter_passive", "pathfinder/phoenix/phoenix_supernova_pf", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phoenix_supernova_pf_scepter_passive_cooldown", "pathfinder/phoenix/phoenix_supernova_pf", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_phoenix_supernova_pf_force_day", "pathfinder/phoenix/phoenix_supernova_pf", LUA_MODIFIER_MOTION_NONE)

require("libraries.timers")

phoenix_supernova_pf = phoenix_supernova_pf or class({})

function phoenix_supernova_pf:Spawn()
	if not IsServer() then return end
	Timers( 1, function ( )		
		if self:GetCaster():HasAbility("pathfinder_supernova_allies") and not self:GetCaster():HasModifier("modifier_phoenix_supernova_allies_checker") then			
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_phoenix_supernova_allies_checker", {})
			self:RefreshIntrinsicModifier()
			return nil
		end
		return 1.0
	end)
end

function phoenix_supernova_pf:GetIntrinsicModifierName()
	if self:GetCaster():HasModifier("modifier_phoenix_supernova_allies_checker") then
		return "modifier_generic_2_charges"
	end
end

function phoenix_supernova_pf:IsHiddenWhenStolen() 	return false end
function phoenix_supernova_pf:IsRefreshable() 			return true end
function phoenix_supernova_pf:IsStealable() 			return true end

function phoenix_supernova_pf:GetBehavior()
	if not self:GetCaster():HasModifier("modifier_phoenix_supernova_allies_checker") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	else
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK
	end
end

function phoenix_supernova_pf:OnAbilityPhaseStart()
	if not IsServer() then
		return
	end
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_5)
	return true
end

function phoenix_supernova_pf:GetCastRange()
	if self:GetCaster():HasModifier("modifier_phoenix_supernova_allies_checker") then
		return 700
	else
		return self:GetSpecialValueFor("aura_radius")
	end
end
function phoenix_supernova_pf:GetAbilityTextureName()   return "phoenix_supernova" end

function phoenix_supernova_pf:OnSpellStart()
	if not IsServer() then
		return
	end
	
	local caster = self:GetCaster()
	local ability = self
	local egg_duration = self:GetSpecialValueFor("duration")


	caster.egg_target = caster
	if self:GetCaster():HasModifier("modifier_phoenix_supernova_allies_checker") then
		caster.egg_target = self:GetCursorTarget()
	end

	if caster.egg_target == caster then
		-- Remove any existing Sun Rays that may be mid-cast
		caster:RemoveModifierByName("modifier_phoenix_sun_ray_pf_caster_dummy")
	end

	local location = caster.egg_target:GetAbsOrigin()
	local ground_location = GetGroundPosition(location, caster.egg_target)
	

	caster.egg_target:AddNewModifier(caster, ability, "modifier_phoenix_supernova_pf_caster_dummy", {duration = egg_duration })
	caster.egg_target:AddNoDraw()

	local egg = CreateUnitByName("npc_dota_phoenix_sun_pf", ground_location, false, caster, caster:GetOwner(), caster:GetTeamNumber())

	local egg_health = caster.egg_target:GetMaxHealth() / 100 * self:GetLevelSpecialValueFor("max_health_for_egg", self:GetLevel() - 1)
	egg:SetMaxHealth(egg_health)
	egg:SetBaseMaxHealth(egg_health)
	egg:SetHealth(egg_health)
	egg:SetPhysicalArmorBaseValue(caster.egg_target:GetPhysicalArmorValue(false))

	egg:AddNewModifier(caster, ability, "modifier_kill", {duration = egg_duration })
	egg:AddNewModifier(caster, ability, "modifier_phoenix_supernova_pf_egg_thinker", {duration = egg_duration + 0.3 })

	if caster:HasAbility("special_bonus_unique_phoenix_egg_bkb") and caster:FindAbilityByName("special_bonus_unique_phoenix_egg_bkb"):GetLevel() > 0 then
		egg:AddNewModifier(caster, ability, "modifier_black_king_bar_immune", {duration = egg_duration })		
	end	

	local egg_playback_rate = 6 / egg_duration
	egg:StartGestureWithPlaybackRate(ACT_DOTA_IDLE , egg_playback_rate)

	caster.egg = egg
end

modifier_phoenix_supernova_pf_caster_dummy = modifier_phoenix_supernova_pf_caster_dummy or class({})

function modifier_phoenix_supernova_pf_caster_dummy:IsDebuff()				return false end
function modifier_phoenix_supernova_pf_caster_dummy:IsHidden() 				return false end
function modifier_phoenix_supernova_pf_caster_dummy:IsPurgable() 				return false end
function modifier_phoenix_supernova_pf_caster_dummy:IsPurgeException() 		return false end
function modifier_phoenix_supernova_pf_caster_dummy:IsStunDebuff() 			return false end
function modifier_phoenix_supernova_pf_caster_dummy:RemoveOnDeath() 			return true end
function modifier_phoenix_supernova_pf_caster_dummy:IgnoreTenacity() 			return true end

function modifier_phoenix_supernova_pf_caster_dummy:GetTexture() return "phoenix_supernova" end

function modifier_phoenix_supernova_pf_caster_dummy:DeclareFunctions()
	local decFuns =
		{
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_EVENT_ON_DEATH,
		}
	return decFuns
end

function modifier_phoenix_supernova_pf_caster_dummy:CheckState()
	local state =
		{
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_MUTED] = true,
			-- [MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_OUT_OF_GAME] = true,
		}
	
	if self:GetCaster() ~= self:GetParent() then
		state[MODIFIER_STATE_STUNNED] = true
	end
		
	return state
end

function modifier_phoenix_supernova_pf_caster_dummy:GetModifierIncomingDamage_Percentage()
	return -100
end

function modifier_phoenix_supernova_pf_caster_dummy:OnCreated()
	if not IsServer() then
		return
	end
	if self:GetAbility():IsStolen() then
		return
	end
	local caster = self:GetCaster()
	self.abilities = {}
	
	if self:GetCaster() == self:GetParent() then
		for slot = 0, 10 do
			local ability = self:GetParent():GetAbilityByIndex(slot)
            
            -- Disables casting abilities during supernova.
			if ability and ability:IsActivated() then
				ability:SetActivated(false)
				table.insert(self.abilities, ability)
			end
		end		
	end
	self:GetAbility():SetActivated(false)
end

function modifier_phoenix_supernova_pf_caster_dummy:OnDeath( keys )
	if not IsServer() then
		return
	end
	if keys.unit == self:GetParent() then
		local eggs = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
			self:GetParent():GetAbsOrigin(),
			nil,
			2500,
			DOTA_UNIT_TARGET_TEAM_BOTH,
			DOTA_UNIT_TARGET_ALL,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
            false )
		for _, egg in pairs(eggs) do
			if egg:GetUnitName() == "npc_dota_phoenix_sun_pf" and egg:GetTeamNumber() == self:GetParent():GetTeamNumber() and egg:GetOwner() == self:GetParent():GetOwner() then
				egg:Kill(self:GetAbility(), keys.attacker)
			end
		end
	end
end

function modifier_phoenix_supernova_pf_caster_dummy:OnDestroy()
	if not IsServer() then
		return
	end
	if self:GetCaster():GetUnitName() == "npc_dota_hero_phoenix" then
		self:GetCaster():StartGesture(ACT_DOTA_INTRO)
	end
	
	if self:GetCaster() == self:GetParent() then
		for _, ability in pairs(self.abilities) do
			ability:SetActivated(true)
		end
	end
	self:GetAbility():SetActivated(true)
end

modifier_phoenix_supernova_pf_egg_thinker = modifier_phoenix_supernova_pf_egg_thinker or class({})


function modifier_phoenix_supernova_pf_egg_thinker:IsDebuff()					return false end
function modifier_phoenix_supernova_pf_egg_thinker:IsHidden() 				return false end
function modifier_phoenix_supernova_pf_egg_thinker:IsPurgable() 				return false end
function modifier_phoenix_supernova_pf_egg_thinker:IsPurgeException() 		return false end
function modifier_phoenix_supernova_pf_egg_thinker:IsStunDebuff() 			return false end
function modifier_phoenix_supernova_pf_egg_thinker:RemoveOnDeath() 			return true end
function modifier_phoenix_supernova_pf_egg_thinker:IgnoreTenacity() 			return true end
function modifier_phoenix_supernova_pf_egg_thinker:IsAura() 					return true end
function modifier_phoenix_supernova_pf_egg_thinker:GetAuraSearchTeam() 		return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_phoenix_supernova_pf_egg_thinker:GetAuraSearchType() 		return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_phoenix_supernova_pf_egg_thinker:GetAuraRadius() 			return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_phoenix_supernova_pf_egg_thinker:GetModifierAura()			return "modifier_phoenix_supernova_pf_dmg" end

function modifier_phoenix_supernova_pf_egg_thinker:GetTexture() return "phoenix_supernova" end

function modifier_phoenix_supernova_pf_egg_thinker:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_DEATH,
	}
end


function modifier_phoenix_supernova_pf_egg_thinker:OnCreated()
	self.aura_radius	= self:GetAbility():GetSpecialValueFor("aura_radius")
	self.damage_per_sec	= self:GetAbility():GetSpecialValueFor("damage_per_sec")
	
	if not IsServer() then
		return
	end
	local egg = self:GetParent()
	local caster = self:GetCaster()
	local pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_phoenix/phoenix_supernova_egg.vpcf", PATTACH_ABSORIGIN_FOLLOW, egg )
	ParticleManager:SetParticleControlEnt( pfx, 0, egg, PATTACH_POINT_FOLLOW, "attach_hitloc", egg:GetAbsOrigin(), true )
	ParticleManager:SetParticleControlEnt( pfx, 1, egg, PATTACH_POINT_FOLLOW, "attach_hitloc", egg:GetAbsOrigin(), true )
	ParticleManager:ReleaseParticleIndex( pfx )
	StartSoundEvent( "Hero_Phoenix.SuperNova.Begin", egg)
	StartSoundEvent( "Hero_Phoenix.SuperNova.Cast", egg)

	egg:StartGestureWithPlaybackRate(ACT_DOTA_IDLE, 6 / self:GetDuration())

	if caster:HasAbility("pathfinder_supernova_blackhole") then
		self.bh_thinker = CreateModifierThinker(
			caster,
			self,
			"modifier_ability_black_hole_thinker",
			{ duration = self:GetDuration() },
			egg:GetAbsOrigin(),
			caster:GetTeamNumber(),
			false
		)
		self.bh_thinker = self.bh_thinker:FindModifierByName("modifier_ability_black_hole_thinker")
	end

	self:ResetUnit(caster.egg_target)
	caster.egg_target:SetMana( caster.egg_target:GetMaxMana() )

	local ability = self:GetAbility()
	GridNav:DestroyTreesAroundPoint(egg:GetAbsOrigin(), ability:GetSpecialValueFor("cast_range") , false)
	
	self:OnIntervalThink()
	self:StartIntervalThink(1.0)

end

function modifier_phoenix_supernova_pf_egg_thinker:OnIntervalThink()
	if not IsServer() then
		return
	end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local egg = self:GetParent()
	if not egg:IsAlive() then
		return
	end
	
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
		egg:GetAbsOrigin(),
		nil,
		ability:GetSpecialValueFor("aura_radius"),
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false )
	for _, enemy in pairs(enemies) do
		local damageTable = {
			victim = enemy,
			attacker = caster,
			damage = self.damage_per_sec,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = ability,
		}
		ApplyDamage(damageTable)
	end

	if caster:HasAbility("pathfinder_supernova_heal_bkb") then
		local allies = FindUnitsInRadius(caster:GetTeamNumber(),
		egg:GetAbsOrigin(),
		nil,
		ability:GetSpecialValueFor("aura_radius"),
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false )
		for _, ally in pairs(allies) do
			local heal = self.damage_per_sec
			ally:Heal(heal, self:GetAbility())
			ally:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_minotaur_horn_immune", {duration = 1.1})	

			local bondFX = ParticleManager:CreateParticle( "particles/econ/items/warlock/warlock_ti10_head/warlock_ti_10_fatal_bonds_pulse.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
			ParticleManager:SetParticleControlEnt( bondFX, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
			ParticleManager:SetParticleControlEnt( bondFX, 1, ally, PATTACH_POINT_FOLLOW, "attach_hitloc", ally:GetAbsOrigin(), true )
			ParticleManager:ReleaseParticleIndex(bondFX)
			local nFXIndex = ParticleManager:CreateParticle( "particles/items3_fx/fish_bones_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, ally)
			ParticleManager:ReleaseParticleIndex( nFXIndex )		
		end
	end
end

function modifier_phoenix_supernova_pf_egg_thinker:OnDeath( keys )
	if not IsServer() then
		return
	end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local egg = self:GetParent()
	local killer = keys.attacker
	if egg ~= keys.unit then
		return
	end

	caster.egg_target:RemoveNoDraw()
	egg:AddNoDraw()

	StopSoundEvent("Hero_Phoenix.SuperNova.Begin", egg)
	StopSoundEvent( "Hero_Phoenix.SuperNova.Cast", egg)
	if egg == killer then
		-- Phoenix reborns
		StartSoundEvent( "Hero_Phoenix.SuperNova.Explode", egg)
		local pfxName = "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf"
		local pfx = ParticleManager:CreateParticle( pfxName, PATTACH_ABSORIGIN_FOLLOW, caster.egg_target )
		ParticleManager:SetParticleControl( pfx, 0, egg:GetAbsOrigin() )
		ParticleManager:SetParticleControl( pfx, 1, Vector(1.5,1.5,1.5) )
		ParticleManager:SetParticleControl( pfx, 3, egg:GetAbsOrigin() )
		ParticleManager:ReleaseParticleIndex(pfx)
		caster.egg_target:SetHealth( caster.egg_target:GetMaxHealth() )
		
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
			egg:GetAbsOrigin(),
			nil,
			ability:GetSpecialValueFor("aura_radius"),
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			FIND_ANY_ORDER,
			false )
		for _, enemy in pairs(enemies) do
			enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration = ability:GetSpecialValueFor("stun_duration")})
		end

		if caster:HasAbility("pathfinder_supernova_heal_bkb") then
			local allies = FindUnitsInRadius(caster:GetTeamNumber(),
			egg:GetAbsOrigin(),
			nil,
			ability:GetSpecialValueFor("aura_radius"),
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false )
			for _, ally in pairs(allies) do
				local heal = ally:GetMaxHealth() / 100 * self:GetCaster():FindAbilityByName("pathfinder_supernova_heal_bkb"):GetLevelSpecialValueFor("final_heal_percent",1)
				ally:Heal(heal, self:GetAbility())	
				local nFXIndex = ParticleManager:CreateParticle( "particles/items3_fx/fish_bones_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, ally)
				ParticleManager:ReleaseParticleIndex( nFXIndex )		
				local bondFX = ParticleManager:CreateParticle( "particles/econ/events/ti10/mekanism_recipient_ti10.vpcf", PATTACH_POINT_FOLLOW, ally )
				ParticleManager:SetParticleControl( bondFX, 0, ally:GetAbsOrigin())
				ParticleManager:SetParticleControl( bondFX, 1, ally:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(bondFX)	
			end
		end
	else
		-- Phoenix killed
		StartSoundEventFromPosition( "Hero_Phoenix.SuperNova.Death", egg:GetAbsOrigin())
		if caster.egg_target:IsAlive() then  caster.egg_target:Kill(ability, killer) end

		local pfxName = "particles/units/heroes/hero_phoenix/phoenix_supernova_death.vpcf"
		local pfx = ParticleManager:CreateParticle( pfxName, PATTACH_WORLDORIGIN, nil )
		local attach_point = caster.egg_target:ScriptLookupAttachment( "attach_hitloc" )
		ParticleManager:SetParticleControl( pfx, 0, caster:GetAttachmentOrigin(attach_point) )
		ParticleManager:SetParticleControl( pfx, 1, caster:GetAttachmentOrigin(attach_point) )
		ParticleManager:SetParticleControl( pfx, 3, caster:GetAttachmentOrigin(attach_point) )
		ParticleManager:ReleaseParticleIndex(pfx)
	end
	caster.egg = nil
	FindClearSpaceForUnit(caster.egg_target, egg:GetAbsOrigin(), false)

	if caster:HasAbility("pathfinder_supernova_blackhole") and self.bh_thinker and not self.bh_thinker:IsNull() then
		self.bh_thinker:Destroy()
	end
end

function modifier_phoenix_supernova_pf_egg_thinker:ResetUnit( unit )
	for i=0,10 do
		local abi = unit:GetAbilityByIndex(i)
		if abi then
			if abi:GetAbilityType() ~= 1 and not abi:IsItem() then
				abi:EndCooldown()
			end
		end
	end
	unit:Purge( true, true, true, true, true )
end

function modifier_phoenix_supernova_pf_egg_thinker:OnTakeDamage( keys )
	if not IsServer() then
		return
	end

	local egg = self:GetParent()

	if keys.unit ~= egg then
		return
	end
	
	local pfxName = "particles/units/heroes/hero_phoenix/phoenix_supernova_hit.vpcf"
	local pfx = ParticleManager:CreateParticle( pfxName, PATTACH_POINT_FOLLOW, egg )
	local attach_point = egg:ScriptLookupAttachment( "attach_hitloc" )
	ParticleManager:SetParticleControlEnt( pfx, 0, egg, PATTACH_POINT_FOLLOW, "attach_hitloc", egg:GetAttachmentOrigin(attach_point), true )
	ParticleManager:SetParticleControlEnt( pfx, 1, egg, PATTACH_POINT_FOLLOW, "attach_hitloc", egg:GetAttachmentOrigin(attach_point), true )
	ParticleManager:ReleaseParticleIndex(pfx)
end

modifier_phoenix_supernova_pf_dmg = modifier_phoenix_supernova_pf_dmg or class({})

function modifier_phoenix_supernova_pf_dmg:IsHidden() return false end
function modifier_phoenix_supernova_pf_dmg:IsDebuff() 
	return true 
end
function modifier_phoenix_supernova_pf_dmg:IsPurgable() return false end

function modifier_phoenix_supernova_pf_dmg:GetHeroEffectName() return "particles/units/heroes/hero_phoenix/phoenix_supernova_radiance.vpcf" end

function modifier_phoenix_supernova_pf_dmg:GetEffectAttachType() return PATTACH_WORLDORIGIN end

function modifier_phoenix_supernova_pf_dmg:OnCreated()

	if not IsServer() then
		return
	end
	local target = self:GetParent()
	local caster = self:GetCaster()
	self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_radiance_streak_light.vpcf", PATTACH_POINT_FOLLOW, target)
	-- The fucking particle I can't do
	ParticleManager:SetParticleControlEnt( self.pfx, 8, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true )



end

function modifier_phoenix_supernova_pf_dmg:OnDestroy()
	if not IsServer() then
		return
	end
	ParticleManager:DestroyParticle(self.pfx, false)
	ParticleManager:ReleaseParticleIndex(self.pfx)
end

function modifier_phoenix_supernova_pf_dmg:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP
	}
end

function modifier_phoenix_supernova_pf_dmg:OnTooltip()
	return self:GetAbility():GetSpecialValueFor("damage_per_sec")
end


------------------------------------------------------
-------------------------------------------------------
--- Black Hole modifiers
------------------------------------------------------
------------------------------------------------------

modifier_ability_black_hole_debuff = {}

function modifier_ability_black_hole_debuff:IsHidden()
	return true
end

function modifier_ability_black_hole_debuff:IsDebuff()
	return true
end

function modifier_ability_black_hole_debuff:IsStunDebuff()
	return true
end

function modifier_ability_black_hole_debuff:IsPurgable()
	return true
end

function modifier_ability_black_hole_debuff:OnCreated( kv )
	self.rate = 0.2 --animation rate
	self.pull_speed = 30
	self.rotate_speed = 0.25

	if IsServer() then
		self.center = Vector( kv.aura_origin_x, kv.aura_origin_y, 0 )

		if self:ApplyHorizontalMotionController() == false then
			self:Destroy()
		end
	end
end

function modifier_ability_black_hole_debuff:OnRefresh( kv )
	
end

function modifier_ability_black_hole_debuff:OnRemoved()
end

function modifier_ability_black_hole_debuff:OnDestroy()
	if IsServer() then
		self:GetParent():InterruptMotionControllers( true )
	end
end

function modifier_ability_black_hole_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
	}

	return funcs
end

function modifier_ability_black_hole_debuff:GetOverrideAnimation()
	if not self:GetParent():HasModifier("modifier_absolute_no_cc") then
		return ACT_DOTA_FLAIL
	end
end

function modifier_ability_black_hole_debuff:GetOverrideAnimationRate()
	return self.rate
end

function modifier_ability_black_hole_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function modifier_ability_black_hole_debuff:UpdateHorizontalMotion( me, dt )
	local target = self:GetParent():GetOrigin()-self.center
	target.z = 0

	local targetL = target:Length2D()-self.pull_speed*dt

	local targetN = target:Normalized()
	local deg = math.atan2( targetN.y, targetN.x )
	local targetN = Vector( math.cos(deg+self.rotate_speed*dt), math.sin(deg+self.rotate_speed*dt), 0 );

	self:GetParent():SetOrigin( self.center + targetN * targetL )


end

function modifier_ability_black_hole_debuff:OnHorizontalMotionInterrupted()
	self:Destroy()
end

---------- ----------- ----------
---------- ----------- ----------
---------- ----------- ----------

modifier_ability_black_hole_thinker = {}

function modifier_ability_black_hole_thinker:IsHidden()
	return true
end

function modifier_ability_black_hole_thinker:IsPurgable()
	return false
end

function modifier_ability_black_hole_thinker:OnCreated( kv )
	self.radius = 420
	self.interval = 1
	self.ticks = math.floor(self:GetDuration()/self.interval+0.5)
	self.tick = 0

	if IsServer() then
		local damage = self:GetCaster():GetMaxHealth() / 100 * self:GetCaster():FindAbilityByName("pathfinder_supernova_blackhole"):GetLevelSpecialValueFor("self_max_hp_dps",1)
		self.damageTable = {
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self:GetAbility(),
		}

		self:StartIntervalThink( self.interval )

		local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
		ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )

		self:AddParticle(
			effect_cast,
			false,
			false,
			-1,
			false,
			false
		)

		EmitSoundOn( "Hero_Enigma.Black_Hole", self:GetParent() )
	end
end

function modifier_ability_black_hole_thinker:OnRemoved()
	if IsServer() then
		if self:GetRemainingTime()<0.01 and self.tick<self.ticks then
			self:OnIntervalThink()
		end

		UTIL_Remove( self:GetParent() )
	end

	StopSoundOn( "Hero_Enigma.Black_Hole", self:GetParent() )
	EmitSoundOn( "Hero_Enigma.Black_Hole.Stop", self:GetParent() )
end

function modifier_ability_black_hole_thinker:OnIntervalThink()
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),
		self:GetParent():GetOrigin(),
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		0,
		false
	)

	for _,enemy in pairs(enemies) do
		self.damageTable.victim = enemy
		ApplyDamage( self.damageTable )
	end

	self.tick = self.tick + 1
end

function modifier_ability_black_hole_thinker:IsAura()
	return true
end

function modifier_ability_black_hole_thinker:GetModifierAura()
	return "modifier_ability_black_hole_debuff"
end

function modifier_ability_black_hole_thinker:GetAuraRadius()
	return self.radius
end

function modifier_ability_black_hole_thinker:GetAuraDuration()
	return 0.1
end

function modifier_ability_black_hole_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_ability_black_hole_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_ability_black_hole_thinker:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

--------------------
--------------------
--------------------

modifier_phoenix_supernova_allies_checker = modifier_phoenix_supernova_allies_checker or class({})

function modifier_phoenix_supernova_allies_checker:IsDebuff()				return false end
function modifier_phoenix_supernova_allies_checker:IsHidden() 				return true end
function modifier_phoenix_supernova_allies_checker:IsPurgable() 				return false end
function modifier_phoenix_supernova_allies_checker:RemoveOnDeath() 			return false end
