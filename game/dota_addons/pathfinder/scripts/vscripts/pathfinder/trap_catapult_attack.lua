
trap_catapult_attack = class({})

--------------------------------------------------------------------------------

function trap_catapult_attack:Precache( context )
	PrecacheResource( "particle", "particles/creatures/catapult/catapult_projectile.vpcf", context )
	PrecacheResource( "particle", "particles/ui_mouseactions/international2020/ping_world_davai.vpcf", context )
end

--------------------------------------------------------------------------------

function  trap_catapult_attack:GetPlaybackRateOverride()
	return 0.3333
end

--------------------------------------------------------------------------------

function trap_catapult_attack:OnAbilityPhaseStart()
	if IsServer() then
		--EmitSoundOn( "lycan_lycan_attack_09", self:GetCaster() )

		self.projectile_width_end = 50

		self.nPreviewFX = ParticleManager:CreateParticle( "particles/dark_moon/darkmoon_creep_warning.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControlEnt( self.nPreviewFX, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetAbsOrigin(), true )
		ParticleManager:SetParticleControl( self.nPreviewFX, 1, Vector( self.projectile_width_end, self.projectile_width_end, self.projectile_width_end ) )
		ParticleManager:SetParticleControl( self.nPreviewFX, 15, Vector( 247, 86, 9 ) )
	end

	return true
end

--------------------------------------------------------------------------------

function trap_catapult_attack:OnAbilityPhaseInterrupted()
	if IsServer() then
		ParticleManager:DestroyParticle( self.nPreviewFX, false )
	end 
end

--------------------------------------------------------------------------------

function trap_catapult_attack:OnSpellStart()
	if IsServer() then
		ParticleManager:DestroyParticle( self.nPreviewFX, false )

		local vDirection = self:GetCursorPosition() - self:GetCaster():GetAttachmentOrigin( self:GetCaster():ScriptLookupAttachment( "attach_attack1" ) )
		local flDist = vDirection:Length()
		local flDist2d = vDirection:Length2D()

		vDirection = vDirection:Normalized()
		vDirection.z = 0.0
		local flSpeed = flDist / self:GetLevelSpecialValueFor("time",1)

		local radius = self:GetLevelSpecialValueFor("radius",1)
		local time = self:GetLevelSpecialValueFor("time",1)

		local info = 
		{
			EffectName = "particles/base_attacks/ranged_tower_bad_linear.vpcf",
			Ability = self,
			vSpawnOrigin = self:GetCaster():GetAttachmentOrigin( self:GetCaster():ScriptLookupAttachment( "attach_attack1" ) ), 
			fStartRadius = 0,
			fEndRadius = 0,
			vVelocity = vDirection * flSpeed,
			fDistance = flDist2d,
			Source = self:GetCaster(),
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		}

		ProjectileManager:CreateLinearProjectile( info )		

		local nFXIndex = ParticleManager:CreateParticle( "particles/ui_mouseactions/international2020/ping_world_davai.vpcf", PATTACH_ABSORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCursorPosition() )	
		ParticleManager:SetParticleControl( nFXIndex, 7, Vector(255,0,0) )	
		ParticleManager:ReleaseParticleIndex( nFXIndex )
		 
		
		EmitSoundOn( "Lycan.RuptureBall", self:GetCaster() )
	end
end

--------------------------------------------------------------------------------

function trap_catapult_attack:OnProjectileHit( hTarget, vLocation )
	if IsServer() then
		local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), vLocation, nil, self:GetLevelSpecialValueFor("radius",1), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )

		EmitSoundOn( "Lycan.RuptureBall.Impact", hTarget );

		for _,hTarget in pairs(enemies) do

			hTarget:AddNewModifier( self:GetCaster(), self, "modifier_stunned", { duration = self:GetLevelSpecialValueFor( "stun_duration" ,1) } )


			local damage_percent = self:GetLevelSpecialValueFor("damage_percent", (self:GetLevel() - 1))
			local final_damage = hTarget:GetMaxHealth() / (100 / damage_percent)
			print(final_damage)

			local damage = {
				victim = hTarget,
				attacker = self:GetCaster(),
				damage = final_damage,
				damage_type = self:GetAbilityDamageType(),
				ability = self
			}
			ApplyDamage( damage )
		end

		return true
	end
end

--------------------------------------------------------------------------------
