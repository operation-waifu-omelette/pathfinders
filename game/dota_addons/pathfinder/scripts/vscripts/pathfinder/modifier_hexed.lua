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
modifier_hexed = class({})

require("constants")

--------------------------------------------------------------------------------
-- Classifications
function modifier_hexed:IsHidden()
	return false
end

function modifier_hexed:GetTexture()
	return "buyback"
end

function modifier_hexed:IsDebuff()
	return true
end

function modifier_hexed:IsPurgable()
	return false
end

function modifier_hexed:RemoveOnDeath()
	return false
end
require("libraries.has_shard")
require("constants")
-- Initializations
function modifier_hexed:OnCreated( kv )
	-- references
	self.base_speed = 350
	

	local models = courier_models

	self.model = models[RandomInt(1, #models)]
	self.patron_effect = nil

	if IsServer() then
		-- play effects
		self:PlayEffects( true )
		local table = AddPatronEffect(self:GetParent())
		self.model = table[2]
		self.patron_effect = table[1]
		self.scale = table[3]
		if self.patron_effect then 			
			self.effect = ParticleManager:CreateParticle( self.patron_effect, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			ParticleManager:SetParticleControlEnt( self.effect, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
			ParticleManager:SetParticleControlEnt( self.effect, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
			
		end
		--self:GetParent():SetModelScale(1.13)
		-- self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_nyx_assassin_vendetta_break", {})
		if self:GetParent():HasModifier("modifier_phoenix_sun_ray_pf_caster_dummy") then
			self:GetParent():RemoveModifierByName("modifier_phoenix_sun_ray_pf_caster_dummy")
		end
	end
end

function modifier_hexed:OnRefresh( kv )
	-- references
	self.base_speed = self:GetAbility():GetSpecialValueFor( "movespeed" )
	if IsServer() then
		-- play effects
		self:PlayEffects( true )
	end
end

function modifier_hexed:OnDestroy( kv )
	if IsServer() then
		-- play effects
		self:PlayEffects( false )
		--self:GetParent():SetModelScale(1)
		if self.effect then
			ParticleManager:DestroyParticle(self.effect, false)
			ParticleManager:ReleaseParticleIndex(self.effect)
		end
		-- self:GetParent():RemoveModifierByName("modifier_nyx_assassin_vendetta_break")
	end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_hexed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
	}
	return funcs
end

function modifier_hexed:GetModifierMoveSpeed_Absolute()
	return self.base_speed
end
function modifier_hexed:GetModifierModelChange()
	return self.model
end
function modifier_hexed:GetModifierHPRegenAmplify_Percentage( params )
	return -100
end

function modifier_hexed:GetModifierModelScale()
	if not IsServer() then return end
	local playerID = tostring(PlayerResource:GetSteamID(self:GetParent():GetPlayerOwnerID()))

	for id,table in pairs(patron_id) do
		if playerID == id then
			
			return table.model_scale
			
		end
	end
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_hexed:CheckState()
	local state = {	}
	if IsServer() then
		state = {[MODIFIER_STATE_DISARMED] = true,
				[MODIFIER_STATE_SILENCED] = true,
				[MODIFIER_STATE_MUTED] = true,
				[MODIFIER_STATE_PASSIVES_DISABLED] = true,
				[MODIFIER_STATE_FLYING]	= false,
				}
	end

	return state
end



--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_hexed:PlayEffects( bStart )
	local sound_cast = "Hero_Lion.Hex.Target"
	local particle_cast = "particles/units/heroes/hero_shadowshaman/shadowshaman_voodoo.vpcf"

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_hexed:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 1000
end

function modifier_hexed:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function modifier_hexed:GetStatusEffectName()	
	if tostring(PlayerResource:GetSteamID(self:GetParent():GetPlayerOwnerID())) == "76561198107181525" then --hardcode for snike
		return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_gold_lvl2.vpcf"
	end
end
