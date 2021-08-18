require( "utility_functions" )
LinkLuaModifier("pathfinder_lc_press", "pathfinder/pathfinder_legion_commander", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pathfinder_lc_press", "pathfinder/pathfinder_legion_commander", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_press_bkb", "pathfinder/pathfinder_legion_commander", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pathfinder_lc_press_blademail", "pathfinder/pathfinder_legion_commander", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_pathfinder_lc_moment", "pathfinder/pathfinder_legion_commander", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pathfinder_lc_moment_attack", "pathfinder/pathfinder_legion_commander", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pathfinder_special_lc_moment_aura", "pathfinder/pathfinder_legion_commander", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_pathfinder_lc_arrows_movespeed", "pathfinder/pathfinder_legion_commander", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pathfinder_lc_arrows_kill_detector", "pathfinder/pathfinder_legion_commander", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_pathfinder_lc_duel_taunted", "pathfinder/pathfinder_legion_commander", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pathfinder_lc_duel_taunted_target", "pathfinder/pathfinder_legion_commander", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pathfinder_lc_duel_bonus", "pathfinder/pathfinder_legion_commander", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pathfinder_lc_duel_purge", "pathfinder/pathfinder_legion_commander", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pathfinder_lc_duel_arrows", "pathfinder/pathfinder_legion_commander", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_pathfinder_lc_soldier_passive", "pathfinder/pathfinder_legion_commander", LUA_MODIFIER_MOTION_NONE)

require("libraries.timers")
require("libraries.has_shard")	

pathfinder_lc_arrows = class({})

function Precache(context)
	PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_legion_commander.vsndevts", context)
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_mars.vsndevts", context )	
end

function pathfinder_lc_arrows:GetIntrinsicModifierName()	
	return "modifier_pathfinder_lc_arrows_kill_detector"
end

function pathfinder_lc_arrows:OnAbilityPhaseStart()	
	if IsServer() then		
		local cast = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_odds_cast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(cast, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(cast)
	end
	EmitSoundOn("Hero_LegionCommander.Overwhelming.Cast",self:GetCaster())
	return true
end

function pathfinder_lc_arrows:GetCastRange(vLocation, hTarget)
	return self:GetLevelSpecialValueFor("arrows_range", self:GetLevel() - 1)
end

function pathfinder_lc_arrows:GetAOERadius()	
	return self:GetLevelSpecialValueFor("arrows_radius", self:GetLevel() - 1)
end

function pathfinder_lc_arrows:OnSpellStart()	
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	EmitSoundOn("Hero_LegionCommander.Overwhelming.Location",self:GetCaster())	

	local arrows_radius = self:GetLevelSpecialValueFor("arrows_radius", self:GetLevel() -1)

	local aoe_vector = Vector(arrows_radius, arrows_radius, arrows_radius)	
	local enemies = FindRadiusPoint(caster, point, arrows_radius, true)

	local nFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_legion_commander/legion_commander_odds.vpcf", PATTACH_CUSTOMORIGIN, caster )	
	ParticleManager:SetParticleControl( nFxIndex, 0, point )
	ParticleManager:SetParticleControl( nFxIndex, 1, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( nFxIndex, 4, aoe_vector )	
	ParticleManager:ReleaseParticleIndex( nFxIndex )
	local arrows_base_damage = self:GetLevelSpecialValueFor("arrows_base_damage", self:GetLevel() - 1)
	local arrows_damage_per_unit = self:GetLevelSpecialValueFor("arrows_damage_per_unit", self:GetLevel() - 1)	
	local arrows_movespeed_duration = self:GetLevelSpecialValueFor("arrows_movespeed_duration", self:GetLevel() - 1)	
	local arrows_damage = arrows_base_damage + #enemies * arrows_damage_per_unit	

	if IsServer() and self:GetCaster():HasAbility("pathfinder_special_lc_arrows_meteor") then
		Timers:CreateTimer(0.25, function()
			local nFxIndex = ParticleManager:CreateParticle( "particles/items4_fx/meteor_hammer_spell.vpcf", PATTACH_CUSTOMORIGIN, caster )	
			ParticleManager:SetParticleControl( nFxIndex, 0, caster:GetAbsOrigin() + Vector(0,0,1000))
			ParticleManager:SetParticleControl( nFxIndex, 1, point )
			ParticleManager:SetParticleControl( nFxIndex, 2, Vector(0.5,0,0) )	
			ParticleManager:ReleaseParticleIndex( nFxIndex )
			StartSoundEventFromPosition("DOTA_Item.MeteorHammer.Impact", point)
			Timers:CreateTimer(0.5, function()
				local targets = FindRadiusPoint(caster, point, arrows_radius, true)
				for _,enemy in pairs(targets) do
				if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then			
						local damage =
						{
							victim = enemy,
							attacker = self:GetCaster(),
							damage = arrows_base_damage,
							damage_type = self:GetAbilityDamageType(),
							ability = self,
						}
						ApplyDamage( damage )
						enemy:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = self:GetCaster():FindAbilityByName("pathfinder_special_lc_arrows_meteor"):GetLevelSpecialValueFor("stun_duration", 1)})
					end
				end
			end)
    	return nil
		end)		
	end	

	for _,enemy in pairs(enemies) do
		if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then				
			local damage =
			{
				victim = enemy,
				attacker = self:GetCaster(),
				damage = arrows_damage,
				damage_type = self:GetAbilityDamageType(),
				ability = self,
			}
			ApplyDamage( damage )
		end
	end	
	if #enemies ~= 0 then
		for _,enemy in pairs(enemies) do			
			if self:GetCaster():HasModifier("modifier_pathfinder_lc_arrows_movespeed") then
				self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pathfinder_lc_arrows_movespeed", {duration = arrows_movespeed_duration})
				self:GetCaster():SetModifierStackCount("modifier_pathfinder_lc_arrows_movespeed", self:GetCaster(), self:GetCaster():GetModifierStackCount("modifier_pathfinder_lc_arrows_movespeed", self:GetCaster()) + 1)
			else
				self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pathfinder_lc_arrows_movespeed", {duration = arrows_movespeed_duration})
			end
		end
	end
