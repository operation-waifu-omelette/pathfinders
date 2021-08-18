
pathfinder_trap_catapult_ignite = class ({})
LinkLuaModifier( "modifier_pathfinder_trap_catapult_ignite_thinker", "modifiers/creatures/modifier_pathfinder_trap_catapult_ignite_thinker", LUA_MODIFIER_MOTION_NONE )

----------------------------------------------------------------------------------------

function pathfinder_trap_catapult_ignite:Precache( context )
	PrecacheResource( "particle", "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_ogre_magi/ogre_magi_ignite_cast.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_ogre_magi/ogre_magi_ignite_debuff.vpcf", context )
	PrecacheResource( "particle", "particles/neutral_fx/black_dragon_fireball.vpcf", context )
	PrecacheResource( "particle", "particles/status_fx/status_effect_burn.vpcf", context )
end

----------------------------------------------------------------------------------------

function pathfinder_trap_catapult_ignite:OnSpellStart()
	if IsServer() then


		self.hThinker = CreateModifierThinker( self:GetCaster(), self, "modifier_pathfinder_trap_catapult_ignite_thinker", { duration = -1 }, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false )
		if self.hThinker ~= nil then
			local projectile =
			{
				Target = self.hThinker,
				Source = self:GetCaster(),
				Ability = self,
				EffectName = "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite.vpcf",
				iMoveSpeed = self:GetSpecialValueFor( "projectile_speed" ),
				vSourceLoc = self:GetCaster():GetOrigin(),
				bDodgeable = false,
				bProvidesVision = false,
			}

			ProjectileManager:CreateTrackingProjectile( projectile )
			EmitSoundOn( "OgreMagi.Ignite.Cast", self:GetCaster() )

			local nDestinationPreviewFX = ParticleManager:CreateParticle( "particles/ui_mouseactions/international2020/ping_world_davai.vpcf", PATTACH_CUSTOMORIGIN, nil )					
			ParticleManager:SetParticleControl( nDestinationPreviewFX, 0, self.hThinker:GetAbsOrigin() )
			ParticleManager:SetParticleControl( nDestinationPreviewFX, 7, Vector( 255, 0, 0 ) )					
			ParticleManager:ReleaseParticleIndex( nDestinationPreviewFX )				
			EmitGlobalSound("Item.PickUpGemShop")
		end
	end
end

----------------------------------------------------------------------------------------

function pathfinder_trap_catapult_ignite:OnProjectileHit( hTarget, vLocation )
	if IsServer() then
		if self.hThinker ~= nil then
			local hBuff = self.hThinker:FindModifierByName( "modifier_pathfinder_trap_catapult_ignite_thinker" )
			if hBuff ~= nil then
				hBuff:OnIntervalThink()
			end
			self.hThinker = nil;
		end
	end

	return true
end

----------------------------------------------------------------------------------------