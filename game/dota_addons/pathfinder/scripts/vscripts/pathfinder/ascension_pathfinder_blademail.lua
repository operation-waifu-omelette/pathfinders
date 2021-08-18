ascension_pathfinder_blademail = class( {} )
LinkLuaModifier("modifier_ascension_pathfinder_blademail", "pathfinder/ascension_pathfinder_blademail", LUA_MODIFIER_MOTION_NONE)
-----------------------------------------------------------------------------------------
require( "utility_functions" )
require("libraries.timers")

--------------------------------------------------------------------------------


function ascension_pathfinder_blademail:OnSpellStart()

	if not IsServer() then
		return
	end

	EmitSoundOn( "Hero_Terrorblade.PreAttack", self:GetCaster() )	
	self.nPreviewFX = ParticleManager:CreateParticle( "particles/dark_moon/darkmoon_creep_warning.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( self.nPreviewFX, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetOrigin(), true )
	ParticleManager:SetParticleControl( self.nPreviewFX, 1, Vector( 100, 100, 100 ) )
	ParticleManager:SetParticleControl( self.nPreviewFX, 15, Vector( 255, 26, 26 ) )

	Timers:CreateTimer(self:GetCastPoint(), function() 
		if self.nPreviewFX then
			ParticleManager:DestroyParticle(self.nPreviewFX, false)
			ParticleManager:ReleaseParticleIndex(self.nPreviewFX)
		end
		EmitSoundOn( "DOTA_Item.BladeMail.Activate", self:GetCaster() )

		local flDuration = self:GetSpecialValueFor( "duration" )
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_ascension_pathfinder_blademail", { duration = flDuration } )
	end)	
end

--------------------------------
-- BLADE MAIL ACTIVE MODIFIER --
--------------------------------
modifier_ascension_pathfinder_blademail = class( {} )
function modifier_ascension_pathfinder_blademail:IsPurgable() return true end
function modifier_ascension_pathfinder_blademail:IsHidden() return false end

function modifier_ascension_pathfinder_blademail:GetEffectName()	
	return "particles/units/heroes/hero_nyx_assassin/nyx_assassin_spiked_carapace.vpcf"	
end

function modifier_ascension_pathfinder_blademail:GetStatusEffectName()	
	return "particles/status_fx/status_effect_blademail.vpcf"	
end

function modifier_ascension_pathfinder_blademail:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_TAKEDAMAGE}

	return decFuncs
end

function modifier_ascension_pathfinder_blademail:OnDestroy()
	if not IsServer() then return end
	self:GetParent():EmitSound("DOTA_Item.BladeMail.Deactivate")
end

function modifier_ascension_pathfinder_blademail:OnTakeDamage(keys)
	if not IsServer() then return end
	
	local attacker = keys.attacker
	local target = keys.unit
	local original_damage = keys.original_damage / 100 * self:GetAbility():GetSpecialValueFor("percent")
	local damage_type = keys.damage_type
	local damage_flags = keys.damage_flags

	if not keys.attacker:IsMagicImmune() and keys.unit == self:GetParent() and not keys.attacker:IsBuilding() and keys.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bitand(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bitand(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then	
		if not keys.unit:IsOther() then
			EmitSoundOnClient("DOTA_Item.BladeMail.Damage", keys.attacker:GetPlayerOwner())
		
			local damageTable = {
				victim			= keys.attacker,
				damage			= keys.original_damage,
				damage_type		= DAMAGE_TYPE_MAGICAL,
				damage_flags	= DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
				attacker		= self:GetParent(),
				ability			= self:GetAbility()
			}
			
			local reflectDamage = ApplyDamage(damageTable)
		end
	end
end