end

modifier_pathfinder_lc_arrows_kill_detector =  class({})

function modifier_pathfinder_lc_arrows_kill_detector:IsHidden()
	return true
end

function modifier_pathfinder_lc_arrows_kill_detector:IsPurgable()
	return false
end

function modifier_pathfinder_lc_arrows_kill_detector:DeclareFunctions()
	local funcs = {MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT ,}
	return funcs
end

function modifier_pathfinder_lc_arrows_kill_detector:OnTakeDamageKillCredit( params )
	if IsServer() then		
		if params.inflictor and params.inflictor == self:GetAbility() and self:GetParent():HasAbility("pathfinder_special_lc_arrows_reset") and self:GetParent():HasAbility("pathfinder_lc_duel") and params.damage >= params.target:GetHealth() then 			
			local nFxIndex = ParticleManager:CreateParticle( "particles/items2_fx/refresher.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )	
			ParticleManager:SetParticleControl( nFxIndex, 0, self:GetCaster():GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(nFxIndex)
			self:GetParent():FindAbilityByName("pathfinder_lc_duel"):EndCooldown()
			self:GetParent():FindAbilityByName("pathfinder_lc_arrows"):EndCooldown()
			self:GetParent():FindAbilityByName("pathfinder_lc_duel"):EndCooldown()
			self:GetParent():FindAbilityByName("pathfinder_lc_press"):EndCooldown()
        end 
    end 
end


modifier_pathfinder_lc_arrows_movespeed =  class({})

function modifier_pathfinder_lc_arrows_movespeed:IsHidden()
	return false
end
function modifier_pathfinder_lc_arrows_movespeed:IsDebuff()
	return false
end
function modifier_pathfinder_lc_arrows_movespeed:IsPurgable()
	return true
end

function modifier_pathfinder_lc_arrows_movespeed:GetEffectName()
	return "particles/units/heroes/hero_legion_commander/legion_commander_odds_buff.vpcf"
end

function modifier_pathfinder_lc_arrows_movespeed:GetActivityTranslationModifiers()
    return "haste"
end


function modifier_pathfinder_lc_arrows_movespeed:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}
	return funcs
end

function modifier_pathfinder_lc_arrows_movespeed:GetModifierMoveSpeedBonus_Percentage( params )
	return self:GetAbility():GetSpecialValueFor("arrows_movespeed_per_unit") * self:GetAbility():GetCaster():GetModifierStackCount("modifier_pathfinder_lc_arrows_movespeed", self:GetAbility():GetCaster())
end

function modifier_pathfinder_lc_arrows_movespeed:GetModifierIgnoreMovespeedLimit(params)
    return 1
end


-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
-- PRESS THE Attack

-----------------------------------------------------------------
-----------------------------------------------------------------


pathfinder_lc_press = class({})

function Precache(context)
	PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_legion_commander.vsndevts", context)
end

function pathfinder_lc_press:OnSpellStart()	
	if IsServer() then		
		local target = self:GetCursorTarget()
		local caster = self:GetCaster()

		local halo_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_press_hero.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(halo_particle, 0, caster:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(halo_particle)

		target:EmitSoundParams("Hero_LegionCommander.PressTheAttack", 0, 0.7, 0)
		
		if target.press_particle then
			ParticleManager:DestroyParticle(target.press_particle, true)
			ParticleManager:ReleaseParticleIndex(target.press_particle)
			target.press_particle = nil
		end

		target.press_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_press.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(target.press_particle, 0, target:GetAbsOrigin())
			ParticleManager:SetParticleControl(target.press_particle, 1, target:GetAbsOrigin())
			ParticleManager:SetParticleControlEnt(target.press_particle, 2, target, PATTACH_POINT_FOLLOW, "attach_attack1", target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(target.press_particle, 3, target:GetAbsOrigin())
		target:AddNewModifier(self:GetCaster(), self, "modifier_pathfinder_lc_press", {duration = self:GetLevelSpecialValueFor("press_duration", self:GetLevel() - 1)})	

		if self:GetCaster():HasAbility("pathfinder_special_lc_press_blademail") then
			target:AddNewModifier(self:GetCaster(), self, "modifier_pathfinder_lc_press_blademail", {duration = self:GetLevelSpecialValueFor("press_duration", self:GetLevel() - 1)})	
		end
		if self:GetCaster():HasAbility("pathfinder_special_lc_press_bkb") then
			target:AddNewModifier(self:GetCaster(), self, "modifier_press_bkb", {duration = self:GetLevelSpecialValueFor("press_duration", self:GetLevel() - 1)})	
		end		
	end	
	return true
end

function pathfinder_lc_press:GetCastRange()
	return self:GetLevelSpecialValueFor("press_range", self:GetLevel() - 1)
end

modifier_pathfinder_lc_press = class({})

function modifier_pathfinder_lc_press:IsHidden()
	return false
end

function modifier_pathfinder_lc_press:IsPurgable()
	return true
end

function modifier_pathfinder_lc_press:IsDebuff()
	return false
end

function modifier_pathfinder_lc_press:OnCreated(table)
	if IsServer() then
		self:GetParent():Purge(false, true, false, true, true)		
	end
	self.press = self:GetAbility()	
end

function modifier_pathfinder_lc_press:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,								
				MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT ,
			}
	return funcs
end


function modifier_pathfinder_lc_press:GetModifierAttackSpeedBonus_Constant()	
	local value = self.press:GetLevelSpecialValueFor("press_attack", self.press:GetLevel() - 1)	
	return value
end

function modifier_pathfinder_lc_press:GetModifierConstantHealthRegen()	
	local value = self.press:GetLevelSpecialValueFor("press_regen", self.press:GetLevel() - 1)	
	return value
end


function modifier_pathfinder_lc_press:OnDestroy()
	if not IsServer() then return end	
	if self:GetParent().press_particle then
		ParticleManager:DestroyParticle(self:GetParent().press_particle, false)
		ParticleManager:ReleaseParticleIndex(self:GetParent().press_particle)
		self:GetParent().press_particle = nil
	end
end

modifier_pathfinder_lc_press_blademail = class( {} )
function modifier_pathfinder_lc_press_blademail:IsPurgable() return true end
function modifier_pathfinder_lc_press_blademail:IsHidden() return true end
function modifier_pathfinder_lc_press_blademail:IsDebuff() return false end

function modifier_pathfinder_lc_press_blademail:GetEffectName()	
	return "particles/units/heroes/hero_nyx_assassin/nyx_assassin_spiked_carapace.vpcf"	
end

function modifier_pathfinder_lc_press_blademail:GetStatusEffectName()	
	return "particles/status_fx/status_effect_blademail.vpcf"	
end

function modifier_pathfinder_lc_press_blademail:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_TAKEDAMAGE}

	return decFuncs
end

function modifier_pathfinder_lc_press_blademail:OnTakeDamage(keys)
	if not IsServer() then return end
	
	local attacker = keys.attacker
	local target = keys.unit
	local original_damage = keys.original_damage
	local damage_type = keys.damage_type
	local damage_flags = keys.damage_flags

	if keys.unit == self:GetParent() and not keys.attacker:IsBuilding() and keys.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bitand(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bitand(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then	
		if not keys.unit:IsOther() then
			EmitSoundOnClient("DOTA_Item.BladeMail.Damage", keys.attacker:GetPlayerOwner())
		
			local damageTable = {
				victim			= keys.attacker,
				damage			= keys.original_damage / 100 * self:GetAbility():GetCaster():FindAbilityByName("pathfinder_special_lc_press_blademail"):GetLevelSpecialValueFor("percent",1),
				damage_type		= keys.damage_type,
				damage_flags	= DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
				attacker		= self:GetParent(),
				ability			= self:GetAbility()
			}
			
			local reflectDamage = ApplyDamage(damageTable)
		end
	end
end



modifier_press_bkb = class({})

function modifier_press_bkb:OnCreated()	
	if IsServer() then	
		self.magic_resist = self:GetCaster():FindAbilityByName("pathfinder_special_lc_press_bkb"):GetLevelSpecialValueFor("magic_resist",1)
		self.status_resist = self:GetCaster():FindAbilityByName("pathfinder_special_lc_press_bkb"):GetLevelSpecialValueFor("status_resist",1)
		self:SetHasCustomTransmitterData( true )
	end
end

function modifier_press_bkb:GetEffectName()		
	return "particles/units/heroes/hero_chen/chen_divine_favor_buff.vpcf"	
end

function modifier_press_bkb:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end
function modifier_press_bkb:GetModifierMagicalResistanceBonus()
	return self.magic_resist
end
function modifier_press_bkb:GetModifierStatusResistanceStacking()
	return self.status_resist
end

function modifier_press_bkb:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS ,	
				MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING ,											
			}
	return funcs
end

function modifier_press_bkb:AddCustomTransmitterData( )
	return
	{
		magic_resist = self.magic_resist,
		status_resist = self.status_resist,
	}
end

function modifier_press_bkb:HandleCustomTransmitterData( data )
	self.magic_resist = data.magic_resist
	self.status_resist = data.status_resist
end




pathfinder_lc_moment = class({})

function pathfinder_lc_moment:GetIntrinsicModifierName()
	return "modifier_pathfinder_lc_moment"
end



modifier_pathfinder_lc_moment = class({})

function modifier_pathfinder_lc_moment:OnCreated()
	if IsServer() and self:GetParent() == self:GetCaster() and self:GetCaster():HasAbility("pathfinder_special_lc_moment_aura") then
		
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pathfinder_special_lc_moment_aura", {})
	end
end


function modifier_pathfinder_lc_moment:GetEffectName()	
	if self:GetParent() ~= self:GetCaster() then
		return "particles/units/heroes/hero_legion_commander/legion_commander_duel_buff.vpcf"
	end
end

function modifier_pathfinder_lc_moment:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function modifier_pathfinder_lc_moment:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ATTACKED,												
			}
	return funcs
end

function modifier_pathfinder_lc_moment:IsHidden()
	if self:GetParent() == self:GetCaster() then
		return true
	else 
		return fasle
	end
end

function modifier_pathfinder_lc_moment:IsPurgable()
	return false
end

function modifier_pathfinder_lc_moment:IsDebuff()
	return false
end

function modifier_pathfinder_lc_moment:OnAttacked(params)
	require("libraries.has_shard")
	if not IsServer() then return end
	if RandomInt(1,100) < self:GetCaster():FindAbilityByName("pathfinder_lc_moment"):GetLevelSpecialValueFor("moment_chance", self:GetCaster():FindAbilityByName("pathfinder_lc_moment"):GetLevel() - 1) then
		if self:GetCaster():FindAbilityByName("pathfinder_lc_moment"):IsCooldownReady()  and not self:GetCaster():FindAbilityByName("pathfinder_lc_moment"):GetCaster():PassivesDisabled() and self:GetParent():IsAttacking() and not self:GetParent():GetAttackTarget():IsBuilding() then
			self:GetParent():PerformAttack( self:GetParent():GetAttackTarget(), true, true, true, true, false, false, true)
			local lifesteal = self:GetCaster():FindAbilityByName("pathfinder_lc_moment"):GetLevelSpecialValueFor("moment_lifesteal", self:GetCaster():FindAbilityByName("pathfinder_lc_moment"):GetLevel() -1)
			local heal = self:GetParent():GetAverageTrueAttackDamage(nil) / 100 * (100 + lifesteal)
			self:GetParent():Heal(heal, nil)

			if self:GetParent() == self:GetCaster() then
				self:GetCaster():FindAbilityByName("pathfinder_lc_moment"):StartCooldown(self:GetCaster():FindAbilityByName("pathfinder_lc_moment"):GetCooldown(self:GetCaster():FindAbilityByName("pathfinder_lc_moment"):GetLevel() -1))
			--self:GetAbility():GetCaster():StartGesture(ACT_DOTA_CAST3_STATUE)
			end
			EmitSoundOn("Hero_LegionCommander.Courage", self:GetParent())

			local moment_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_courage_tgt_rope.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent():GetAttackTarget())	
			ParticleManager:SetParticleControl(moment_particle, 0, self:GetParent():GetAttackTarget():GetAbsOrigin())
			ParticleManager:SetParticleControlEnt( moment_particle, 2, self:GetParent():GetAttackTarget(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAttackTarget():GetAbsOrigin(), false )
			ParticleManager:SetParticleControlEnt( moment_particle, 3, self:GetParent():GetAttackTarget(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAttackTarget():GetAbsOrigin(), false )
			ParticleManager:ReleaseParticleIndex(moment_particle)

			if self:GetParent():HasAbility("pathfinder_special_lc_moment_aoe") then 
				local radius = self:GetParent():FindAbilityByName("pathfinder_special_lc_moment_aoe"):GetLevelSpecialValueFor("radius",1)
				local enemies = FindRadius(self:GetParent(), radius, true)
				local extra_targets = self:GetParent():FindAbilityByName("pathfinder_special_lc_moment_aoe"):GetLevelSpecialValueFor("extra_targets",1)
				local current_count = 0
				for _,enemy in pairs(enemies) do 					
					if enemy ~= self:GetParent():GetAttackTarget() and current_count < extra_targets then
						self:GetParent():PerformAttack( enemy, true, true, true, true, false, false, true)
						self:GetParent():Heal(heal, nil)
						moment_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_courage_tgt_rope.vpcf", PATTACH_CUSTOMORIGIN, enemy)	
						ParticleManager:SetParticleControl(moment_particle, 0, enemy:GetAbsOrigin())
						ParticleManager:SetParticleControlEnt( moment_particle, 2, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), false )
						ParticleManager:SetParticleControlEnt( moment_particle, 3, enemy, PATTACH_POINT_FOLLOW, "attach_attack1", enemy:GetAbsOrigin(), false )
						ParticleManager:ReleaseParticleIndex(moment_particle)
						current_count = current_count + 1
					end
				end
			end

			require("libraries.timers")
			self:GetParent():AddNewModifier(self:GetParent(), self, "modifier_pathfinder_lc_moment_attack", {duration = 0.5})					
		end
	end
end


modifier_pathfinder_lc_moment_attack = class({})

function modifier_pathfinder_lc_moment_attack:GetStatusEffectName()
	return "particles/status_fx/status_effect_legion_commander_duel.vpcf"
end

function modifier_pathfinder_lc_moment_attack:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_pathfinder_lc_moment_attack:IsHidden()
	return true
end

function modifier_pathfinder_lc_moment_attack:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,		
	}
	return funcs
