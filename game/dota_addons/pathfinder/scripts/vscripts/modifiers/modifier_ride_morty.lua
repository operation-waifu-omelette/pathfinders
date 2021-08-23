
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

	self.model = models[#models]
	if IsServer() then
		local parent = self:GetParent()
		local supp_effect = AddPatronEffect(parent)
		self.model = supp_effect.model
		self.effects = {}

		if supp_effect.scale then
			parent:SetModelScale(supp_effect.scale)
		end
		if supp_effect.material_group then
			Timers:CreateTimer(0, function()
				if parent:HasModifier(self:GetName()) then
					parent:SetMaterialGroup(tostring(supp_effect.material_group))
				end
			end)
		end
		if supp_effect.particles_data then
			WearFunc:_CreateParticlesFromConfigList(supp_effect.particles_data, parent, self.effects)
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
	if not IsServer() then return end
	
	local parent = self:GetParent()
	parent:RemoveHorizontalMotionController( self )
	parent:RemoveVerticalMotionController( self )
	parent:SetModelScale(1)
	if self.effects then
		for _, particle in pairs(self.effects) do
			ParticleManager:DestroyParticle(particle, false)
			ParticleManager:ReleaseParticleIndex(particle)
		end
	end
end


--------------------------------------------------------------------------------

function modifier_ride_morty:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
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


