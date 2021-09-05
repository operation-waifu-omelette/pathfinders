----------------
-- LUCKY SHOT --
----------------

LinkLuaModifier("modifier_pangolier_lucky_shot_lua", "pathfinder/pangolier/pangolier_lucky_shot_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pangolier_lucky_shot_lua_disarm", "pathfinder/pangolier/pangolier_lucky_shot_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pangolier_lucky_shot_break", "pathfinder/pangolier/pangolier_lucky_shot_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pangolier_lucky_shot_silence", "pathfinder/pangolier/pangolier_lucky_shot_lua", LUA_MODIFIER_MOTION_NONE)

pangolier_lucky_shot_lua							= class({})
modifier_pangolier_lucky_shot_lua					= class({})
modifier_pangolier_lucky_shot_lua_disarm			= class({})
modifier_pangolier_lucky_shot_break			= class({})
modifier_pangolier_lucky_shot_silence		= class({})

function pangolier_lucky_shot_lua:GetIntrinsicModifierName()
	return "modifier_pangolier_lucky_shot_lua"
end

-------------------------
-- LUCKY SHOT MODIFIER --
-------------------------

function modifier_pangolier_lucky_shot_lua:IsHidden()	return true end

function modifier_pangolier_lucky_shot_lua:DeclareFunctions()
	local funcs = {MODIFIER_EVENT_ON_ATTACK_LANDED}

	return funcs
end

function modifier_pangolier_lucky_shot_lua:OnAttackLanded(keys)
	if not IsServer() then return end

	-- A bunch of conditionals that need to be passed to continue
	if keys.attacker == self:GetParent() and not self:GetParent():IsIllusion() and not self:GetParent():PassivesDisabled() and not keys.target:IsMagicImmune() and not keys.target:IsBuilding() then
		-- Roll!
		if RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("chance_pct"),DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, self:GetCaster()) then
			
			keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_pangolier_lucky_shot_lua_disarm", {duration = self:GetAbility():GetSpecialValueFor("duration") * (1 - keys.target:GetStatusResistance())})
			
			-- Emit sound
			if keys.target:IsConsideredHero() then
				keys.target:EmitSound("Hero_Pangolier.LuckyShot.Proc")
			else
				keys.target:EmitSound("Hero_Pangolier.LuckyShot.Proc.Creep")
			end
			
			-- Play particle effect
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_pangolier/pangolier_luckyshot_disarm_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			-- This CP isn't editable in particle manager so hopefully I'm not doing something wrong here
			ParticleManager:SetParticleControl(particle, 1, keys.target:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(particle)
		end
		if self:GetCaster():FindAbilityByName("pangolier_lucky_shot_breaks") then
			if RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("chance_pct"),DOTA_PSEUDO_RANDOM_CUSTOM_GAME_2, self:GetCaster()) then
				
				keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_pangolier_lucky_shot_break", {duration = self:GetAbility():GetSpecialValueFor("duration") * (1 - keys.target:GetStatusResistance())})
				
			end
		end
		if self:GetCaster():FindAbilityByName("pangolier_lucky_shot_antimage") then
			if RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("chance_pct"),DOTA_PSEUDO_RANDOM_CUSTOM_GAME_2, self:GetCaster()) then
				self:GetCaster():GiveMana(self:GetCaster():GetAttackDamage() * ( self:GetCaster():FindAbilityByName("pangolier_lucky_shot_antimage"):GetSpecialValueFor("mana_pct") / 100) )
				keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_pangolier_lucky_shot_silence", {duration = self:GetAbility():GetSpecialValueFor("duration") * (1 - keys.target:GetStatusResistance())})
				
			end
		end
	end
end

--------------------------------
-- LUCKY SHOT DISARM MODIFIER --
--------------------------------

function modifier_pangolier_lucky_shot_lua_disarm:GetEffectName()
	return "particles/units/heroes/hero_pangolier/pangolier_luckyshot_disarm_debuff.vpcf"
end

function modifier_pangolier_lucky_shot_lua_disarm:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_pangolier_lucky_shot_lua_disarm:OnCreated()
	self.ability	= self:GetAbility()
	self.caster		= self:GetCaster()
	self.parent		= self:GetParent()
	
	-- AbilitySpecials
	self.chance_pct	= self.ability:GetSpecialValueFor("chance_pct")
	self.slow		= self.ability:GetSpecialValueFor("slow")
	self.armor		= self.ability:GetSpecialValueFor("armor")
end

function modifier_pangolier_lucky_shot_lua_disarm:CheckState()
	state = {
			[MODIFIER_STATE_DISARMED] = true
			}

	return state
end

function modifier_pangolier_lucky_shot_lua_disarm:DeclareFunctions()
	local funcs =	{
					MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
					MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
					}

	return funcs
end

function modifier_pangolier_lucky_shot_lua_disarm:GetModifierMoveSpeedBonus_Percentage()
	return self.slow * (-1)
end

function modifier_pangolier_lucky_shot_lua_disarm:GetModifierPhysicalArmorBonus()
	return self.armor * (-1)
end

---------------------------------
-- LUCKY SHOT SILENCE MODIFIER --
---------------------------------

function modifier_pangolier_lucky_shot_break:GetEffectName()
	return "particles/generic_gameplay/generic_break.vpcf"
end

function modifier_pangolier_lucky_shot_break:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_pangolier_lucky_shot_break:OnCreated()
	self.ability	= self:GetAbility()
	self.caster		= self:GetCaster()
	self.parent		= self:GetParent()
	
	-- AbilitySpecials
	self.chance_pct	= self.ability:GetSpecialValueFor("chance_pct")
end

function modifier_pangolier_lucky_shot_break:CheckState()
	state = {
			[MODIFIER_STATE_PASSIVES_DISABLED] = true
			}
	return state
end


function modifier_pangolier_lucky_shot_silence:GetEffectName()
	return "particles/units/heroes/hero_pangolier/pangolier_luckyshot_silence_debuff.vpcf"
end

function modifier_pangolier_lucky_shot_silence:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_pangolier_lucky_shot_silence:OnCreated()
	self.ability	= self:GetAbility()
	self.caster		= self:GetCaster()
	self.parent		= self:GetParent()
	
	-- AbilitySpecials
	self.chance_pct	= self.ability:GetSpecialValueFor("chance_pct")
end

function modifier_pangolier_lucky_shot_silence:CheckState()
	state = {
			[MODIFIER_STATE_SILENCED] = true
			}
	return state
end