end

function modifier_pathfinder_lc_moment_attack:GetOverrideAnimation()
	if self:GetParent():GetUnitName() == "npc_dota_hero_legion_commander" then
		return ACT_DOTA_MOMENT_OF_COURAGE
	else
		return ACT_DOTA_ATTACK
	end
end


--------------------------------------------------
------ legion_commander_duel
--------------------

pathfinder_lc_duel = class({})

function pathfinder_lc_duel:Spawn()
	if not IsServer() then return end
	Timers(2, function()
		if self:GetCaster():FindAbilityByName("pathfinder_special_lc_duel_legion") and self:IsTrained() then
			for i=1,self:GetCaster():FindAbilityByName("pathfinder_special_lc_duel_legion"):GetLevelSpecialValueFor("soldier_count",1) do
				local spawn = self:GetCaster():GetAbsOrigin() + RandomVector( 165 )
				local soldier = CreateUnitByName( "pathfinder_lc_soldier", spawn, true, nil, nil, DOTA_TEAM_GOODGUYS )
				soldier:AddNewModifier(self:GetCaster(), self, "modifier_pathfinder_lc_soldier_passive", { } )		
				FindClearSpaceForUnit(soldier, soldier:GetAbsOrigin() , false)				
			end
			return nil
		else
			return 2
		end
	end)
