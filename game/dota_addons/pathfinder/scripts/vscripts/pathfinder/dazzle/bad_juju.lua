pf_bad_juju = class({})
require("libraries.has_shard")
LinkLuaModifier( "modifier_pf_bad_juju_passive", "pathfinder/dazzle/bad_juju", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pf_bad_juju_debuff", "pathfinder/dazzle/bad_juju", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pf_bad_juju_heal", "pathfinder/dazzle/bad_juju", LUA_MODIFIER_MOTION_NONE )

function pf_bad_juju:GetIntrinsicModifierName()
    return 'modifier_pf_bad_juju_passive'
end

function pf_bad_juju:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor('radius')
end

modifier_pf_bad_juju_passive = class({
    IsHidden    = function() return false end,
    IsPermanent     = function(self) return true end,

    DeclareFunctions    = function(self)
        return {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
            MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
        }
    end,
    GetModifierPercentageCooldown = function(self) return self.reductionCooldown end,
})

function modifier_pf_bad_juju_passive:OnCreated()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.reductionCooldown = self.ability:GetSpecialValueFor('cooldown_reduction')
    self.radius = self.ability:GetSpecialValueFor('radius')
    self.duration = self.ability:GetSpecialValueFor('duration')
end


function modifier_pf_bad_juju_passive:OnRefresh()
    self:OnCreated()
end

function modifier_pf_bad_juju_passive:OnAbilityFullyCast(keys)
	if keys.ability and keys.unit == self.parent and not self.parent:PassivesDisabled() and not keys.ability:IsItem() then

        if self:GetCaster():FindAbilityByName("pf_bad_juju_heal") then
            local allies = FindUnitsInRadius(
                keys.unit:GetTeamNumber(),	-- int, your team number
                keys.unit:GetOrigin(),	-- point, center point
                nil,	-- handle, cacheUnit. (not known)
                self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
                DOTA_UNIT_TARGET_HERO,	-- int, type filter
                DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
                FIND_ANY_ORDER,	-- int, order filter
                false	-- bool, can grow cache
            )
            for _,ally in pairs(allies) do
                ally:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_pf_bad_juju_heal", {duration = self.duration})
            end
        end

        local enemies = FindUnitsInRadius(
            keys.unit:GetTeamNumber(),	-- int, your team number
            keys.unit:GetOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
            FIND_ANY_ORDER,	-- int, order filter
            false	-- bool, can grow cache
        )

        local target_count = 0        

        for k,v in pairs(enemies) do 
            AddStackModifier(v, {
                ability = self.ability,
                modifier = 'modifier_pf_bad_juju_debuff',
                updateStack = true,
                duration = self.duration,
                caster = keys.unit,
            })

            if self:GetCaster():FindAbilityByName("pf_bad_juju_attacks") and target_count <= self:GetCaster():FindAbilityByName("pf_bad_juju_attacks"):GetLevelSpecialValueFor("targets",1) then
                self:GetCaster():PerformAttack(v, false, true, true, true, true, false, false)
                target_count = target_count + 1
            end
        end 



        if self:GetCaster():FindAbilityByName("pf_bad_juju_raze") then
            local max_stack = self:GetCaster():FindAbilityByName("pf_bad_juju_raze"):GetLevelSpecialValueFor("max_stack",1)
            self:IncrementStackCount()

            if self:GetStackCount() == max_stack then
                if #enemies > 0 then
                    for _,enemy in pairs(enemies) do
                        local particle_raze = "particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf"

                        -- Add particle effects. CP0 is location, CP1 is radius
                        local particle_raze_fx = ParticleManager:CreateParticle(particle_raze, PATTACH_WORLDORIGIN, nil)
                        ParticleManager:SetParticleControl(particle_raze_fx, 0, enemy:GetAbsOrigin())
                        ParticleManager:SetParticleControl(particle_raze_fx, 1, Vector(50, 1, 1))
                        ParticleManager:SetParticleControl(particle_raze_fx, 60, Vector(210, 1, 210))
                        ParticleManager:SetParticleControl(particle_raze_fx, 61, Vector(1, 1, 1))
                        ParticleManager:ReleaseParticleIndex(particle_raze_fx)

                        local damageTable = {
                            victim = enemy,
                            attacker = self:GetCaster(),
                            damage = self:GetCaster():GetIntellect() / 100 * self:GetCaster():FindAbilityByName("pf_bad_juju_raze"):GetLevelSpecialValueFor("int_damage",1),
                            damage_type = DAMAGE_TYPE_PHYSICAL,
                            ability = self:GetAbility(), --Optional.
                        }
                        ApplyDamage(damageTable)
                    end
                    EmitSoundOn("Hero_Nevermore.Shadowraze", self:GetCaster())
                    self:SetStackCount(0)
                else
                    self:DecrementStackCount()
                end
            end
        end
	end
