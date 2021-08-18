phantom_assassin_dagger_global= class({})

--------------------------------------------------------------------------------
function phantom_assassin_dagger_global:GetCastAnimation()
	self:GetCaster():AddActivityModifier("assassin")
    return ACT_DOTA_TAUNT;
end

-- Ability Start
function phantom_assassin_dagger_global:OnSpellStart()
	-- unit identifier	
	local caster = self:GetCaster()
	local spell = caster:FindAbilityByName("phantom_assassin_stifling_dagger_lua")

	if spell:GetLevel() < 1 then
		return false
	end
	
    self:DoThing()        	

end

function phantom_assassin_dagger_global:OnAbilityPhaseInterrupted()
	return
end


function phantom_assassin_dagger_global:DoThing()	
	local caster = self:GetCaster()
	local spell = caster:FindAbilityByName("phantom_assassin_stifling_dagger_lua")
	require("libraries.has_shard")
	local nFxIndex = ParticleManager:CreateParticle( "particles/econ/events/ti4/blink_dagger_start_smoke_ti4.vpcf", PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControlEnt( nFxIndex, 0, hParent, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
	ParticleManager:SetParticleControl( nFxIndex, 0, caster:GetAbsOrigin() )
	ParticleManager:DestroyParticle(nFxIndex, false)
	ParticleManager:ReleaseParticleIndex( nFxIndex )
	local enemies = FindRadius(caster, 12000, true)
	for _,enemy in pairs(enemies) do
		caster:SetCursorCastTarget(enemy)
		spell:OnSpellStart()
	end		
end