end

function pathfinder_lc_duel:OnSpellStart()		
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	require("libraries.has_shard")

	-- if IsServer() and caster:HasAbility("pathfinder_special_lc_duel_legion") then
	-- 	local stat_percent = caster:FindAbilityByName("pathfinder_special_lc_duel_legion"):GetLevelSpecialValueFor("stat_percent",1)	
	-- 	local attack_damage = caster:GetAverageTrueAttackDamage(nil) / 100 * stat_percent

	-- 	local nearby = FindRadius(caster, 1000, true)

	-- 	for _,enemy in pairs(nearby) do 
	-- 		if enemy ~= target then
	-- 			local spawn = enemy:GetAbsOrigin() + RandomVector( 165 )
	-- 			local soldier = CreateUnitByName( "pathfinder_lc_soldier", spawn, true, nil, nil, DOTA_TEAM_GOODGUYS )
	-- 			soldier:AddNewModifier(nil, self, "modifier_kill", { duration = 2 * self:GetLevelSpecialValueFor("duel_duration", self:GetLevel() - 1) } )

	-- 			soldier:SetBaseDamageMax(attack_damage)
	-- 			soldier:SetBaseDamageMin(attack_damage)

	-- 			soldier:SetForceAttackTarget(enemy)
				
	-- 			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_duel_start_ring_energy.vpcf", PATTACH_ABSORIGIN, soldier)
	-- 			local center_point = soldier:GetAbsOrigin() --+ ((caster:GetAbsOrigin() - target:GetAbsOrigin()) / 200)			
	-- 			ParticleManager:SetParticleControl(particle, 7, center_point)  --The flag's position (also centered).
	-- 			ParticleManager:ReleaseParticleIndex(particle)
	-- 		end
	-- 	end
	-- end
	if IsServer() then
		self:GetCaster().main_duel_target = target
			EmitSoundOn("Hero_LegionCommander.Duel.Cast",self:GetCaster())
			EmitSoundOn("Hero_LegionCommander.Duel",self:GetCaster())
			caster.duel_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_duel_ring.vpcf", PATTACH_ABSORIGIN, caster)
			local center_point = caster:GetAbsOrigin() --+ ((caster:GetAbsOrigin() - target:GetAbsOrigin()) / 200)
			ParticleManager:SetParticleControl(caster.duel_particle, 0, center_point)  --The center position
			ParticleManager:SetParticleControl(caster.duel_particle, 7, center_point)  --The flag's position (also centered).

		-- if IsServer() and caster:HasAbility("pathfinder_special_lc_duel_legion") then
		-- 	local particle = ParticleManager:CreateParticle("particles/econ/items/centaur/centaur_ti6_gold/centaur_ti6_warstomp_gold_ring.vpcf", PATTACH_ABSORIGIN, self:GetCaster())					
		-- 	ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin()) 
		-- 	ParticleManager:SetParticleControl(particle, 1, Vector(700,0,0)) 
		-- 	ParticleManager:ReleaseParticleIndex(particle)
		-- end
	end

	caster.taunt_target = target
	target.taunt_caster = caster
	local duel_duration = self:GetLevelSpecialValueFor("duel_duration", self:GetLevel() - 1)

	if IsServer() then		
		caster:MoveToTargetToAttack( target ) -- for heroes
		caster:SetForceAttackTarget( target ) -- for creeps	
		caster:AddNewModifier(caster, self, "modifier_pathfinder_lc_duel_taunted", {duration = duel_duration})
		if target:GetUnitName() ~= "npc_dota_boss_aghanim" then
			target:MoveToTargetToAttack( caster ) -- for heroes
			target:SetForceAttackTarget(caster ) -- for creeps
			target:AddNewModifier(caster, self, "modifier_pathfinder_lc_duel_taunted_target", {duration = duel_duration})			
		end
	end			