end

modifier_pf_bad_juju_debuff = class({
    DeclareFunctions    = function(self)
        return {
            MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        }
    end,
    GetModifierPhysicalArmorBonus = function(self) return self.armor * self:GetStackCount() end,
})

function modifier_pf_bad_juju_debuff:OnCreated()
    self.armor = -self:GetAbility():GetSpecialValueFor('armor_reduction')
    self.max = -self:GetAbility():GetSpecialValueFor('max_reduction')

    self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_armor_enemy.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "attach_head", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.nfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
end

function modifier_pf_bad_juju_debuff:OnDestroy() 
    if self.nfx then 
        ParticleManager:DestroyParticle(self.nfx, false)
        ParticleManager:ReleaseParticleIndex(self.nfx)
    end 
end

function modifier_pf_bad_juju_debuff:OnRefresh()
    self.armor = -self:GetAbility():GetSpecialValueFor('armor_reduction')
    self.armor = math.max(self.armor, self.max)
end

-----------------
-----------------

modifier_pf_bad_juju_heal = class({
    
})

function modifier_pf_bad_juju_heal:OnCreated()
    self.effect_cast = ParticleManager:CreateParticle( "particles/purple_rain.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt(
		self.effect_cast,
		0,
		self:GetParent(),
		PATTACH_OVERHEAD_FOLLOW,
		nil,
		self:GetParent():GetOrigin(), -- unknown
		true -- unknown, true
	)
    ParticleManager:SetParticleControlEnt(
		self.effect_cast,
		1,
		self:GetParent(),
		PATTACH_OVERHEAD_FOLLOW,
		nil,
		self:GetParent():GetOrigin(), -- unknown
		true -- unknown, true
	)
    ParticleManager:SetParticleControlEnt(
		self.effect_cast,
		2,
		self:GetParent(),
		PATTACH_OVERHEAD_FOLLOW,
		nil,
		self:GetParent():GetOrigin(), -- unknown
		true -- unknown, true
	)
    ParticleManager:SetParticleControl(self.effect_cast, 60, Vector(190,1,190))
    ParticleManager:SetParticleControl(self.effect_cast, 61, Vector(1,1,1))
    self:AddParticle(
		self.effect_cast,
		false,
		false,
		-1,
		false,
		true
	)
    self:StartIntervalThink(1)
end

function modifier_pf_bad_juju_heal:OnIntervalThink()
    if self:GetParent():IsAlive() then
        local heal = self:GetParent():GetMaxHealth() / 100 * self:GetCaster():FindAbilityByName("pf_bad_juju_heal"):GetLevelSpecialValueFor("heal_percent",1)
        self:GetParent():Heal(heal, self:GetAbility())
        local mana = self:GetParent():GetMaxMana() / 100 * self:GetCaster():FindAbilityByName("pf_bad_juju_heal"):GetLevelSpecialValueFor("heal_percent",1)
        self:GetParent():GiveMana(mana)
    end
end

