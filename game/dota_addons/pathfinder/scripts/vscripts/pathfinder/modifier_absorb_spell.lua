
--------------------------------------------------------------------------------
modifier_absorb_spell = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_absorb_spell:IsHidden()
	return true
end


function modifier_absorb_spell:IsDebuff()
	return false
end

function modifier_absorb_spell:IsPurgable()
	return false
end

function modifier_absorb_spell:OnCreated(table)
	require("libraries.timers")
	local duration = table.duration	

	local nFXIndex = ParticleManager:CreateParticle( "particles/items_fx/immunity_sphere_buff.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() );
	ParticleManager:SetParticleControl( nFXIndex, 0, Vector( 0, 0, -1000 ) )
	ParticleManager:SetParticleControlEnt(nFXIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)	

	Timers:CreateTimer(duration, function()
		ParticleManager:DestroyParticle(nFXIndex, true)
   		ParticleManager:ReleaseParticleIndex( nFXIndex )
    	return nil
	end)
end



function modifier_absorb_spell:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ABSORB_SPELL
	}

	return funcs
end

function modifier_absorb_spell:GetAbsorbSpell(keys)
	if IsServer() then
		keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel()))
	end	
	local nFXIndex = ParticleManager:CreateParticle( "particles/items_fx/immunity_sphere.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() );
	ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetAbsOrigin() );
	ParticleManager:DestroyParticle(nFXIndex, false)
   	ParticleManager:ReleaseParticleIndex( nFXIndex )	
			
	return 1
end