end


function pathfinder_lc_duel:GetCastRange()		
	return self:GetLevelSpecialValueFor("duel_range", self:GetLevel() - 1)
end

function pathfinder_lc_duel:GetCastAnimation()		
	return ACT_DOTA_CAST_ABILITY_4
end

--------------------------------------=======

modifier_pathfinder_lc_duel_taunted = class({})

function modifier_pathfinder_lc_duel_taunted:IsHidden()
	return true
end

function modifier_pathfinder_lc_duel_taunted:IsDebuff()
	return false
end

function modifier_pathfinder_lc_duel_taunted:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end



function modifier_pathfinder_lc_duel_taunted:GetStatusEffectName()
	return "particles/status_fx/status_effect_legion_commander_duel.vpcf"
end

function modifier_pathfinder_lc_duel_taunted:GetEffectName()	
	return "particles/units/heroes/hero_legion_commander/legion_commander_duel_buff.vpcf"
end

function modifier_pathfinder_lc_duel_taunted:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function modifier_pathfinder_lc_duel_taunted:OnDestroy()
	if IsServer() then
		self:GetParent():SetForceAttackTarget( nil )
		StopSoundOn("Hero_LegionCommander.Duel",self:GetCaster())
		if self:GetParent().duel_particle then
			ParticleManager:DestroyParticle(self:GetParent().duel_particle, false)
			ParticleManager:ReleaseParticleIndex(self:GetParent().duel_particle)
		end
		if IsServer() and self:GetCaster():HasAbility("pathfinder_special_lc_duel_purge") and self.purge_ring then					
			ParticleManager:DestroyParticle(self.purge_ring, false)
			ParticleManager:ReleaseParticleIndex(self.purge_ring)			
		end
	end
