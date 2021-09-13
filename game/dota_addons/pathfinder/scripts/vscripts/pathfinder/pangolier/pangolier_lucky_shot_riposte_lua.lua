--------------------------------------------------------------------------------------------------------------------------------------------------------

LinkLuaModifier("modifier_pangolier_lucky_shot_riposte", "pathfinder/pangolier/pangolier_lucky_shot_riposte_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pangolier_lucky_shot_lua_disarm", "pathfinder/pangolier/pangolier_lucky_shot_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pangolier_lucky_shot_break", "pathfinder/pangolier/pangolier_lucky_shot_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pangolier_lucky_shot_silence", "pathfinder/pangolier/pangolier_lucky_shot_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pangolier_lucky_shot_damage_reduction", "pathfinder/pangolier/pangolier_lucky_shot_lua", LUA_MODIFIER_MOTION_NONE)

pangolier_lucky_shot_riposte = pangolier_lucky_shot_riposte	or class({})
modifier_pangolier_lucky_shot_riposte = modifier_pangolier_lucky_shot_riposte or class({})

--------------------------------------------------------------------------------------------------------------------------------------------------------

--[[---------------------------------------------------------------------
	PANGOLIER SWASHBUCKLE ON ATTACK
]]------------------------------------------------------------------------


function pangolier_lucky_shot_riposte:GetIntrinsicModifierName()
	return "modifier_pangolier_lucky_shot_riposte"
end

function modifier_pangolier_lucky_shot_riposte:IsHidden() return true end

function modifier_pangolier_lucky_shot_riposte:DeclareFunctions()
	local funcs = {MODIFIER_EVENT_ON_TAKEDAMAGE}
	return funcs
end

function modifier_pangolier_lucky_shot_riposte:OnTakeDamage(keys)
	if not IsServer() then return end
    
	local parent = self:GetParent()
    local caster = self:GetCaster()
    local ability = caster:FindAbilityByName("pangolier_lucky_shot_lua")

	local attacker = keys.attacker
	local target = keys.unit
	local original_damage = keys.original_damage
	local damage_type = keys.damage_type
	local damage_flags = keys.damage_flags
    if ability:IsTrained() then
        if keys.unit == self:GetParent() and not keys.attacker:IsBuilding() and keys.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bitand(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bitand(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then	
            if not keys.unit:IsOther() and keys.damage_type == DAMAGE_TYPE_PHYSICAL then
                if RollPseudoRandomPercentage(ability:GetSpecialValueFor("chance_pct"),DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, caster) then
                    keys.attacker:AddNewModifier(parent, ability, "modifier_pangolier_lucky_shot_lua_disarm", {duration = ability:GetSpecialValueFor("duration") * (1 - keys.attacker:GetStatusResistance())})	
                    if keys.attacker:IsConsideredHero() then
                        keys.attacker:EmitSound("Hero_Pangolier.LuckyShot.Proc")
                    else
                        keys.attacker:EmitSound("Hero_Pangolier.LuckyShot.Proc.Creep")
                    end
                    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_pangolier/pangolier_luckyshot_disarm_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
                    ParticleManager:SetParticleControl(particle, 1, keys.attacker:GetAbsOrigin())
                    ParticleManager:ReleaseParticleIndex(particle)
                end
                ---------------- LUCKY SHOT BREAK SHARD -------------------------------------------------------
                if caster:FindAbilityByName("pangolier_lucky_shot_damage_reduction") then    
                    if RollPseudoRandomPercentage(ability:GetSpecialValueFor("chance_pct"),DOTA_PSEUDO_RANDOM_CUSTOM_GAME_2, caster) then      
                        keys.attacker:AddNewModifier(parent, ability, "modifier_pangolier_lucky_shot_break", {duration = ability:GetSpecialValueFor("duration") * (1 - keys.attacker:GetStatusResistance())})
                        keys.attacker:AddNewModifier(parent, ability, "modifier_pangolier_lucky_shot_damage_reduction", {duration = ability:GetSpecialValueFor("duration") * caster:FindAbilityByName("pangolier_lucky_shot_damage_reduction"):GetSpecialValueFor("duration_multiplier")  * (1 - keys.attacker:GetStatusResistance()) })		
                        if keys.attacker:IsConsideredHero() then
                            keys.attacker:EmitSound("Hero_Pangolier.LuckyShot.Proc")
                        else
                            keys.attacker:EmitSound("Hero_Pangolier.LuckyShot.Proc.Creep")
                        end
                        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_pangolier/pangolier_luckyshot_disarm_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
                        ParticleManager:SetParticleControl(particle, 1, keys.attacker:GetAbsOrigin())
                        ParticleManager:ReleaseParticleIndex(particle)
                    end
                end
                ---------------- LUCKY SHOT DAMAGE SILENCE SHARD -------------------------------------------------------
                if caster:FindAbilityByName("pangolier_lucky_shot_antimage") then     
                    if RollPseudoRandomPercentage(ability:GetSpecialValueFor("chance_pct"),DOTA_PSEUDO_RANDOM_CUSTOM_GAME_3, caster) then 
                        caster:GiveMana(caster:GetAttackDamage() * ( caster:FindAbilityByName("pangolier_lucky_shot_antimage"):GetSpecialValueFor("mana_pct") / 100) )
                        keys.attacker:AddNewModifier(parent, ability, "modifier_pangolier_lucky_shot_silence", {duration = ability:GetSpecialValueFor("duration") * (1 - keys.attacker:GetStatusResistance())})
                        if keys.attacker:IsConsideredHero() then
                            keys.attacker:EmitSound("Hero_Pangolier.LuckyShot.Proc")
                        else
                            keys.attacker:EmitSound("Hero_Pangolier.LuckyShot.Proc.Creep")
                        end
                        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_pangolier/pangolier_luckyshot_disarm_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
                        ParticleManager:SetParticleControl(particle, 1, keys.attacker:GetAbsOrigin())
                        ParticleManager:ReleaseParticleIndex(particle)
                    end
                end
                
                local reflectDamage = ApplyDamage(damageTable)
            end
        end
    end
end
