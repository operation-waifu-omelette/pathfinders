phantom_assassin_blur_lua = class({})
LinkLuaModifier( "modifier_phantom_assassin_blur_lua", "pathfinder/phantom_assassin_blur_lua/modifier_phantom_assassin_blur_lua", LUA_MODIFIER_MOTION_NONE )



--------------------------------------------------------------------------------
-- Passive Modifier
function phantom_assassin_blur_lua:GetIntrinsicModifierName()
	return "modifier_phantom_assassin_blur_lua"
end

function phantom_assassin_blur_lua:GetCastRange(vLocation, hTarget)
	return self:GetLevelSpecialValueFor("radius", self:GetLevel())
end

function phantom_assassin_blur_lua:OnSpellStart()
	self.in_grace_period = true
	require("libraries.timers")

	Timers:CreateTimer(2, function()
		self.in_grace_period = false		
    	return nil
	end)

	if self:GetCaster():HasAbility("pathfinder_special_pa_blur_block") then
		local special = self:GetCaster():FindAbilityByName("pathfinder_special_pa_blur_block")
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_absorb_spell", {duration = special:GetLevelSpecialValueFor("duration", 1)})	
	end

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_invisible", {duration = self:GetLevelSpecialValueFor("duration", 1)})	
	self:GetCaster():Purge(false, true, false, false, false)

	local nFxIndex = ParticleManager:CreateParticle( "particles/items2_fx/smoke_of_deceit.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( nFxIndex, 0, self:GetCaster(), PATTACH_ABSORIGIN, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
	ParticleManager:SetParticleControl( nFxIndex, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:DestroyParticle(nFxIndex, false)
	ParticleManager:ReleaseParticleIndex( nFxIndex )


	if IsServer() and self:GetCaster():HasAbility("pathfinder_special_pa_blur_aoe") then
		local special = self:GetCaster():FindAbilityByName("pathfinder_special_pa_blur_aoe")
		local friendlies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), self:GetCaster(), special:GetLevelSpecialValueFor("radius", 1), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, 0, false )

		for _,ally in pairs(friendlies) do
			ally:AddNewModifier(self:GetCaster(), self, "modifier_invisible", {duration = self:GetLevelSpecialValueFor("duration", 1)})				
			ally:Purge(false, true, false, false, false)
		end
	end
end


-----
modifier_phantom_assassin_blur_lua_aura = class({})
function modifier_phantom_assassin_blur_lua_aura:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_phantom_assassin_blur_lua_aura:GetModifierAura()
	return  "modifier_phantom_assassin_blur_lua"
end

--------------------------------------------------------------------------------

function modifier_phantom_assassin_blur_lua_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_phantom_assassin_blur_lua_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_OTHER 
end

--------------------------------------------------------------------------------

function modifier_phantom_assassin_blur_lua_aura:GetAuraRadius()
	return self:GetParent():FindAbilityByName("pathfinder_special_pa_blur_aoe"):GetLevelSpecialValueFor("radius",1)
end

function modifier_phantom_assassin_blur_lua_aura:IsHidden()
	return true
end
function modifier_phantom_assassin_blur_lua_aura:IsPurgable()
	return false
end