end

function modifier_pathfinder_lc_duel_taunted:IsPurgable()
	return false
end

function modifier_pathfinder_lc_duel_taunted:DeclareFunctions()
	local funcs =
	{
		MODIFIER_EVENT_ON_DEATH,		
	}
	return funcs
end

function modifier_pathfinder_lc_duel_taunted:OnCreated()
	if IsServer() and self:GetCaster():HasAbility("pathfinder_special_lc_duel_purge") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_pathfinder_lc_duel_purge", {duration = self:GetCaster():FindAbilityByName("pathfinder_lc_duel"):GetLevelSpecialValueFor("duel_duration",1)})
	end
	if IsServer() and self:GetCaster():HasAbility("pathfinder_special_lc_duel_arrows")  and self:GetCaster().taunt_target then
		self:GetCaster().taunt_target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_pathfinder_lc_duel_arrows", {duration = self:GetCaster():FindAbilityByName("pathfinder_lc_duel"):GetLevelSpecialValueFor("duel_duration",1)})
	end
end


function modifier_pathfinder_lc_duel_taunted:OnDeath(kv)
	if IsServer() and self:GetParent() == kv.unit then						
		if self:GetCaster().taunt_target:HasModifier("modifier_pathfinder_lc_duel_taunted") then
			self:GetCaster().taunt_target:RemoveModifierByName("modifier_pathfinder_lc_duel_taunted")
		end
	end
end

function modifier_pathfinder_lc_duel_taunted:RemoveOnDeath()
	return true
end


function modifier_pathfinder_lc_duel_taunted:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_TAUNTED] = true,
	}
	return state
end

-----

modifier_pathfinder_lc_duel_taunted_target = class({})

function modifier_pathfinder_lc_duel_taunted_target:IsHidden()
	return true
end

function modifier_pathfinder_lc_duel_taunted_target:IsDebuff()
	return false
end

function modifier_pathfinder_lc_duel_taunted_target:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end



function modifier_pathfinder_lc_duel_taunted_target:GetStatusEffectName()
	return "particles/status_fx/status_effect_legion_commander_duel.vpcf"
end

function modifier_pathfinder_lc_duel_taunted_target:GetEffectName()	
	return "particles/units/heroes/hero_legion_commander/legion_commander_duel_buff.vpcf"
end

function modifier_pathfinder_lc_duel_taunted_target:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function modifier_pathfinder_lc_duel_taunted_target:OnDestroy()
	if IsServer() then
		self:GetParent():SetForceAttackTarget( nil )
	end
end

function modifier_pathfinder_lc_duel_taunted_target:IsPurgable()
	return false
end
function modifier_pathfinder_lc_duel_taunted_target:RemoveOnDeath()
	return true
end

function modifier_pathfinder_lc_duel_taunted_target:DeclareFunctions()
	local funcs =
	{
		MODIFIER_EVENT_ON_DEATH,		
	}
	return funcs
end


function modifier_pathfinder_lc_duel_taunted_target:OnDeath(kv)
	if IsServer() then		
		if self:GetParent() == kv.unit then --and kv.unit:HasModifier("modifier_pathfinder_lc_duel_taunted_target") then
			win_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster())	
			ParticleManager:SetParticleControlEnt( win_particle, 0, self:GetCaster(), PATTACH_OVERHEAD_FOLLOW, nil, self:GetCaster():GetAbsOrigin() + Vector( 0, 0, 96 ), false )
			ParticleManager:ReleaseParticleIndex(win_particle)
			EmitSoundOn("Hero_LegionCommander.Duel.Victory", self:GetCaster())
			self:GetCaster():SetCursorCastTarget(self:GetCaster())
			self:GetCaster():FindAbilityByName("pathfinder_lc_press"):OnSpellStart()
		
				
			local creep_dmg = self:GetAbility():GetLevelSpecialValueFor("duel_creep_damage", self:GetAbility():GetLevel() - 1)
			local hero_dmg = self:GetAbility():GetLevelSpecialValueFor("duel_hero_damage", self:GetAbility():GetLevel() - 1)

			local dmg = creep_dmg
			if self:GetParent():IsConsideredHero() then
				dmg = hero_dmg
			end

			local old_stack = 0
			if self:GetCaster():HasModifier("modifier_pathfinder_lc_duel_bonus") then			
				old_stack = self:GetCaster():GetModifierStackCount("modifier_pathfinder_lc_duel_bonus", self:GetCaster())
			end
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_pathfinder_lc_duel_bonus", {})
			self:GetCaster():SetModifierStackCount("modifier_pathfinder_lc_duel_bonus", self:GetCaster(), old_stack + dmg)	
			self:GetParent():RemoveModifierByName("modifier_pathfinder_lc_duel_taunted_target")
			if self:GetParent().taunt_caster:HasModifier("modifier_pathfinder_lc_duel_taunted") then
				self:GetParent().taunt_caster:RemoveModifierByName("modifier_pathfinder_lc_duel_taunted")
			end
		end		
	end
