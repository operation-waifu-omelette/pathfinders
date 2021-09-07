
---------------------------------------------------------------------------------------------------------------------------------------------
LinkLuaModifier("modifier_pangolier_lucky_shot_lua", "pathfinder/pangolier/pangolier_lucky_shot_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pangolier_lucky_shot_lua_disarm", "pathfinder/pangolier/pangolier_lucky_shot_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pangolier_lucky_shot_break", "pathfinder/pangolier/pangolier_lucky_shot_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pangolier_lucky_shot_silence", "pathfinder/pangolier/pangolier_lucky_shot_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pangolier_lucky_shot_damage_reduction", "pathfinder/pangolier/pangolier_lucky_shot_lua", LUA_MODIFIER_MOTION_NONE)

pangolier_lucky_shot_lua							= class({})
modifier_pangolier_lucky_shot_lua					= class({})
modifier_pangolier_lucky_shot_lua_disarm			= class({})
modifier_pangolier_lucky_shot_break			= class({})
modifier_pangolier_lucky_shot_silence		= class({})
modifier_pangolier_lucky_shot_damage_reduction		= class({})

----------------------------------------------------------------------------------------------------------------------------
function pangolier_lucky_shot_lua:GetIntrinsicModifierName()
	return "modifier_pangolier_lucky_shot_lua"
end

----------------------------------------------------------------------------------------------------------------------------------
-- 									LUCKY SHOT MODIFIER 																		--
----------------------------------------------------------------------------------------------------------------------------------

function modifier_pangolier_lucky_shot_lua:IsHidden()	return true end

function modifier_pangolier_lucky_shot_lua:DeclareFunctions()
	local funcs = {MODIFIER_EVENT_ON_ATTACK_LANDED}
	return funcs
end

function modifier_pangolier_lucky_shot_lua:OnAttackLanded(keys)
	if not IsServer() then return end

	local ability = self:GetAbility()
	local parent = self:GetParent()
	local caster = self:GetCaster()

	if keys.attacker == parent and not parent:IsIllusion() and not parent:PassivesDisabled() and not keys.target:IsMagicImmune() and not keys.target:IsBuilding() then

		if RollPseudoRandomPercentage(ability:GetSpecialValueFor("chance_pct"),DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, caster) then

			keys.target:AddNewModifier(parent, ability, "modifier_pangolier_lucky_shot_lua_disarm", {duration = ability:GetSpecialValueFor("duration") * (1 - keys.target:GetStatusResistance())})	
			if keys.target:IsConsideredHero() then
				keys.target:EmitSound("Hero_Pangolier.LuckyShot.Proc")
			else
				keys.target:EmitSound("Hero_Pangolier.LuckyShot.Proc.Creep")
			end
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_pangolier/pangolier_luckyshot_disarm_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
			ParticleManager:SetParticleControl(particle, 1, keys.target:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(particle)

		end
		---------------- LUCKY SHOT BREAK SHARD -------------------------------------------------------
		if caster:FindAbilityByName("pangolier_lucky_shot_breaks") then
			if RollPseudoRandomPercentage(ability:GetSpecialValueFor("chance_pct"),DOTA_PSEUDO_RANDOM_CUSTOM_GAME_2, caster) then
				keys.target:AddNewModifier(parent, ability, "modifier_pangolier_lucky_shot_break", {duration = ability:GetSpecialValueFor("duration") * (1 - keys.target:GetStatusResistance())})
				if keys.target:IsConsideredHero() then
					keys.target:EmitSound("Hero_Pangolier.LuckyShot.Proc")
				else
					keys.target:EmitSound("Hero_Pangolier.LuckyShot.Proc.Creep")
				end
				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_pangolier/pangolier_luckyshot_disarm_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
				ParticleManager:SetParticleControl(particle, 1, keys.target:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(particle)
			end
		end
		---------------- LUCKY SHOT DAMAGE SILENCE SHARD -------------------------------------------------------
		if caster:FindAbilityByName("pangolier_lucky_shot_antimage") then
			if RollPseudoRandomPercentage(ability:GetSpecialValueFor("chance_pct"),DOTA_PSEUDO_RANDOM_CUSTOM_GAME_3, caster) then
				caster:GiveMana(caster:GetAttackDamage() * ( caster:FindAbilityByName("pangolier_lucky_shot_antimage"):GetSpecialValueFor("mana_pct") / 100) )
				keys.target:AddNewModifier(parent, ability, "modifier_pangolier_lucky_shot_silence", {duration = ability:GetSpecialValueFor("duration") * (1 - keys.target:GetStatusResistance())})
				if keys.target:IsConsideredHero() then
					keys.target:EmitSound("Hero_Pangolier.LuckyShot.Proc")
				else
					keys.target:EmitSound("Hero_Pangolier.LuckyShot.Proc.Creep")
				end
				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_pangolier/pangolier_luckyshot_disarm_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
				ParticleManager:SetParticleControl(particle, 1, keys.target:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(particle)
			end
		end
		---------------- LUCKY SHOT DAMAGE REDUCTION SHARD -------------------------------------------------------
		if caster:FindAbilityByName("pangolier_lucky_shot_damage_reduction") then
			if RollPseudoRandomPercentage(ability:GetSpecialValueFor("chance_pct"),DOTA_PSEUDO_RANDOM_CUSTOM_GAME_4, caster) then
				keys.target:AddNewModifier(parent, ability, "modifier_pangolier_lucky_shot_damage_reduction", {duration = ability:GetSpecialValueFor("duration") * caster:FindAbilityByName("pangolier_lucky_shot_damage_reduction"):GetSpecialValueFor("duration_multiplier")  * (1 - keys.target:GetStatusResistance()) })		
				if keys.target:IsConsideredHero() then
					keys.target:EmitSound("Hero_Pangolier.LuckyShot.Proc")
				else
					keys.target:EmitSound("Hero_Pangolier.LuckyShot.Proc.Creep")
				end
				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_pangolier/pangolier_luckyshot_disarm_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
				ParticleManager:SetParticleControl(particle, 1, keys.target:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(particle)
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
-- LUCKY SHOT BREAK MODIFIER 	--
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
end

function modifier_pangolier_lucky_shot_break:CheckState()
	state = {
			[MODIFIER_STATE_PASSIVES_DISABLED] = true
			}
	return state
end

---------------------------------
-- LUCKY SHOT SILENCE MODIFIER --
---------------------------------

function modifier_pangolier_lucky_shot_silence:GetEffectName()
	return "particles/units/heroes/hero_pangolier/pangolier_luckyshot_silence_debuff.vpcf"
end

function modifier_pangolier_lucky_shot_silence:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_pangolier_lucky_shot_silence:OnCreated()
end

function modifier_pangolier_lucky_shot_silence:CheckState()
	state = {
			[MODIFIER_STATE_SILENCED] = true
			}
	return state
end

--------------------------------
-- LUCKY SHOT DAMAGE REDUCTION MODIFIER --
--------------------------------
function modifier_pangolier_lucky_shot_damage_reduction:OnCreated(kv)	
	self.damage_reduction = self:GetCaster():FindAbilityByName("pangolier_lucky_shot_damage_reduction"):GetSpecialValueFor("reduction_pct")
end

function modifier_pangolier_lucky_shot_damage_reduction:OnRefresh()
	self:OnCreated()
end

function modifier_pangolier_lucky_shot_damage_reduction:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_pangolier_lucky_shot_damage_reduction:GetModifierBaseDamageOutgoing_Percentage()
	return self.damage_reduction * -1
end
