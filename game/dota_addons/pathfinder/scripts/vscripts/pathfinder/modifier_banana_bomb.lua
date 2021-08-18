modifier_banana_bomb = class({})

function modifier_banana_bomb:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_venomancer.vsndevts", context )	
	PrecacheResource( "particle", "particles/units/heroes/hero_venomancer/venomancer_poison_nova_g.vpcf", context )	
	PrecacheResource( "particle", "particles/units/heroes/hero_venomancer/venomancer_poison_nova_e.vpcf", context )	
end

--------------------------------------------------------------------------------


function modifier_banana_bomb:OnCreated( kv )
	require("libraries.timers")
	if IsServer() then
		self.nova = self:GetAbility():GetCaster():FindAbilityByName("venomancer_poison_nova_datadriven")
		if self.nova:GetLevel() <1 then
			self:GetParent():ForceKill(false)
		end		
		self.radius = self:GetAbility():GetCaster():FindAbilityByName("pathfinder_special_venomancer_banana_bomb"):GetSpecialValueFor( "radius" )
		self.activation_delay = self:GetAbility():GetCaster():FindAbilityByName("pathfinder_special_venomancer_banana_bomb"):GetSpecialValueFor( "activation_delay" )				

		Timers:CreateTimer( self.activation_delay, function()
        	self:StartIntervalThink( self.activation_delay )
        	return nil
    	end)		
	end
end

--------------------------------------------------------------------------------

function modifier_banana_bomb:CheckState()
	local state = {}
	if IsServer() then
		state[MODIFIER_STATE_ROOTED] = true
		state[MODIFIER_STATE_MAGIC_IMMUNE] = true
		state[MODIFIER_STATE_INVULNERABLE] = true
		state[MODIFIER_STATE_ATTACK_IMMUNE] = true
		state[MODIFIER_STATE_NO_HEALTH_BAR] = true
		state[MODIFIER_STATE_UNSELECTABLE] = true
		state[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	end

	return state
end

--------------------------------------------------------------------------------

function modifier_banana_bomb:OnIntervalThink()
	if IsServer() then
		local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetCaster(), self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, 0, false )
		local lCaster = self:GetAbility():GetCaster()
		if #enemies > 0 then
			for _, enemy in pairs( enemies ) do
				if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
					if self.nova then
						local dur = self.nova:GetSpecialValueFor("duration")
						self.nova:ApplyDataDrivenModifier(self:GetAbility():GetCaster(), enemy, "modifier_poison_nova_debuff_datadriven", {duration = dur})
					end					
				end
			end
		end

		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_venomancer/venomancer_poison_nova_g.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius - 50, 1, self.radius - 50) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_venomancer/venomancer_poison_nova_e.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 0, 1, 0 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		

		--EmitSoundOn( "TreasureChest.MineTrap.Detonate", self:GetParent() )
		-- EmitSoundOn( "Hero_Venomancer.PoisonNova", self:GetParent() )
		self:GetParent():EmitSoundParams("Hero_Venomancer.PoisonNova", 0, 0.4, 0)
		self:GetParent():ForceKill( false )
	end
end

function modifier_banana_bomb:DeclareFunctions()
	local funcs = {		
		MODIFIER_PROPERTY_MODEL_CHANGE,
	}
	return funcs
end

function modifier_banana_bomb:GetModifierModelChange()
	if RandomInt(1,2) < 2 then
		return "models/props_gameplay/banana_prop_closed.vmdl"
	else
		return "models/props_gameplay/banana_prop_open.vmdl"
	end
end