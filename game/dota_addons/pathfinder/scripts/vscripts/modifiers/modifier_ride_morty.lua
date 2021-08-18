
modifier_ride_morty = class({})
require("libraries.has_shard")
----------------------------------------------------------------------------------

function modifier_ride_morty:IsHidden()
	return true
end

----------------------------------------------------------------------------------
require("constants")
function modifier_ride_morty:IsPurgable()
	return false
end

-----------------------------------------------------------------------

function modifier_ride_morty:GetOverrideAnimation( params )
	return ACT_DOTA_RUN
end

----------------------------------------------------------------------------------

function modifier_ride_morty:OnCreated( kv )
	require("libraries.has_shard")

	local models = courier_models
	self.patron_effect = nil

	self.model = models[#models]
	if IsServer() then
		local table = AddPatronEffect(self:GetParent())
		self.model = table[2]
		self.patron_effect = table[1]
		self.scale = table[3]
		if self.patron_effect then 			
			self.effect = ParticleManager:CreateParticle( self.patron_effect, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			ParticleManager:SetParticleControlEnt( self.effect, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
			ParticleManager:SetParticleControlEnt( self.effect, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )

		end
		if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then 
			self:Destroy()
			return
		end
	end
end

--------------------------------------------------------------------------------

function modifier_ride_morty:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,		
	}

	return funcs
end

function modifier_ride_morty:GetModifierModelChange()
	return self.model
end

--------------------------------------------------------------------------------

function modifier_ride_morty:CheckState()
	local state =
	{
		[ MODIFIER_STATE_INVULNERABLE ] = true,
		[ MODIFIER_STATE_NO_HEALTH_BAR ] = true,
		[ MODIFIER_STATE_SILENCED ] = true,
		[ MODIFIER_STATE_UNSELECTABLE ] = true,
		[ MODIFIER_STATE_COMMAND_RESTRICTED ] = true,
	}	

	return state
end

--------------------------------------------------------------------------------

function modifier_ride_morty:UpdateHorizontalMotion( me, dt )
	if IsServer() then
		if self:GetCaster() then
			me:SetAbsOrigin( self:GetCaster():GetAbsOrigin() )

			local MortyAngles = self:GetCaster():GetAngles() 
			me:SetAbsAngles( MortyAngles.x, MortyAngles.y, MortyAngles.z )
		end
	end
end


--------------------------------------------------------------------------------

function modifier_ride_morty:UpdateVerticalMotion( me, dt )
	if IsServer() then
		if  self:GetCaster() then

			local vPos =  self:GetCaster():GetAbsOrigin()
			vPos.z = vPos.z + 50
			me:SetAbsOrigin( vPos )	
		end
	end
end


--------------------------------------------------------------------------------

function modifier_ride_morty:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveHorizontalMotionController( self )
		self:GetParent():RemoveVerticalMotionController( self )
		if self.effect then
			ParticleManager:DestroyParticle(self.effect, false)	
			ParticleManager:ReleaseParticleIndex(self.effect)
		end
	end
end


--------------------------------------------------------------------------------

function modifier_ride_morty:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

function modifier_ride_morty:GetStatusEffectName()
	if IsServer() and tostring(PlayerResource:GetSteamID(self:GetParent():GetPlayerOwnerID())) == "76561198107181525" then --hardcode for snike
		return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_gold_lvl2.vpcf"
	end
end

--------------------------------------------------------------------------------

function modifier_ride_morty:OnVerticalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

function modifier_ride_morty:GetModifierModelScale()
	if self.scale then
		return self.scale
	else 
		return 0
	end
end


