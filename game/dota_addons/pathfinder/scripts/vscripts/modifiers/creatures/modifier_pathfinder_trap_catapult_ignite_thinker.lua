
modifier_pathfinder_trap_catapult_ignite_thinker = class({})

----------------------------------------------------------------------------------------

function modifier_pathfinder_trap_catapult_ignite_thinker:OnCreated( kv )
	if IsServer() then
		self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
		self.damage_pct = self:GetAbility():GetSpecialValueFor( "damage_pct" )
		self.area_duration = self:GetAbility():GetSpecialValueFor( "area_duration" )
		self.linger_duration = self:GetAbility():GetSpecialValueFor( "linger_duration" )
		self.bImpact = false
	end
end

----------------------------------------------------------------------------------------

function modifier_pathfinder_trap_catapult_ignite_thinker:OnImpact()
	if IsServer() then
		local nFXIndex = ParticleManager:CreateParticle( "particles/neutral_fx/black_dragon_fireball.vpcf", PATTACH_WORLDORIGIN, nil );
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() );
		ParticleManager:SetParticleControl( nFXIndex, 1, self:GetParent():GetOrigin() );
		ParticleManager:SetParticleControl( nFXIndex, 2, Vector( self.area_duration, 0, 0 ) );
		ParticleManager:ReleaseParticleIndex( nFXIndex );

		EmitSoundOn( "OgreMagi.Ignite.Target", self:GetParent() )
		
		self:SetDuration( self.area_duration, true )
		self.bImpact = true

		self:StartIntervalThink( 0.5 )
	end
end

----------------------------------------------------------------------------------------

function modifier_pathfinder_trap_catapult_ignite_thinker:OnIntervalThink()
	if IsServer() then
		if self.bImpact == false then
			self:OnImpact()
			return
		end

		local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetParent(), self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
		for _,enemy in pairs( enemies ) do
			if enemy ~= nil then
				local damage = {
					victim = enemy,
					attacker = self:GetAbility():GetCaster(),
					damage = self.damage_pct * (enemy:GetMaxHealth() / 100),
					damage_type = DAMAGE_TYPE_MAGICAL,
					ability = self:GetAbility()
				}	
				ApplyDamage( damage )
			end
		end
	end
end

----------------------------------------------------------------------------------------