end


function modifier_pathfinder_lc_duel_taunted_target:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_TAUNTED] = true,
	}
	return state
end

-----------------

modifier_pathfinder_lc_duel_bonus = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_lc_duel_bonus:IsHidden()
	return false
end

function modifier_pathfinder_lc_duel_bonus:IsDebuff()
	return false
end

function modifier_pathfinder_lc_duel_bonus:IsPurgable()
	return false
end

function modifier_pathfinder_lc_duel_bonus:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------
function modifier_pathfinder_lc_duel_bonus:DeclareFunctions()
	local funcs_array = {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
						MODIFIER_EVENT_ON_DEATH,   }
    return funcs_array
end

function modifier_pathfinder_lc_duel_bonus:GetModifierPreAttack_BonusDamage( params )
	return self:GetParent():GetModifierStackCount("modifier_pathfinder_lc_duel_bonus", self:GetParent())
end

function modifier_pathfinder_lc_duel_bonus:OnDeath(kv)
	if IsServer() and kv.unit == self:GetParent() then
		local dmg = math.floor(self:GetParent():GetModifierStackCount("modifier_pathfinder_lc_duel_bonus", self:GetParent()) * 0.6)		
		self:GetParent():SetModifierStackCount("modifier_pathfinder_lc_duel_bonus", self:GetParent(), dmg)
	end
end


--------------------------------
-- SPECIAL SPECIAL IsSpeciallyDeniable()
-----
-------
----------
-------------------------
modifier_pathfinder_special_lc_moment_aura = class({})
function modifier_pathfinder_special_lc_moment_aura:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_pathfinder_special_lc_moment_aura:GetModifierAura()
	return  "modifier_pathfinder_lc_moment"
end

--------------------------------------------------------------------------------

function modifier_pathfinder_special_lc_moment_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_pathfinder_special_lc_moment_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_OTHER 
end

--------------------------------------------------------------------------------

function modifier_pathfinder_special_lc_moment_aura:GetAuraRadius()
	return self:GetParent():FindAbilityByName("pathfinder_special_lc_moment_aura"):GetLevelSpecialValueFor("radius",1)
end

function modifier_pathfinder_special_lc_moment_aura:IsHidden()
	return true
end
function modifier_pathfinder_special_lc_moment_aura:IsPurgable()
	return false
end

----
--
----
------

--
modifier_pathfinder_lc_duel_purge = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_lc_duel_purge:IsHidden()
	return true
end

function modifier_pathfinder_lc_duel_purge:IsDebuff()
	return false
end

function modifier_pathfinder_lc_duel_purge:IsPurgable()
	return true
end

function modifier_pathfinder_lc_duel_purge:RemoveOnDeath()
	return true
end

--------------------------------------------------------------------------------
function modifier_pathfinder_lc_duel_purge:OnCreated()
	self:StartIntervalThink(1)
	if IsServer() and self:GetCaster():HasAbility("pathfinder_special_lc_duel_purge") and self:GetCaster() == self:GetParent() then
		self.purge_ring =  ParticleManager:CreateParticle( "particles/items_fx/gem_truesight_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
		local radius = self:GetCaster():FindAbilityByName("pathfinder_special_lc_duel_purge"):GetLevelSpecialValueFor("radius",1)	
		ParticleManager:SetParticleControl(self.purge_ring, 0, self:GetCaster():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.purge_ring, 1, Vector(radius, 0 ,0))
		
		local duration = self:GetCaster():FindAbilityByName("pathfinder_lc_duel"):GetLevelSpecialValueFor("duel_duration",1)
		require("libraries.timers")
		Timers:CreateTimer(duration, function()
			if self.purge_ring then
				ParticleManager:DestroyParticle(self.purge_ring, false)
				ParticleManager:ReleaseParticleIndex(self.purge_ring)
			end
		end)
	end
end

function modifier_pathfinder_lc_duel_purge:OnIntervalThink()
	require("libraries.has_shard")
	if IsServer() and self:GetCaster():HasAbility("pathfinder_special_lc_duel_purge") then
		if self:GetParent() == self:GetCaster() then
			local heal_amount = self:GetCaster():GetMaxHealth() / 100 * self:GetCaster():FindAbilityByName("pathfinder_special_lc_duel_purge"):GetLevelSpecialValueFor("max_health_heal",1)
			local radius = self:GetCaster():FindAbilityByName("pathfinder_special_lc_duel_purge"):GetLevelSpecialValueFor("radius",1)
			local allies = FindRadius(self:GetCaster(),radius, false)
			for _,ally in pairs(allies) do
				if ally ~= nil and ally:IsConsideredHero() then 
					self:GetCaster():SetCursorCastTarget(ally)
					self:GetCaster():FindAbilityByName("pathfinder_lc_press"):OnSpellStart()
					ally:Heal(heal_amount, self:GetCaster())
				end
			end
		end
	end
end


--------------
--------
--
modifier_pathfinder_lc_duel_arrows = class({})
-- Classifications
function modifier_pathfinder_lc_duel_arrows:IsHidden()
	return true
end


function modifier_pathfinder_lc_duel_arrows:IsPurgable()
	return false
end

function modifier_pathfinder_lc_duel_arrows:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------
function modifier_pathfinder_lc_duel_arrows:OnCreated()
	self.target = self:GetParent():GetAbsOrigin()
	self:StartIntervalThink(1)	
end

function modifier_pathfinder_lc_duel_arrows:OnIntervalThink()
	require("libraries.has_shard")
	if IsServer() and self:GetCaster():HasAbility("pathfinder_special_lc_duel_arrows") then		
		self:GetCaster():SetCursorPosition(self.target)
		self:GetCaster():FindAbilityByName("pathfinder_lc_arrows"):OnSpellStart()
	end
end


-----------------
-----------------
-----------------

modifier_pathfinder_lc_soldier_passive = class({})
-- Classifications
function modifier_pathfinder_lc_soldier_passive:IsHidden()
	return true
end


function modifier_pathfinder_lc_soldier_passive:IsPurgable()
	return false
end

function modifier_pathfinder_lc_soldier_passive:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------
function modifier_pathfinder_lc_soldier_passive:OnCreated()
	if not IsServer() then return end
	self.lc = self:GetCaster()

	self:StartIntervalThink(2)	
end

function modifier_pathfinder_lc_soldier_passive:CheckState()
	if not IsServer() then return end
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}

	return state
