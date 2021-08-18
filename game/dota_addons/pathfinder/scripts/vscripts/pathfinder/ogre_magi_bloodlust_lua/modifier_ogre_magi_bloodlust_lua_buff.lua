-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]

--------------------------------------------------------------------------------
LinkLuaModifier( "modifier_ogre_magi_bloodlust_shield", "pathfinder/ogre_magi_bloodlust_lua/modifier_ogre_magi_bloodlust_lua_buff", LUA_MODIFIER_MOTION_NONE )

modifier_ogre_magi_bloodlust_lua_buff = class({})

function modifier_ogre_magi_bloodlust_lua_buff:Precache( context )
	PrecacheResource( "particle", "particles/status_fx/status_effect_earth_spirit_petrify.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/ogre/ogre_melee_smash.vpcf", context )
	
end

-----------------------------------------------------
-- Classifications
function modifier_ogre_magi_bloodlust_lua_buff:IsHidden()
	return false
end

function modifier_ogre_magi_bloodlust_lua_buff:IsDebuff()
	return false
end

function modifier_ogre_magi_bloodlust_lua_buff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_ogre_magi_bloodlust_lua_buff:OnCreated( kv )
	-- references
	self.model_scale = self:GetAbility():GetSpecialValueFor( "modelscale" )
	self.ms_bonus = self:GetAbility():GetSpecialValueFor( "bonus_movement_speed" )
	self.as_bonus = self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
	self.as_self = self:GetAbility():GetSpecialValueFor( "self_bonus" )

	if self:GetParent()==self:GetCaster() then
		self.as_bonus = self.as_bonus + self.as_self
	end
	

	if not IsServer() then return end

	-- play effects
	local sound_cast = "Hero_OgreMagi.Bloodlust.Target"
	EmitSoundOn( sound_cast, self:GetParent() )

	local sound_player = "Hero_OgreMagi.Bloodlust.Target.FP"
	EmitSoundOnClient( sound_player, self:GetParent():GetPlayerOwner() )	

	if self:GetCaster():FindAbilityByName("pathfinder_special_om_shield_bloodlust") then		
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ogre_magi_bloodlust_shield", {duration=self:GetDuration()})
	end
end


function modifier_ogre_magi_bloodlust_lua_buff:OnRefresh( kv )
	-- do what oncreated do
	self:OnCreated( kv )	
end

function modifier_ogre_magi_bloodlust_lua_buff:OnDestroy()

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_ogre_magi_bloodlust_lua_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MODEL_SCALE,						
	}

	return funcs
end


function modifier_ogre_magi_bloodlust_lua_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end


function modifier_ogre_magi_bloodlust_lua_buff:GetModifierAttackSpeedBonus_Constant()
	return self.as_bonus
end


--------------------------------------------------------------------------------
-- Graphics & Animations

function modifier_ogre_magi_bloodlust_lua_buff:GetEffectName()
	return "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf"
end

function modifier_ogre_magi_bloodlust_lua_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ogre_magi_bloodlust_lua_buff:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function modifier_ogre_magi_bloodlust_lua_buff:GetModifierModelScale( params )
	return self.model_scale
end


----
----
----
----

modifier_ogre_magi_bloodlust_shield = class({})

-- Classifications
function modifier_ogre_magi_bloodlust_shield:IsHidden()
	return false
end

function modifier_ogre_magi_bloodlust_shield:IsDebuff()
	return false
end

function modifier_ogre_magi_bloodlust_shield:IsPurgable()
	return false
end

function modifier_ogre_magi_bloodlust_shield:GetTexture()
	return "ogre_magi_smash"
end


function modifier_ogre_magi_bloodlust_shield:OnCreated()
	if not IsServer() then return end
	self.max_stacks = self:GetCaster():FindAbilityByName("pathfinder_special_om_shield_bloodlust"):GetLevelSpecialValueFor("layers", 1)
	self.targets = self:GetCaster():FindAbilityByName("pathfinder_special_om_shield_bloodlust"):GetLevelSpecialValueFor("targets", 1)
	self.shield_fx = ParticleManager:CreateParticle( "particles/units/heroes/hero_ogre_magi/ogre_magi_fire_shield.vpcf", PATTACH_CENTER_FOLLOW , self:GetParent() )
	ParticleManager:SetParticleControlEnt(  self.shield_fx, 0, self:GetParent(), PATTACH_CENTER_FOLLOW , nil, self:GetParent():GetOrigin(), true )
	ParticleManager:SetParticleControl( self.shield_fx, 1, Vector( self.max_stacks, 0, 0 ) )
	ParticleManager:SetParticleControl( self.shield_fx, 9, Vector( 1, 0, 0 ) )
	ParticleManager:SetParticleControl( self.shield_fx, 10, Vector( 1, 0, 0 ) )
	ParticleManager:SetParticleControl( self.shield_fx, 11, Vector( 1, 0, 0 ) )
	self:SetStackCount(self.max_stacks)
end

function modifier_ogre_magi_bloodlust_shield:RemoveLayer()
	if not IsServer() then return end

	if self:GetStackCount() <= 2 then
		ParticleManager:SetParticleControl( self.shield_fx, 9, Vector( 0, 0, 0 ) )
	end
	if self:GetStackCount() <= 1 then
		ParticleManager:SetParticleControl( self.shield_fx, 10, Vector( 0, 0, 0 ) )
	end

	local radius = self:GetCaster():FindAbilityByName("pathfinder_special_om_shield_bloodlust"):GetLevelSpecialValueFor("radius", 1)
	local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
				self:GetParent():GetAbsOrigin(),
				nil,
				radius,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
				FIND_ANY_ORDER,
				false)
	local current_count = 0		
	for _,enemy in pairs(enemies) do
		self:GetAbility():FireShieldProjectile(self:GetParent(), enemy)				
		current_count = current_count + 1
		if current_count > self.targets then
			break
		end
	end
end

function modifier_ogre_magi_bloodlust_shield:OnStackCountChanged(iStackCount)
	if not IsServer() then return end
	ParticleManager:SetParticleControl( self.shield_fx, 1, Vector( self:GetStackCount(), 0, 0 ) )
	if self:GetStackCount() <= 0 then
		self:Destroy()
	end
end

function modifier_ogre_magi_bloodlust_shield:OnRefresh()
	if not IsServer() then return end
	ParticleManager:SetParticleControl( self.shield_fx, 1, Vector( self:GetStackCount(), 0, 0 ) )	
end


function modifier_ogre_magi_bloodlust_shield:OnDestroy()	
	if not IsServer() or not self.shield_fx then return end
	ParticleManager:DestroyParticle(self.shield_fx, false)
	ParticleManager:ReleaseParticleIndex(self.shield_fx)
end

function modifier_ogre_magi_bloodlust_shield:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}

	return funcs
end

function modifier_ogre_magi_bloodlust_shield:GetModifierIncomingDamage_Percentage(keys)
	if not IsServer() then return end
	if keys.attacker and keys.damage and keys.damage >= 5 then
		self:GetParent():EmitSound("Hero_OgreMagi.Idle.Scratch")		
		self:DecrementStackCount()
		self:RemoveLayer()
		return -100
	end
end
