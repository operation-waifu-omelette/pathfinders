modifier_axe_battle_hunger_lua_debuff = class({})
require("libraries.has_shard")

--------------------------------------------------------------------------------
-- Classifications
function modifier_axe_battle_hunger_lua_debuff:IsHidden()
	return false
end

function modifier_axe_battle_hunger_lua_debuff:IsDebuff()
	return true
end

function modifier_axe_battle_hunger_lua_debuff:IsStunDebuff()
	return false
end

function modifier_axe_battle_hunger_lua_debuff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_axe_battle_hunger_lua_debuff:OnCreated( kv )
	-- references
	self.slow = self:GetAbility():GetSpecialValueFor( "slow" )
	local damage = self:GetAbility():GetSpecialValueFor( "damage_per_second" )
	local interval = 1

	if IsServer() then
		-- precache damage
		self.damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(), --Optional.
			damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
		}

		-- Start interval
		self:StartIntervalThink( interval )		
		self:OnIntervalThink()
		self:OnRefresh()			
	end
end

function modifier_axe_battle_hunger_lua_debuff:OnRefresh( kv )
	-- update value
	self.slow = self:GetAbility():GetSpecialValueFor( "slow" )
	local damage = self:GetAbility():GetSpecialValueFor( "damage_per_second" )
	
	if IsServer() then
		self.damageTable.damage = damage * (self:GetStackCount() + 1)		

		if self:GetStackCount() < self:GetAbility():GetSpecialValueFor("max_stacks") then
			self:IncrementStackCount()
		end
	end
end

function modifier_axe_battle_hunger_lua_debuff:OnDestroy( kv )
	if IsServer() then
		-- decrement buff stack
		local modifier = self:GetCaster():FindModifierByName( "modifier_axe_battle_hunger_lua" )
		if modifier then
			modifier:DecrementStackCount()
		end
	end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_axe_battle_hunger_lua_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}

	return funcs
end

function modifier_axe_battle_hunger_lua_debuff:OnDeath( params )
	if IsServer() then
		if params.attacker~=self:GetParent() then return end
		self:Destroy()
	end
end

function modifier_axe_battle_hunger_lua_debuff:OnTakeDamage( params )
	if IsServer() then

		if params.attacker~=self:GetCaster() then return end
		if params.unit ~= self:GetParent() then return end
		if params.inflictor ~= self:GetAbility() then return end
		if not params.attacker:HasAbility("pathfinder_axe_special_battle_hunger_lifesteal") then return end		

		local special = params.attacker:FindAbilityByName("pathfinder_axe_special_battle_hunger_lifesteal")
		local amount = params.damage / 100 * special:GetLevelSpecialValueFor("percent", 1)
		local radius = special:GetLevelSpecialValueFor("radius", 1)
		local heroes = FindRadius(self:GetParent(), radius, true)
		for _,hero in pairs(heroes) do
			hero:Heal(amount, self:GetAbility())			

			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
			ParticleManager:SetParticleControl(nFXIndex, 0, hero:GetAbsOrigin())
			ParticleManager:SetParticleControl(nFXIndex, 1, hero:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex( nFXIndex )

			local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail_scepter.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
					ParticleManager:SetParticleControl(effect, 0, hero:GetAbsOrigin())
					ParticleManager:SetParticleControl(effect, 1, self:GetParent():GetAbsOrigin())
					ParticleManager:SetParticleControl(effect, 60, Vector(0,255,0))
					ParticleManager:SetParticleControl(effect, 61, Vector(1,1,1))
					ParticleManager:ReleaseParticleIndex( effect )
		end
	end
end

function modifier_axe_battle_hunger_lua_debuff:OnAttackLanded( params )
	if IsServer() then
		if params.attacker==self:GetParent() then 
			if params.target==self:GetCaster() then 
				if params.target:HasAbility("pathfinder_axe_special_battle_hunger_refresh") then
					self:IncrementStackCount()
					self:ForceRefresh()
				end
			end

		elseif params.target == self:GetParent() then
			for i=0,10 do
				local ability = self:GetCaster():GetAbilityByIndex(i)
				if ability and ability:GetLevel() > 0 and not ability:IsCooldownReady() and self:GetCaster():HasAbility("pathfinder_axe_special_battle_hunger_culling_cdr") then					
					local current_cd = ability:GetCooldownTimeRemaining()
					local cdr = self:GetCaster():FindAbilityByName("pathfinder_axe_special_battle_hunger_culling_cdr"):GetLevelSpecialValueFor("cdr", 1)
					local new_cd = current_cd - cdr

					if new_cd <= 0 then
						new_cd = 0
					end
					ability:EndCooldown()
					ability:StartCooldown(new_cd)
				end
			end

			-- local culling = self:GetCaster():FindAbilityByName("axe_culling_blade_lua")
			-- if culling and culling:GetLevel() > 0 and not culling:IsCooldownReady() and self:GetCaster():HasAbility("pathfinder_axe_special_battle_hunger_culling_cdr") then
			-- 	local current_cd = culling:GetCooldownTimeRemaining()
			-- 	local cdr = self:GetCaster():FindAbilityByName("pathfinder_axe_special_battle_hunger_culling_cdr"):GetLevelSpecialValueFor("cdr", 1)
			-- 	local new_cd = current_cd - cdr
			-- 	if new_cd <= 0 then
			-- 		new_cd = 0
			-- 	end
			-- 	culling:EndCooldown()
			-- 	culling:StartCooldown(new_cd)
			-- end
		end
	end
end

function modifier_axe_battle_hunger_lua_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_axe_battle_hunger_lua_debuff:OnIntervalThink()
	-- apply damage
	ApplyDamage( self.damageTable )	
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_axe_battle_hunger_lua_debuff:GetEffectName()
	return "particles/units/heroes/hero_axe/axe_battle_hunger.vpcf"
end

function modifier_axe_battle_hunger_lua_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

-- function modifier_axe_battle_hunger_lua_debuff:PlayEffects()
-- 	-- Get Resources
-- 	local particle_cast = "string"
-- 	local sound_cast = "string"

-- 	-- Get Data

-- 	-- Create Particle
-- 	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_NAME, hOwner )
-- 	ParticleManager:SetParticleControl( effect_cast, iControlPoint, vControlVector )
-- 	ParticleManager:SetParticleControlEnt(
-- 		effect_cast,
-- 		iControlPoint,
-- 		hTarget,
-- 		PATTACH_NAME,
-- 		"attach_name",
-- 		vOrigin, -- unknown
-- 		bool -- unknown, true
-- 	)
-- 	ParticleManager:SetParticleControlForward( effect_cast, iControlPoint, vForward )
-- 	SetParticleControlOrientation( effect_cast, iControlPoint, vForward, vRight, vUp )
-- 	ParticleManager:ReleaseParticleIndex( effect_cast )

-- 	-- buff particle
-- 	self:AddParticle(
-- 		nFXIndex,
-- 		bDestroyImmediately,
-- 		bStatusEffect,
-- 		iPriority,
-- 		bHeroEffect,
-- 		bOverheadEffect
-- 	)

-- 	-- Create Sound
-- 	EmitSoundOnLocationWithCaster( vTargetPosition, sound_location, self:GetCaster() )
-- 	EmitSoundOn( sound_target, target )
-- end