end

function modifier_pathfinder_lc_soldier_passive:DeclareFunctions()
	local funcs_array = {MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS, 
						MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT,  }
    return funcs_array
end

function modifier_pathfinder_lc_soldier_passive:GetActivityTranslationModifiers()
	return "bulwark"
end


function modifier_pathfinder_lc_soldier_passive:OnIntervalThink()
	if not IsServer() then return end

	if self:GetParent():IsAlive() then
		if self.lc and IsValidEntity(self.lc) and self.lc:IsAlive() and not self.lc:PassivesDisabled() then
			owner_dmg = self.lc:GetAverageTrueAttackDamage(self.lc)
			dmg_pct = self:GetCaster():FindAbilityByName("pathfinder_special_lc_duel_legion"):GetLevelSpecialValueFor("stat_percent",1)
			self:GetParent():SetBaseDamageMax(owner_dmg / 100 * dmg_pct)
			self:GetParent():SetBaseDamageMin(owner_dmg / 100 * dmg_pct)

			ExecuteOrderFromTable({
				UnitIndex = self:GetParent():entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
				Position = self.lc:GetOrigin() + RandomVector(RandomFloat(200, 600))
			})		
			self:GetParent():RemoveModifierByName("modifier_stunned")
		else
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {})
		end
	else
		if self.lc:IsAlive() then
			self:GetParent():RemoveModifierByName("modifier_stunned")
		end
	end	
end

function modifier_pathfinder_lc_soldier_passive:OnTakeDamageKillCredit( params )
	if IsServer() then		
		if params.attacker and params.attacker == self:GetParent() and params.damage >= params.target:GetHealth() and params.target:GetAttackCapability() ~= DOTA_UNIT_CAP_NO_ATTACK then 			
			local reward_mult = self:GetCaster():FindAbilityByName("pathfinder_special_lc_duel_legion"):GetLevelSpecialValueFor("reward_percent",1) / 100
			win_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())	
			ParticleManager:SetParticleControlEnt( win_particle, 0, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, nil, self:GetParent():GetAbsOrigin() + Vector( 0, 0, 96 ), false )
			ParticleManager:ReleaseParticleIndex(win_particle)
			EmitSoundOn("Hero_LegionCommander.Duel.Victory", self:GetParent())			
				
			local creep_dmg = self:GetAbility():GetLevelSpecialValueFor("duel_creep_damage", self:GetAbility():GetLevel() - 1) * reward_mult
			local hero_dmg = self:GetAbility():GetLevelSpecialValueFor("duel_hero_damage", self:GetAbility():GetLevel() - 1) * reward_mult

			local dmg = creep_dmg
			if params.target:IsConsideredHero() then
				dmg = hero_dmg
			end

			local old_stack = 0
			if self:GetCaster():HasModifier("modifier_pathfinder_lc_duel_bonus") then			
				old_stack = self:GetCaster():GetModifierStackCount("modifier_pathfinder_lc_duel_bonus", self:GetCaster())
			end
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_pathfinder_lc_duel_bonus", {})
			self:GetCaster():SetModifierStackCount("modifier_pathfinder_lc_duel_bonus", self:GetCaster(), old_stack + dmg)				
        end 

		if params.attacker == self:GetParent() then
			local damageTable = {
					victim = params.target,
					attacker = self:GetCaster(),
					damage = 1,
					damage_type = DAMAGE_TYPE_PHYSICAL,
					ability = self:GetAbility(),
				}
			ApplyDamage(damageTable)
		end
    end 
end
