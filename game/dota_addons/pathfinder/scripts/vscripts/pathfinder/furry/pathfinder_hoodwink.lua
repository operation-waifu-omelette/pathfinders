-- Code written by Friday for Aghanim's Pathfinders
require("libraries.timers")
LinkLuaModifier( "modifier_generic_4_charges", "pathfinder/generic/modifier_generic_4_charges", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_pathfinder_temp_tree", "pathfinder/furry/pathfinder_hoodwink", LUA_MODIFIER_MOTION_NONE )


---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- ACORN SHOT

pathfinder_acorn_shot = class({})
LinkLuaModifier( "modifier_pathfinder_acorn_shot_thinker", "pathfinder/furry/pathfinder_hoodwink", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hoodwink_root", "pathfinder/furry/pathfinder_hoodwink", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pathfinder_acorn_shot_debuff", "pathfinder/furry/pathfinder_hoodwink", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pathfinder_acorn_shot_preattack", "pathfinder/furry/pathfinder_hoodwink", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pathfinder_acorn_shot_attack", "pathfinder/furry/pathfinder_hoodwink", LUA_MODIFIER_MOTION_NONE )

function pathfinder_acorn_shot:Precache( context )
	PrecacheResource( "particle", "particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_impact.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_tracking.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_tree.vpcf", context )
	PrecacheResource( "model", 	"models/heroes/hoodwink/hoodwink_tree_model.vmdl", context )
	PrecacheResource( "model", 	"models/props_tree/frostivus_tree.vmdl", context )
end

function pathfinder_acorn_shot:GetCastRange(vLocation, hTarget)
	return self:GetCaster():Script_GetAttackRange() + self:GetSpecialValueFor( "bonus_range" )
end

function pathfinder_acorn_shot:GetIntrinsicModifierName()
	if self:GetCaster():HasAbility("pathfinder_acorn_shot_attack") then
		return "modifier_pathfinder_acorn_shot_attack"
	end
end

function pathfinder_acorn_shot:OnSpellStart()
    if not IsServer() then return end

    self.bonus_damage = self:GetLevelSpecialValueFor("bonus_damage", self:GetLevel())
    self.projectile_speed = self:GetLevelSpecialValueFor("projectile_speed", self:GetLevel())
    self.bounce_count = self:GetLevelSpecialValueFor("bounce_count", self:GetLevel())
    self.bounce_range = self:GetLevelSpecialValueFor("bounce_range", self:GetLevel())
    self.debuff_duration = self:GetLevelSpecialValueFor("debuff_duration", self:GetLevel())
    self.slow = self:GetLevelSpecialValueFor("slow", self:GetLevel())
    self.bounce_delay = self:GetLevelSpecialValueFor("bounce_delay", self:GetLevel())

    local target = self:GetCursorTarget()
    if not target or self:GetAutoCastState() then
        local loc = self:GetCursorPosition()
        local thinker = CreateModifierThinker(
            self:GetCaster(), -- player source
            self, -- ability source
            "modifier_pathfinder_acorn_shot_thinker", -- modifier name
            {duration =  self:GetSpecialValueFor("tree_duration") }, -- kv
            loc,
            self:GetCaster():GetTeamNumber(),
            false
        )
		target = thinker
	else
		local vo = {
			"hoodwink_hoodwink_acorn_en_01",
			"hoodwink_hoodwink_acorn_en_02",
			"hoodwink_hoodwink_acorn_en_03_81",
			"hoodwink_hoodwink_acorn_en_04",
			"hoodwink_hoodwink_acorn_en_05",
			"hoodwink_hoodwink_acorn_en_06",
			"hoodwink_hoodwink_acorn_en_06-02",
			"hoodwink_hoodwink_acorn_en_07",
			"hoodwink_hoodwink_acorn_en_08",
			"hoodwink_hoodwink_acorn_en_09",
			"hoodwink_hoodwink_acorn_en_10",
			"hoodwink_hoodwink_acorn_en_11",
			"hoodwink_hoodwink_acorn_en_12",
			"hoodwink_hoodwink_acorn_en_13",
			"hoodwink_hoodwink_acorn_en_14",
			"hoodwink_hoodwink_acorn_en_15",
		}
		self:GetCaster():EmitSoundParams(vo[RandomInt(1, #vo)], 0, 3, 0)
    end
    self:MakeProjectile(self.bounce_count, self:GetCaster(), target)
end


function pathfinder_acorn_shot:MakeProjectile(bounce, source, target )
    local projectile =
    {
        Target = target,
        Source = source,
        Ability = self,
        EffectName = "particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_tracking.vpcf",
        iMoveSpeed = self.projectile_speed,
        vSourceLoc = source:GetAbsOrigin(),
        bDodgeable = true,
        bProvidesVision = true,
        ExtraData = {
			bounce = bounce,
		}
    }
    return ProjectileManager:CreateTrackingProjectile( projectile )
end

function pathfinder_acorn_shot:OnProjectileHit_ExtraData(hTarget, vLocation, table)
    if not IsServer() or not hTarget then return end

	if not hTarget:HasModifier("modifier_pathfinder_acorn_shot_thinker") then
        local nFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_impact.vpcf", PATTACH_CUSTOMORIGIN, hTarget )
        ParticleManager:SetParticleControlEnt( nFxIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true )
        ParticleManager:ReleaseParticleIndex( nFxIndex )
        EmitSoundOn( "Hero_Hoodwink.AcornShot.Target", hTarget )

        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pathfinder_acorn_shot_preattack", {})
        self:GetCaster():PerformAttack(hTarget, false, true, true, true, false, false, false)
        self:GetCaster():RemoveModifierByName("modifier_pathfinder_acorn_shot_preattack")

		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_pathfinder_acorn_shot_debuff", {duration = self.debuff_duration})

		if self:GetCaster():HasAbility("pathfinder_acorn_shot_stun") then
			local base_stun = self:GetCaster():FindAbilityByName("pathfinder_acorn_shot_stun"):GetLevelSpecialValueFor("base_stun", 1)
			local base_damage = self:GetCaster():FindAbilityByName("pathfinder_acorn_shot_stun"):GetLevelSpecialValueFor("base_damage", 1)

			-- damage
			local damageTable = {
				victim = hTarget,
				attacker = self:GetCaster(),
				damage = base_damage + base_damage * (self.bounce_count - table.bounce),
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self, --Optional.
				damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
			}
			ApplyDamage(damageTable)

			-- self:GetCaster():Heal(base_damage + base_damage * (self.bounce_count - table.bounce), self)
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = base_stun + base_stun * (self.bounce_count - table.bounce)})
		end

	else
		local tree_model = "pathfinder_hoodwink_tree"
		if self:GetCaster():HasAbility("pathfinder_acorn_shot_tree") then
			tree_model = "pathfinder_hoodwink_tree_special"
		end
        
        -- tree
		local tree = CreateUnitByName(tree_model, vLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)
		tree:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = self:GetSpecialValueFor("tree_duration")})
		tree:AddNewModifier(self:GetCaster(), self, "modifier_pathfinder_temp_tree", {})
		tree:SetForwardVector(RandomVector(2))
		
		hTarget:FindModifierByName("modifier_pathfinder_acorn_shot_thinker").tree = tree

        local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_tree.vpcf"
	    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, tree )
	    ParticleManager:SetParticleControl( effect_cast, 0, tree:GetOrigin() )
	    ParticleManager:SetParticleControl( effect_cast, 1, Vector( 1, 1, 1 ) )
		ParticleManager:ReleaseParticleIndex( effect_cast )

		local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            vLocation,	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            70,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
		)
		if #units > 0 then
			for _,unit in pairs(units) do
				FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
			end
		end


        particle_cast = "particles/econ/items/juggernaut/bladekeeper_healing_ward/juggernaut_healing_ward_eruption_dc.vpcf"
        effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	    ParticleManager:SetParticleControl( effect_cast, 0, tree:GetOrigin()+Vector(1,0,0) )
		ParticleManager:ReleaseParticleIndex( effect_cast )
		
		local vo = {
			"hoodwink_hoodwink_acorn_gr_01",
			"hoodwink_hoodwink_acorn_gr_02",
			"hoodwink_hoodwink_acorn_gr_03",
			"hoodwink_hoodwink_acorn_gr_04",
			"hoodwink_hoodwink_acorn_gr_05",
			"hoodwink_hoodwink_acorn_gr_06",
			"hoodwink_hoodwink_acorn_gr_07",
			"hoodwink_hoodwink_acorn_gr_08_81",

			"hoodwink_hoodwink_acorn_gr_09",
			"hoodwink_hoodwink_acorn_gr_10",
			"hoodwink_hoodwink_acorn_gr_11",
			"hoodwink_hoodwink_acorn_gr_12_81",

			"hoodwink_hoodwink_acorn_gr_13",
			"hoodwink_hoodwink_acorn_gr_14",
			"hoodwink_hoodwink_acorn_gr_15_02",
		}
		self:GetCaster():EmitSoundParams(vo[RandomInt(1, #vo)], 0, 3, 0)
	end

    if table.bounce > 0 then
        -- Find enemy nearby
        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            hTarget:GetOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.bounce_range,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if #enemies > 0 then
            for _,enemy in pairs(enemies) do
                if enemy ~= hTarget then
                    local spell = self
                    Timers(spell.bounce_delay, function()
						spell:MakeProjectile(table.bounce - 1, hTarget, enemy)

                        if not spell:GetCaster():HasAbility("pathfinder_acorn_shot_tree") and hTarget:HasModifier("modifier_pathfinder_acorn_shot_thinker") then
                            hTarget:RemoveSelf()
                        end
                    end)
                    break
                end
            end
        end
    end
end


modifier_pathfinder_acorn_shot_thinker = class({})
function modifier_pathfinder_acorn_shot_thinker:Precache( context )
	PrecacheResource( "particle", "particles/items3_fx/fish_bones_active.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack_latch.vpcf", context )
	PrecacheResource( "soundfile", "DOTA_Item.FaerieSpark.Activate", context )
end

function modifier_pathfinder_acorn_shot_thinker:OnCreated(table)
	if IsServer() and self:GetCaster():HasAbility("pathfinder_acorn_shot_tree") then
		self.radius = self:GetCaster():FindAbilityByName("pathfinder_acorn_shot_tree"):GetLevelSpecialValueFor("radius",1)
		self.stun = self:GetCaster():FindAbilityByName("pathfinder_acorn_shot_tree"):GetLevelSpecialValueFor("stun_duration",1)
		self.heal_percent = self:GetCaster():FindAbilityByName("pathfinder_acorn_shot_tree"):GetLevelSpecialValueFor("heal_percent",1)
		self:StartIntervalThink(1)
	end
end

function modifier_pathfinder_acorn_shot_thinker:OnIntervalThink()
	if IsServer() and self:GetCaster():HasAbility("pathfinder_acorn_shot_tree") then

		local allies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			self:GetParent():GetAbsOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)
		for _,ally in pairs(allies) do
			local heal = ally:GetMaxHealth() / 100 * self.heal_percent
			ally:Heal(heal, self:GetAbility())

			local nFXIndex = ParticleManager:CreateParticle( "particles/items3_fx/fish_bones_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, ally )
			ParticleManager:ReleaseParticleIndex( nFXIndex )		
			self:GetParent():EmitSoundParams( "DOTA_Item.FaerieSpark.Activate", 0, 0.2, 0)
		end		
		local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack_latch.vpcf", PATTACH_WORLDORIGIN, self:GetParent() )
		ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetAbsOrigin() )
		ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
		ParticleManager:ReleaseParticleIndex(effect_cast)

		local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			self:GetParent():GetAbsOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
			FIND_ANY_ORDER,	-- int, order filter
			false	-- bool, can grow cache
		)
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_hoodwink_root", {duration = self.stun})

			end
		end
	end
end

function modifier_pathfinder_acorn_shot_thinker:OnDestroy()
	if not IsServer() then return end
	-- UTIL_Remove( self:GetParent() )
end

---------------------
modifier_hoodwink_root							= modifier_hoodwink_root or class({})

function modifier_hoodwink_root:GetEffectName()
	return "particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_root_small.vpcf"
end

function modifier_hoodwink_root:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
	}
end

---------------------

modifier_pathfinder_acorn_shot_debuff = class({
    IsHidden				= function(self) return false end,
	IsPurgable	  			= function(self) return true end,
	IsDebuff	  			= function(self) return true end,
})
function modifier_pathfinder_acorn_shot_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end

function modifier_pathfinder_acorn_shot_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetLevelSpecialValueFor("slow", self:GetAbility():GetLevel() -1) * -1
end

modifier_pathfinder_acorn_shot_preattack = class({
    IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,
})

function modifier_pathfinder_acorn_shot_preattack:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
  }

  return funcs
end

function modifier_pathfinder_acorn_shot_preattack:GetModifierPreAttack_BonusDamage() return
    self:GetAbility().bonus_damage
end

------
------
------

modifier_pathfinder_acorn_shot_attack = class({
    IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,
})

function modifier_pathfinder_acorn_shot_attack:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK    ,
  }

  return funcs
end

function modifier_pathfinder_acorn_shot_attack:OnAttack(params)
	if not IsServer() then return end
	if not self:GetCaster():HasAbility("pathfinder_acorn_shot_attack") or params.no_attack_cooldown or params.attacker ~= self:GetParent() or not params.target or params.target:IsBuilding() then
		return
	end

	if self.last_proc_time and GameRules:GetGameTime() - self.last_proc_time < 0.2 then
		return
	end

	local special = self:GetCaster():FindAbilityByName("pathfinder_acorn_shot_attack")
	if RollPseudoRandomPercentage( special:GetLevelSpecialValueFor("chance",1), DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, self:GetParent()) == true then
		self.last_proc_time = GameRules:GetGameTime()
		self:GetAbility():MakeProjectile( self:GetAbility():GetLevelSpecialValueFor("bounce_count", self:GetAbility():GetLevel()), self:GetParent(), params.target)
	end
end

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- SCURRY

pathfinder_scurry = class({})
LinkLuaModifier( "modifier_hoodwink_scurry_lua", "pathfinder/furry/pathfinder_hoodwink", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hoodwink_scurry_lua_buff", "pathfinder/furry/pathfinder_hoodwink", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Init Abilities
function pathfinder_scurry:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_hoodwink.vsndevts", context )
	PrecacheResource( "soundfile", "DOTA_Item.FaerieSpark.Activate", context )	
	PrecacheResource( "particle", "particles/units/heroes/hero_hoodwink/hoodwink_scurry.vpcf", context )
	PrecacheResource( "particle", "particles/items3_fx/fish_bones_active.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack_latch.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack_latch_edge.vpcf", context )
end

function pathfinder_scurry:Spawn()
	if not IsServer() then return end
end

--------------------------------------------------------------------------------
-- Passive Modifier
function pathfinder_scurry:GetIntrinsicModifierName()
	return "modifier_hoodwink_scurry_lua"
end

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Ability Start
function pathfinder_scurry:OnSpellStart()
	if not IsServer() then return end
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local duration = self:GetSpecialValueFor( "duration" )


	if caster:HasAbility("pathfinder_scurry_leap") then

		local vo = {
			"hoodwink_hoodwink_whirling_01",
			"hoodwink_hoodwink_whirling_02",
			"hoodwink_hoodwink_whirling_03",
			"hoodwink_hoodwink_whirling_04",
			"hoodwink_hoodwink_whirling_05",
			"hoodwink_hoodwink_whirling_06",
		}
		caster:EmitSoundParams(vo[RandomInt(1, #vo)], 0, 3, 0)

		local spell = self
		local special = caster:FindAbilityByName("pathfinder_scurry_leap")
		local distance = special:GetLevelSpecialValueFor("leap_distance",1)

		local knock_radius = special:GetLevelSpecialValueFor("knock_radius",1)
		local stun_duration = special:GetLevelSpecialValueFor("stun_duration",1)

		local point = self:GetCaster():GetAbsOrigin() - self:GetCaster():GetForwardVector() * 10

		local dur = special:GetLevelSpecialValueFor("leap_duration",1)
		local knock_origin = point
		local knockback =
		{
			knockback_duration = dur,
			duration = dur,
			knockback_distance = distance,
			knockback_height = 175,
			center_x = knock_origin.x,
			center_y = knock_origin.y,
			center_z = knock_origin.z,
		}
		caster:RemoveModifierByName("modifier_knockback")
		caster:AddNewModifier(self.caster, self, "modifier_knockback", knockback)
		
		Timers(dur, function()
			caster:RemoveGesture(ACT_DOTA_FLAIL)			

			local enemies = FindUnitsInRadius(
				caster:GetTeamNumber(),	-- int, your team number
				caster:GetAbsOrigin(),	-- point, center point
				nil,	-- handle, cacheUnit. (not known)
				knock_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
				DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
				0,	-- int, flag filter
				0,	-- int, order filter
				false	-- bool, can grow cache
			)
			
			local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack_latch_edge.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
			ParticleManager:SetParticleControl( effect_cast, 0, caster:GetAbsOrigin() )
			ParticleManager:SetParticleControl( effect_cast, 1, Vector( knock_radius, 0, 0 ) )
			ParticleManager:ReleaseParticleIndex(effect_cast)
			
			caster:EmitSoundParams("Hero_Hoodwink.AcornShot.Bounce", 0, 3, 0)			

			for _,enemy in pairs(enemies) do
				knockback.knockback_distance = knockback.knockback_distance / 3
				enemy:AddNewModifier(caster, spell, "modifier_knockback", knockback)
				enemy:AddNewModifier(caster, spell, "modifier_stunned", {duration = knockback.knockback_duration + stun_duration})

				caster:PerformAttack(enemy, false, true, true, false, true, false, false)				
			end
		end)
	else
		local vo = {
			"hoodwink_hoodwink_scurry_01",
			"hoodwink_hoodwink_scurry_02",
			"hoodwink_hoodwink_scurry_03",
			"hoodwink_hoodwink_scurry_03_81",

			"hoodwink_hoodwink_scurry_04",
			"hoodwink_hoodwink_scurry_05",
			"hoodwink_hoodwink_scurry_06",
			"hoodwink_hoodwink_scurry_07",
			"hoodwink_hoodwink_scurry_08",
			"hoodwink_hoodwink_scurry_09",
			"hoodwink_hoodwink_scurry_10",
			"hoodwink_hoodwink_scurry_11",
			"hoodwink_hoodwink_scurry_12",
			"hoodwink_hoodwink_scurry_13",
			"hoodwink_hoodwink_scurry_14",
			"hoodwink_hoodwink_scurry_15",
			"hoodwink_hoodwink_scurry_16",
			"hoodwink_hoodwink_scurry_17",

			"hoodwink_hoodwink_scurry_18_02",
		}
		caster:EmitSoundParams(vo[RandomInt(1, #vo)], 0, 3, 0)
	end

	if caster:HasAbility("pathfinder_scurry_allies") then
		local radius = caster:FindAbilityByName("pathfinder_scurry_allies"):GetLevelSpecialValueFor("radius",1)
		local extend_time = caster:FindAbilityByName("pathfinder_scurry_allies"):GetLevelSpecialValueFor("extend_time",1)

		local allies = FindUnitsInRadius(
			caster:GetTeamNumber(),	-- int, your team number
			caster:GetAbsOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)
		if #allies > 1 then
			duration = duration + extend_time * (#allies - 1)
			for _,ally in pairs(allies) do
				if ally ~= caster then
					-- add modifier
					ally:AddNewModifier(
						caster, -- player source
						self, -- ability source
						"modifier_hoodwink_scurry_lua_buff", -- modifier name
						{ duration = duration } -- kv
					)
					ally:AddNewModifier(
						caster, -- player source
						self, -- ability source
						"modifier_rune_invis", -- modifier name
						{ duration = duration } -- kv
					)
				end
			end
		end
		local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack_latch.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:SetParticleControl( effect_cast, 0, caster:GetAbsOrigin() )
		ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, 0, 0 ) )
		ParticleManager:ReleaseParticleIndex(effect_cast)

		caster:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_rune_invis", -- modifier name
			{ duration = duration } -- kv
		)
	end

	

	-- add modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_hoodwink_scurry_lua_buff", -- modifier name
		{ duration = duration } -- kv
	)
end

modifier_hoodwink_scurry_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_hoodwink_scurry_lua:IsHidden()
	return self:GetStackCount()~=0
end

function modifier_hoodwink_scurry_lua:IsDebuff()
	return false
end

function modifier_hoodwink_scurry_lua:IsStunDebuff()
	return false
end

function modifier_hoodwink_scurry_lua:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_hoodwink_scurry_lua:OnCreated( kv )
	self.parent = self:GetParent()

	-- references
	self.evasion = self:GetAbility():GetSpecialValueFor( "evasion" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.interval = 0.5

	if not IsServer() then return end

	-- Start interval
	self:StartIntervalThink( self.interval )
	self:OnIntervalThink()
end

function modifier_hoodwink_scurry_lua:OnRefresh( kv )
	-- references
	self.evasion = self:GetAbility():GetSpecialValueFor( "evasion" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
end

function modifier_hoodwink_scurry_lua:OnRemoved()
end

function modifier_hoodwink_scurry_lua:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_hoodwink_scurry_lua:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_EVASION_CONSTANT,
	}

	return funcs
end

function modifier_hoodwink_scurry_lua:GetModifierEvasion_Constant()
	if self:GetStackCount()==1 or self:GetParent():PassivesDisabled() then return 0 end

	return self.evasion
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_hoodwink_scurry_lua:OnIntervalThink()
	-- check trees
	local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
				self:GetParent():GetAbsOrigin(),
				nil,
				self.radius,
				DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				DOTA_UNIT_TARGET_OTHER,
				DOTA_UNIT_TARGET_FLAG_NONE,
				FIND_ANY_ORDER,
				false)	
	local temp_count = 0
	for _,unit in pairs(units) do
		if unit:GetUnitName() == "pathfinder_hoodwink_tree" or unit:GetUnitName() == "pathfinder_hoodwink_tree_special" then
			temp_count = temp_count + 1
		end
	end

	local trees = GridNav:GetAllTreesAroundPoint( self.parent:GetOrigin(), self.radius, false )
	local stack = 1
	if #trees>0 or temp_count > 0 then stack = 0 end

	-- stack: 0 is active, 1 is inactive (no tree)
	if self:GetStackCount()~=stack then
		self:SetStackCount( stack )

		-- set effects
		if stack==0 then
			self:PlayEffects()
		else
			self:StopEffects()
		end
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_hoodwink_scurry_lua:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_scurry_passive.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( self.radius, 0, 0 ) )

	self.effect_cast = effect_cast
end

function modifier_hoodwink_scurry_lua:StopEffects()
	if not self.effect_cast then return end

	ParticleManager:DestroyParticle( self.effect_cast, false )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )
end

modifier_hoodwink_scurry_lua_buff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_hoodwink_scurry_lua_buff:IsHidden()
	return false
end

function modifier_hoodwink_scurry_lua_buff:IsDebuff()
	return false
end

function modifier_hoodwink_scurry_lua_buff:IsStunDebuff()
	return false
end

function modifier_hoodwink_scurry_lua_buff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_hoodwink_scurry_lua_buff:OnCreated( kv )
	-- references
	self.movespeed = self:GetAbility():GetSpecialValueFor( "movement_speed_pct" )

	if not IsServer() then return end

	-- play effects
	local sound_cast = "Hero_Hoodwink.Scurry.Cast"
	EmitSoundOn( sound_cast, self:GetParent() )

	if self:GetCaster():HasAbility("pathfinder_scurry_canadian") then
		self:StartIntervalThink(0.1)
	end
	 

	if self:GetCaster():HasAbility("pathfinder_bushwhack_scurry") then
		local netInterval = self:GetCaster():FindAbilityByName("pathfinder_bushwhack_scurry"):GetLevelSpecialValueFor( "interval", 1 )
		local this_mod = self
		Timers(0, function()
			if this_mod == nil or CEntityInstance.IsNull(this_mod) then
				return nil
			else
				this_mod:CastTreeAndNet()
				return netInterval
			end
		end)			
	end
end

function modifier_hoodwink_scurry_lua_buff:OnRefresh( kv )
	self.movespeed = self:GetAbility():GetSpecialValueFor( "movement_speed_pct" )
end

function modifier_hoodwink_scurry_lua_buff:OnRemoved()
end

function modifier_hoodwink_scurry_lua_buff:CastTreeAndNet()
	if self:GetCaster():HasAbility("pathfinder_bushwhack_scurry") then
		local point = self:GetParent():GetAbsOrigin() - self:GetParent():GetForwardVector() * 110
		if not self:GetCaster():HasAbility("pathfinder_bushwhack_ground") then
			local tree_model = "pathfinder_hoodwink_tree"			

			if self:GetCaster():HasAbility("pathfinder_acorn_shot_tree") then
				tree_model = "pathfinder_hoodwink_tree_special"
			end

			local tree = CreateUnitByName(tree_model, point, true, nil, nil, DOTA_TEAM_GOODGUYS)	
			tree:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = 20})
			tree:AddNewModifier(self:GetCaster(), self, "modifier_pathfinder_temp_tree", {})
			tree:SetForwardVector(RandomVector(2))

			if self:GetCaster():HasAbility("pathfinder_acorn_shot_tree") then
				local thinker = CreateModifierThinker(
					self:GetCaster(), -- player source
					self:GetAbility(), -- ability source
					"modifier_pathfinder_acorn_shot_thinker", -- modifier name
					{duration =  20 }, -- kv
					point,
					self:GetCaster():GetTeamNumber(),
					false
				)
				thinker:FindModifierByName("modifier_pathfinder_acorn_shot_thinker").tree = tree
			end
			
			local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_tree.vpcf"
			local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, tree )
			ParticleManager:SetParticleControl( effect_cast, 0, tree:GetOrigin() )
			ParticleManager:SetParticleControl( effect_cast, 1, Vector( 1, 1, 1 ) )
			ParticleManager:ReleaseParticleIndex( effect_cast )

			local units = FindUnitsInRadius(
				self:GetCaster():GetTeamNumber(),	-- int, your team number
				point,	-- point, center point
				nil,	-- handle, cacheUnit. (not known)
				70,	-- float, radius. or use FIND_UNITS_EVERYWHERE
				DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
				DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
				0,	-- int, order filter
				false	-- bool, can grow cache
			)
			if #units > 0 then
				for _,unit in pairs(units) do
					FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
				end
			end

			particle_cast = "particles/econ/items/juggernaut/bladekeeper_healing_ward/juggernaut_healing_ward_eruption_dc.vpcf"
			effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
			ParticleManager:SetParticleControl( effect_cast, 0, tree:GetOrigin()+Vector(1,0,0) )
			ParticleManager:ReleaseParticleIndex( effect_cast )
		end
			
		if self:GetCaster():FindAbilityByName("pathfinder_bushwhack"):GetLevel() > 0  then
			local caster = self:GetCaster()
			Timers(0.45, function()
				local prev_cursor = caster:GetCursorPosition()
				caster:SetCursorPosition(point)
				caster:FindAbilityByName("pathfinder_bushwhack"):OnSpellStart()
				caster:SetCursorPosition(prev_cursor)
			end)	
		end
	end
end

function modifier_hoodwink_scurry_lua_buff:OnDestroy()
	if not IsServer() then return end

	-- play effects
	local sound_cast = "Hero_Hoodwink.Scurry.End"
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_hoodwink_scurry_lua_buff:OnIntervalThink()
	if not IsServer() then return end

	if self:GetCaster():HasAbility("pathfinder_scurry_canadian") then
		local forward_point = self:GetParent():GetAbsOrigin() + self:GetParent():GetForwardVector() * 25
		local radius = 65

		local heal = self:GetParent():GetMaxHealth() / 100 * self:GetCaster():FindAbilityByName("pathfinder_scurry_canadian"):GetLevelSpecialValueFor("heal_percent",1)
		local regrow_time = self:GetCaster():FindAbilityByName("pathfinder_scurry_canadian"):GetLevelSpecialValueFor("regrow_time",1)
		local extend_time = self:GetCaster():FindAbilityByName("pathfinder_scurry_canadian"):GetLevelSpecialValueFor("extend_time",1)

		local trees = GridNav:GetAllTreesAroundPoint(forward_point, radius, false)
		for _,tree in pairs(trees) do
			self:GetParent():Heal(heal, self:GetAbility())
			self:SetDuration(self:GetDuration() + extend_time, true)

			local nFXIndex = ParticleManager:CreateParticle( "particles/items3_fx/fish_bones_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
			self:GetParent():EmitSoundParams( "DOTA_Item.FaerieSpark.Activate", 0, 0.5, 0)

			if tree:GetClassname() == "ent_dota_tree" then
				tree:CutDownRegrowAfter(regrow_time, self:GetParent():GetTeamNumber())
			else
				GridNav:DestroyTreesAroundPoint(tree:GetOrigin(), 1, false)
			end
		end

		local enemies = FindUnitsInRadius(
				self:GetCaster():GetTeamNumber(),	-- int, your team number
				forward_point,	-- point, center point
				nil,	-- handle, cacheUnit. (not known)
				radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
				DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
				DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_OTHER,	-- int, type filter
				0,	-- int, flag filter
				0,	-- int, order filter
				false	-- bool, can grow cache
		)
		for _,crate in pairs(enemies) do
			print(crate:GetUnitName())
			if crate:GetUnitName() == "npc_dota_crate" or crate:GetUnitName() == "pf_crate" or crate:GetUnitName() == "npc_dota_cage" or crate:GetUnitName() == "pathfinder_hoodwink_tree" or crate:GetUnitName() == "pathfinder_hoodwink_tree_special" then
				crate:ForceKill(false)
				self:GetParent():Heal(heal, self:GetAbility())
				self:SetDuration(self:GetDuration() + extend_time, true)

				local nFXIndex = ParticleManager:CreateParticle( "particles/items3_fx/fish_bones_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
				ParticleManager:ReleaseParticleIndex( nFXIndex )
				self:GetParent():EmitSoundParams( "DOTA_Item.FaerieSpark.Activate", 0, 0.5, 0)
			end
		end
	end

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_hoodwink_scurry_lua_buff:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}

	return funcs
end

function modifier_hoodwink_scurry_lua_buff:GetActivityTranslationModifiers()
	return "scurry"
end

function modifier_hoodwink_scurry_lua_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_hoodwink_scurry_lua_buff:GetModifierIgnoreMovespeedLimit()
	return 1
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_hoodwink_scurry_lua_buff:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_hoodwink_scurry_lua_buff:GetEffectName()
	return "particles/units/heroes/hero_hoodwink/hoodwink_scurry_aura.vpcf"
end

function modifier_hoodwink_scurry_lua_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- SHARPSHOOTER
pathfinder_sharpshooter = class({})

LinkLuaModifier( "modifier_pathfinder_sharpshooter", "pathfinder/furry/pathfinder_hoodwink", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pathfinder_sharpshooter_debuff", "pathfinder/furry/pathfinder_hoodwink", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Init Abilities
function pathfinder_sharpshooter:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_hoodwink.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_projectile.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_impact.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_target.vpcf", context )
	PrecacheResource( "particle", "particles/items_fx/force_staff.vpcf", context )
end

function pathfinder_sharpshooter:Spawn()
    if not IsServer() then
        return
    else
        self:GetCaster():FindAbilityByName("pathfinder_sharpshooter_release"):SetLevel(1)
    end
end


function pathfinder_sharpshooter:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("arrow_range")
end

--------------------------------------------------------------------------------
-- Ability Start
function pathfinder_sharpshooter:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	
	-- load data
	local duration = self:GetSpecialValueFor( "misfire_time" )

	if caster:HasAbility("special_bonus_unique_pathfinder_sharpshooter_invis") and caster:FindAbilityByName("special_bonus_unique_pathfinder_sharpshooter_invis"):GetLevel() > 0 then
		caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_invisible", -- modifier name
		{ duration = duration } -- kv
	)
	end

	-- add modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_pathfinder_sharpshooter", -- modifier name
		{ duration = duration } -- kv
	)

	self.captains_hit = {
		0,
		0,
		0,
		0,
		0, -- assuming there's 5 projectile
	}

	local vo = {
		"hoodwink_hoodwink_arbalest_01",
		"hoodwink_hoodwink_arbalest_02",
		"hoodwink_hoodwink_arbalest_03",
		"hoodwink_hoodwink_arbalest_04",
		"hoodwink_hoodwink_arbalest_05",
		"hoodwink_hoodwink_arbalest_06",
		"hoodwink_hoodwink_arbalest_07",
		"hoodwink_hoodwink_arbalest_08",
		"hoodwink_hoodwink_arbalest_09",
		"hoodwink_hoodwink_arbalest_10",
		"hoodwink_hoodwink_arbalest_11",
		"hoodwink_hoodwink_arbalest_11_02",
		"hoodwink_hoodwink_arbalest_12",
		"hoodwink_hoodwink_arbalest_13",
		"hoodwink_hoodwink_arbalest_14",
		"hoodwink_hoodwink_arbalest_15",
		"hoodwink_hoodwink_arbalest_16",
		"hoodwink_hoodwink_arbalest_17",
		"hoodwink_hoodwink_arbalest_18",

		"hoodwink_hoodwink_arbalest_20",
		"hoodwink_hoodwink_arbalest_20_02",
		"hoodwink_hoodwink_arbalest_20_03",

		"hoodwink_hoodwink_arbalest_21",
		"hoodwink_hoodwink_arbalest_21_02",
		"hoodwink_hoodwink_arbalest_21_03",
	}
	caster:EmitSoundParams(vo[RandomInt(1, #vo)], 0, 3, 0)
end
--------------------------------------------------------------------------------
-- Projectile
function pathfinder_sharpshooter:OnProjectileHit_ExtraData( target, location, ExtraData )
	if not target then return end

	local caster = self:GetCaster()
	
	-- modifier
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_pathfinder_sharpshooter_debuff", -- modifier name
		{
			duration = ExtraData.duration,
			x = ExtraData.x,
			y = ExtraData.y
		} -- kv
	)

	-- damage
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = ExtraData.damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
		damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
	}
	if not target:IsConsideredHero() then
		damageTable.damage = damageTable.damage / 2
	end
	ApplyDamage(damageTable)

	-- play effects
	local direction = Vector( ExtraData.x, ExtraData.y, 0 ):Normalized()
	self:PlayEffects( target, direction )

	if target:IsConsideredHero() then
		self.captains_hit[ExtraData.id_slot] = self.captains_hit[ExtraData.id_slot] + 1

		local max_hit = self:GetSpecialValueFor("max_hit")
		-- if self:GetCaster():HasAbility("pathfinder_sharpshooter_pierce") then
		-- 	max_hit = self:GetCaster():FindAbilityByName("pathfinder_sharpshooter_pierce"):GetLevelSpecialValueFor("captains_hit",1)
		-- end
		if self.captains_hit[ExtraData.id_slot] >= max_hit then			
			local vo = {
				"hoodwink_hoodwink_arb_hit_01_81",
				"hoodwink_hoodwink_arb_hit_01_81_02",
				"hoodwink_hoodwink_arb_hit_01_81_03",
				"hoodwink_hoodwink_arb_hit_01_81_05",

				"hoodwink_hoodwink_arb_hit_02",
				"hoodwink_hoodwink_arb_hit_03",
				"hoodwink_hoodwink_arb_hit_04",
				"hoodwink_hoodwink_arb_hit_05",
				"hoodwink_hoodwink_arb_hit_06",
				"hoodwink_hoodwink_arb_hit_07",
				"hoodwink_hoodwink_arb_hit_08",
				"hoodwink_hoodwink_arb_hit_09",

				"hoodwink_hoodwink_arb_hit_10",
				"hoodwink_hoodwink_arb_hit_11",
				"hoodwink_hoodwink_arb_hit_12",
				"hoodwink_hoodwink_arb_hit_13",
				"hoodwink_hoodwink_arb_hit_14",
				"hoodwink_hoodwink_arb_hit_15",
				"hoodwink_hoodwink_arb_hit_16",
				"hoodwink_hoodwink_arb_hit_17",
				"hoodwink_hoodwink_arb_hit_18",
				"hoodwink_hoodwink_arb_hit_19",
				"hoodwink_hoodwink_arb_hit_20",
			}

			Timers(0.5, function()
				caster:EmitSoundParams(vo[RandomInt(1, #vo)], 0, 3, 0)
			end)			
			return true
		end
    end
end


function pathfinder_sharpshooter:OnProjectileThink(vLocation)	
	if IsServer() and self:GetCaster():HasAbility("pathfinder_sharpshooter_moving") then		
		if true then

			local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
				vLocation,
				nil,
				self:GetCaster():FindAbilityByName("pathfinder_sharpshooter_moving"):GetLevelSpecialValueFor("tree_gap", 1),
				DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				DOTA_UNIT_TARGET_OTHER,
				DOTA_UNIT_TARGET_FLAG_NONE,
				FIND_ANY_ORDER,
				false)
			local temp_count = 0
			for _,unit in pairs(units) do
				if unit:GetUnitName() == "pathfinder_hoodwink_tree" or unit:GetUnitName() == "pathfinder_hoodwink_tree_special" then
					temp_count = temp_count + 1
				end
			end
			
			if temp_count < 1 then
				local tree_model = "pathfinder_hoodwink_tree"
				if self:GetCaster():HasAbility("pathfinder_acorn_shot_tree") then
					tree_model = "pathfinder_hoodwink_tree_special"
				end

				local tree = CreateUnitByName(tree_model, vLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)		
				tree:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = 20})
				tree:AddNewModifier(self:GetCaster(), self, "modifier_pathfinder_temp_tree", {})
				tree:SetForwardVector(RandomVector(2))

				if self:GetCaster():HasAbility("pathfinder_acorn_shot_tree") then
					local thinker = CreateModifierThinker(
						self:GetCaster(), -- player source
						self, -- ability source
						"modifier_pathfinder_acorn_shot_thinker", -- modifier name
						{duration =  20 }, -- kv
						vLocation,
						self:GetCaster():GetTeamNumber(),
						false
					)
					thinker:FindModifierByName("modifier_pathfinder_acorn_shot_thinker").tree = tree
				end
				
				local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_tree.vpcf"
				local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, tree )
				ParticleManager:SetParticleControl( effect_cast, 0, tree:GetOrigin() )
				ParticleManager:SetParticleControl( effect_cast, 1, Vector( 1, 1, 1 ) )
				ParticleManager:ReleaseParticleIndex( effect_cast )

				local units = FindUnitsInRadius(
					self:GetCaster():GetTeamNumber(),	-- int, your team number
					vLocation,	-- point, center point
					nil,	-- handle, cacheUnit. (not known)
					70,	-- float, radius. or use FIND_UNITS_EVERYWHERE
					DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
					DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
					0,	-- int, order filter
					false	-- bool, can grow cache
				)
				if #units > 0 then
					for _,unit in pairs(units) do
						FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
					end
				end
			
			end			
		end
	end
end


function pathfinder_sharpshooter:GetAbilityTargetType()
	-- if IsServer() and self:GetCaster():HasAbility("pathfinder_sharpshooter_pierce") then
		return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	-- else
	-- 	return DOTA_UNIT_TARGET_HERO
	-- end
end

--------------------------------------------------------------------------------
-- Effects
function pathfinder_sharpshooter:PlayEffects( target, direction )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_impact.vpcf"
	local sound_cast = "Hero_Hoodwink.Sharpshooter.Target"

	-- Get Data

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 0, target:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 1, direction )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, target )
end


----------------------------
----------------------------
----------------------------

modifier_pathfinder_sharpshooter = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_sharpshooter:IsHidden()
	return false
end

function modifier_pathfinder_sharpshooter:IsDebuff()
	return false
end

function modifier_pathfinder_sharpshooter:IsStunDebuff()
	return false
end

function modifier_pathfinder_sharpshooter:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations

function modifier_pathfinder_sharpshooter:OnCreated( kv )
    -- references

	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.team = self.parent:GetTeamNumber()

	self.charge = self:GetAbility():GetSpecialValueFor( "max_charge_time" )
	self.damage = self:GetAbility():GetSpecialValueFor( "max_damage" )
	self.duration = self:GetAbility():GetSpecialValueFor( "max_slow_debuff_duration" )
	self.turn_rate = self:GetAbility():GetSpecialValueFor( "turn_rate" )

	self.recoil_distance = self:GetAbility():GetSpecialValueFor( "recoil_distance" )
	self.recoil_duration = self:GetAbility():GetSpecialValueFor( "recoil_duration" )
    self.recoil_height = self:GetAbility():GetSpecialValueFor( "recoil_height" )

    self.projectile_speed = self:GetAbility():GetSpecialValueFor( "arrow_speed" )
	self.projectile_range = self:GetAbility():GetSpecialValueFor( "arrow_range" )
	self.projectile_width = self:GetAbility():GetSpecialValueFor( "arrow_width" )
	local projectile_vision = self:GetAbility():GetSpecialValueFor( "arrow_vision" )
    local projectile_name = "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_projectile.vpcf"

	-- set interval on both cl and sv
    self:StartIntervalThink( 0.03 )



    if not IsServer() then return end
    self.desired_target = self:GetAbility():GetCursorPosition()
    self:PlayEffects1()
    self:PlayEffects2()

    self.caster:SwapAbilities(
		self:GetAbility():GetAbilityName(),
		"pathfinder_sharpshooter_release",
		false,
		true
	)

    local the_self = self
    self.just_started = true
    Timers(0.5, function()
        the_self.just_started = false
    end)

	self.caster:StartGesture(ACT_DOTA_CHANNEL_ABILITY_6)

	-- precache projectile
	self.info = {
		Source = self.parent,
		Ability = self:GetAbility(),
		-- vSpawnOrigin = caster:GetAbsOrigin(),

	    bDeleteOnHit = false,

	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	    iUnitTargetType = self:GetAbility():GetAbilityTargetType(),

	    EffectName = projectile_name,
	    fDistance = self.projectile_range,
	    fStartRadius = self.projectile_width,
	    fEndRadius = self.projectile_width,
		-- vVelocity = projectile_direction * projectile_speed,

		bHasFrontalCone = false,
		bReplaceExisting = false,

		bProvidesVision = true,
		iVisionRadius = projectile_vision,
		iVisionTeamNumber = self.caster:GetTeamNumber()
	}
end

function modifier_pathfinder_sharpshooter:OnRefresh( kv )

end

function modifier_pathfinder_sharpshooter:OnRemoved()
end

function modifier_pathfinder_sharpshooter:OnDestroy()

    if not IsServer() then return end

    self.caster:SwapAbilities(
		self:GetAbility():GetAbilityName(),
		"pathfinder_sharpshooter_release",
		true,
		false
    )

    self.caster:FadeGesture(ACT_DOTA_CHANNEL_ABILITY_6)
	-- calculate direction
	local direction = self.parent:GetForwardVector()

	-- calculate percentage
	local pct = math.min( self:GetElapsedTime(), self.charge )/self.charge

	-- Launch projectile
	self.info.vSpawnOrigin = self.parent:GetOrigin()
    self.info.vVelocity = direction * self.projectile_speed

	self.info.vVelocity.z = 0

	self.info.ExtraData = {
		damage = self.damage * pct,
		duration = self.duration * pct,
		x = direction.x,
		y = direction.y,
		id_slot = 1,
	}

	ProjectileManager:CreateLinearProjectile( self.info )

	if self:GetCaster():FindAbilityByName("pathfinder_sharpshooter_spread") then
		local num_shot = self:GetCaster():FindAbilityByName("pathfinder_sharpshooter_spread"):GetLevelSpecialValueFor("extra_shots",1)
		local angle = 30		
		for i=1,math.floor(num_shot/2) do
			local left_qangle = QAngle(0, angle * i, 0)
			local right_qangle = QAngle(0, -angle * i, 0)

			local left = RotatePosition(self:GetCaster():GetAbsOrigin(), left_qangle, self:GetCaster():GetAbsOrigin() + direction * 200)		
			local right = RotatePosition(self:GetCaster():GetAbsOrigin(), right_qangle, self:GetCaster():GetAbsOrigin() + direction * 200)

			local spread_dir = (left - self:GetCaster():GetAbsOrigin()):Normalized()
			spread_dir.z = 0

			self.info.vVelocity = spread_dir * self.projectile_speed
			self.info.ExtraData = {	
				damage = self.damage * pct,
				duration = self.duration * pct,
				x = spread_dir.x,
				y = spread_dir.y,
				id_slot = i + 1
			}
			ProjectileManager:CreateLinearProjectile( self.info )

			spread_dir = (right - self:GetCaster():GetAbsOrigin()):Normalized()
			spread_dir.z = 0

			self.info.vVelocity = spread_dir * self.projectile_speed
			self.info.ExtraData = {	
				damage = self.damage * pct,
				duration = self.duration * pct,
				x = spread_dir.x,
				y = spread_dir.y,
				id_slot = i + math.floor(num_shot / 2) + 1
			}
			ProjectileManager:CreateLinearProjectile( self.info )
		end		
	end

	if not self:GetParent():IsAlive() then return end

    -- knockback
    local knock_origin = self.caster:GetAbsOrigin() + self.caster:GetForwardVector() * 2
    local knockback =
    {
        knockback_duration = self.recoil_duration,
        duration = self.recoil_duration,
        knockback_distance = self.recoil_distance,
        knockback_height = self.recoil_height,
        center_x = knock_origin.x,
		center_y = knock_origin.y,
		center_z = knock_origin.z,
    }
    self.caster:RemoveModifierByName("modifier_knockback")
	local mod = self.caster:AddNewModifier(self.caster, self, "modifier_knockback", knockback)

	local caster = self.caster
	
    
    caster:AddNewModifier(caster, self:GetAbility(), "modifier_phased", {duration = 2 + self.recoil_duration})
    Timers(self.recoil_duration, function()
		caster:RemoveGesture(ACT_DOTA_FLAIL)
    end)

	-- play effects
	self:PlayEffects4( mod )

	if caster:HasAbility("special_bonus_unique_pathfinder_sharpshooter_invis") and caster:FindAbilityByName("special_bonus_unique_pathfinder_sharpshooter_invis"):GetLevel() > 0 and caster:HasModifier("modifier_invisible") then
		caster:RemoveModifierByName("modifier_invisible")
	end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_pathfinder_sharpshooter:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_TURNING,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,		
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}

	return funcs
end

function modifier_pathfinder_sharpshooter:GetEffectName()
	if IsServer() and self:GetCaster():HasAbility("pathfinder_sharpshooter_moving") then
		return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_blur.vpcf"	
	end
end

function modifier_pathfinder_sharpshooter:GetModifierIncomingDamage_Percentage()
	if IsServer() and self:GetCaster():HasAbility("pathfinder_sharpshooter_moving") then		
		return -1 * self:GetCaster():FindAbilityByName("pathfinder_sharpshooter_moving"):GetLevelSpecialValueFor("damage_reduction",1)
	end
end

function modifier_pathfinder_sharpshooter:GetModifierMoveSpeed_Limit()
	return 0.1	
end

function modifier_pathfinder_sharpshooter:GetModifierDisableTurning()
	return 1
end

function modifier_pathfinder_sharpshooter:OnOrder( params )
	if params.unit~=self:GetParent() then return end

	-- right click, switch position
	if 	params.order_type==DOTA_UNIT_ORDER_MOVE_TO_POSITION then
		-- face towards
		self.desired_target = params.new_pos

	elseif
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_TARGET or
		params.order_type==DOTA_UNIT_ORDER_ATTACK_TARGET
	then
		self.desired_target =  params.target:GetOrigin()

	elseif
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_DIRECTION
	then
        self.desired_target =  params.new_pos
    end
end


--------------------------------------------------------------------------------
-- Status Effects
function modifier_pathfinder_sharpshooter:CheckState()
	local state = {
        [MODIFIER_STATE_DISARMED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_pathfinder_sharpshooter:OnIntervalThink()
	if not IsServer() then
		-- client only code
		self:UpdateStack()
		return
	end

	-- max charge sound
	if not self.charged and self:GetElapsedTime()>self.charge then
		self.charged = true

		-- play effects
		local sound_cast = "Hero_Hoodwink.Sharpshooter.MaxCharge"
		EmitSoundOnClient( sound_cast, self.parent:GetPlayerOwner() )

		local caster = self.parent
		local vo = {
			"hoodwink_hoodwink_ability_stop_01",
			"hoodwink_hoodwink_ability_stop_02",
			"hoodwink_hoodwink_ability_stop_02_02",
			"hoodwink_hoodwink_ability_stop_03",
			"hoodwink_hoodwink_ability_stop_04",
			"hoodwink_hoodwink_ability_stop_05",
			"hoodwink_hoodwink_ability_stop_05_02",

			"hoodwink_hoodwink_ability_stop_06",
			"hoodwink_hoodwink_ability_stop_07",
			"hoodwink_hoodwink_ability_stop_08",
			"hoodwink_hoodwink_ability_stop_09",
			"hoodwink_hoodwink_ability_stop_10",
			"hoodwink_hoodwink_ability_stop_10_02",

			"hoodwink_hoodwink_ability_stop_11",
			"hoodwink_hoodwink_ability_stop_12",
			"hoodwink_hoodwink_ability_stop_13",
		}
		Timers(0.5, function()
			self.parent:EmitSoundParams(vo[RandomInt(1, #vo)], 0, 3, 0)
		end)		
	end

	-- vision
	-- NOTE: Can be optimized if there's a way to move vision provider dynamically
	local startpos = self.parent:GetOrigin()
	local visions = self.projectile_range/self.projectile_width
	local delta = self.parent:GetForwardVector() * self.projectile_width
	for i=1,visions do
		AddFOWViewer( self.team, startpos, self.projectile_width, 0.1, false )
		startpos = startpos + delta
	end

	-- timer particle
	local remaining = self:GetRemainingTime()
	local seconds = math.ceil( remaining )
	local isHalf = (seconds-remaining)>0.5
	if isHalf then seconds = seconds-1 end

	if self.half~=isHalf then
		self.half = isHalf

		-- play effects
		self:PlayEffects3( seconds, isHalf )
    end

    if self.desired_target then
        local turn_rate = self.turn_rate
        if self.just_started == true then
            turn_rate = turn_rate * 2
        end
        self:TurnToTargetDir(turn_rate, self.desired_target)
	end

    -- update paticle
    self:UpdateEffect()
end

function modifier_pathfinder_sharpshooter:UpdateStack()
	-- only update stack percentage on client to reduce traffic
	local pct = math.min( self:GetElapsedTime(), self.charge )/self.charge
	pct = math.floor( pct*100 )
	self:SetStackCount( pct )
end

function modifier_pathfinder_sharpshooter:TurnToTargetDir(degree_per_second, desired_target)
    local current_forward = self.caster:GetForwardVector():Normalized()
    local desired_forward = (self.desired_target - self.caster:GetAbsOrigin()):Normalized()

    local angle_between = math.deg(math.acos(DotProduct(current_forward, desired_forward)))
    if angle_between > 2 then
        local forward_point = self.caster:GetAbsOrigin() + self.caster:GetForwardVector() * 30
        local degree_per_interval = degree_per_second * 0.03

        local angle_right = QAngle(0, degree_per_interval, 0)
        local angle_left = QAngle(0, -degree_per_interval, 0)

        local forward_point_right = RotatePosition(self.caster:GetAbsOrigin(), angle_right, forward_point)
        local forward_point_left = RotatePosition(self.caster:GetAbsOrigin(), angle_left, forward_point)

        local closest = forward_point_right
        local right_to_target = math.deg(math.acos(DotProduct(desired_forward, (forward_point_right - self.caster:GetAbsOrigin()):Normalized())))
        local left_to_target = math.deg(math.acos(DotProduct(desired_forward, (forward_point_left - self.caster:GetAbsOrigin()):Normalized())))

        if left_to_target < right_to_target then
            closest = forward_point_left
        end

        if not self.caster:IsCurrentlyHorizontalMotionControlled() and not self.caster:IsCurrentlyVerticalMotionControlled() then
            self.caster:SetForwardVector((closest - self.caster:GetAbsOrigin()):Normalized())
        end
    end
end

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_pathfinder_sharpshooter:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter.vpcf"
	local sound_cast = "Hero_Hoodwink.Sharpshooter.Channel"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self.parent,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		self.parent:GetOrigin(), -- unknown
		true -- unknown, true
	)

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	EmitSoundOn( sound_cast, self.parent )
end

function modifier_pathfinder_sharpshooter:PlayEffects2()
	--NOTE: This could be a client-only code to reduce traffic, if only GetForwardVector is available on client. (Why GetAbsOrigin is available but not GetForwardVector?)

	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_range_finder.vpcf"

	-- Get Data
	local startpos = self.parent:GetAbsOrigin()
	local endpos = startpos + self.parent:GetForwardVector() * self.projectile_range

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticleForPlayer( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent, self.parent:GetPlayerOwner() )
	ParticleManager:SetParticleControl( effect_cast, 0, startpos )
	ParticleManager:SetParticleControl( effect_cast, 1, endpos )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
	self.effect_cast = effect_cast
end

function modifier_pathfinder_sharpshooter:PlayEffects3( seconds, half )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_timer.vpcf"

	-- calculate data
	local mid = 1
	if half then mid = 8 end

	local len = 2
	if seconds<1 then
		len = 1
		if not half then return end
	end

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( 1, seconds, mid ) )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( len, 0, 0 ) )
end

function modifier_pathfinder_sharpshooter:PlayEffects4( modifier )
	-- Get Resources
	local particle_cast = "particles/items_fx/force_staff.vpcf"
	local sound_channel = "Hero_Hoodwink.Sharpshooter.Channel"
	local sound_cast = "Hero_Hoodwink.Sharpshooter.Cast"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )

	-- buff particle
	modifier:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- sound
	StopSoundOn( sound_channel, self.caster )
	EmitSoundOn( sound_cast, self.caster )
end

function modifier_pathfinder_sharpshooter:UpdateEffect()
	--NOTE: This could be a client-only code to reduce traffic, if only GetForwardVector is available on client. (Why GetAbsOrigin is available but not GetForwardVector?)
    if not self.effect_cast then return end
	-- Get Data
	local startpos = self.parent:GetAbsOrigin()
	local endpos = startpos + self.parent:GetForwardVector() * self.projectile_range

	ParticleManager:SetParticleControl( self.effect_cast, 0, startpos )
	ParticleManager:SetParticleControl( self.effect_cast, 1, endpos )
end


------------
------------
------------

modifier_pathfinder_sharpshooter_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_sharpshooter_debuff:IsHidden()
	return false
end

function modifier_pathfinder_sharpshooter_debuff:IsDebuff()
	return true
end

function modifier_pathfinder_sharpshooter_debuff:IsStunDebuff()
	return false
end

function modifier_pathfinder_sharpshooter_debuff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_pathfinder_sharpshooter_debuff:OnCreated( kv )
	-- references
	self.parent = self:GetParent()

	self.slow = -self:GetAbility():GetSpecialValueFor( "slow_move_pct" )

	if not IsServer() then return end

	-- play effects
	local direction = Vector( kv.x, kv.y, 0 ):Normalized()
	self:PlayEffects( direction )
end

function modifier_pathfinder_sharpshooter_debuff:OnRefresh( kv )
end

function modifier_pathfinder_sharpshooter_debuff:OnRemoved()
end

function modifier_pathfinder_sharpshooter_debuff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_pathfinder_sharpshooter_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT,
	}

	return funcs
end

function modifier_pathfinder_sharpshooter_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_pathfinder_sharpshooter_debuff:OnTakeDamageKillCredit( params )
	if IsServer() then
		if params.target == self:GetParent() and params.inflictor and params.inflictor == self:GetAbility() and self:GetCaster():HasAbility("pathfinder_sharpshooter_reset") and params.damage >= params.target:GetHealth() then
			if self:GetCaster():HasAbility("pathfinder_scurry") then
				self:GetCaster():FindAbilityByName("pathfinder_scurry"):OnSpellStart()
			end
			self:GetCaster():FindAbilityByName("pathfinder_sharpshooter"):EndCooldown()
			self:GetCaster():FindAbilityByName("pathfinder_sharpshooter"):StartCooldown(math.max(0,self:GetCaster():FindAbilityByName("pathfinder_sharpshooter"):GetEffectiveCooldown(self:GetAbility():GetLevel()) - self:GetCaster():FindAbilityByName("pathfinder_sharpshooter_reset"):GetLevelSpecialValueFor("reduction",1)))
		end		
    end
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_pathfinder_sharpshooter_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_pathfinder_sharpshooter_debuff:PlayEffects( direction )
	-- NOTE: Particle doesn't appear, don't know why

	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_debuff.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self.parent,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		self.parent:GetOrigin(), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlForward( effect_cast, 1, direction )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- BUSHWHACH

--------------------------------------------------------------------------------
pathfinder_bushwhack = class({})
LinkLuaModifier( "modifier_pathfinder_bushwhack_thinker", "pathfinder/furry/pathfinder_hoodwink", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pathfinder_bushwhack_debuff", "pathfinder/furry/pathfinder_hoodwink", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_pathfinder_bushwhack_multi_attack", "pathfinder/furry/pathfinder_hoodwink", LUA_MODIFIER_MOTION_HORIZONTAL )

--------------------------------------------------------------------------------
-- Init Abilities
function pathfinder_bushwhack:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_hoodwink.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack_fail.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack_projectile.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack_target.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/juggernaut/bladekeeper_healing_ward/juggernaut_healing_ward_eruption_dc.vpcf", context )
	PrecacheResource( "particle", "particles/acorn_persistent.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_windrunner/windrunner_shackleshot_rope.vpcf", context )
	PrecacheResource( "model", "maps/ti10_assets/trees/ti10_goldenbirch001.vmdl", context )
end

function pathfinder_bushwhack:Spawn()
	if not IsServer() then return end
	Timers( 1, function ( )		
		if self:GetCaster():HasAbility("pathfinder_bushwhack_multi_attack") and not self:GetCaster():HasModifier("modifier_pathfinder_bushwhack_multi_attack") then			
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pathfinder_bushwhack_multi_attack", {})			
			return 15
		end
		return 1.5
	end)

	Timers( 1, function ( )		
		if self:GetCaster():HasAbility("pathfinder_bushwhack_ground") then			
			print('refreshing intrinsic')			
			self:RefreshIntrinsicModifier()
			return nil
		end
		return 1.5
	end)
end

function pathfinder_bushwhack:GetIntrinsicModifierName()
	if self:GetCaster():HasAbility("pathfinder_bushwhack_ground") then
		return "modifier_generic_4_charges"
	end
end

--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function pathfinder_bushwhack:GetAOERadius()
	return self:GetSpecialValueFor( "trap_radius" )
end

--------------------------------------------------------------------------------
-- Ability Start
function pathfinder_bushwhack:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- load data
	local projectile_name = "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack.vpcf"
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )

	-- calculate delay
	local delay = (point-caster:GetOrigin()):Length2D()/projectile_speed

	local added_delay = 0
	if self:GetCaster():HasAbility("pathfinder_bushwhack_ground") then
		added_delay = self:GetCaster():FindAbilityByName("pathfinder_bushwhack_ground"):GetLevelSpecialValueFor("duration",1)

		AddFOWViewer( self:GetCaster():GetTeamNumber(), point, 300, delay + added_delay, false )

		local tree_time = delay + added_delay
		local tree_model = "pathfinder_hoodwink_tree"

		if self:GetCaster():HasAbility("pathfinder_acorn_shot_tree") then
			tree_model = "pathfinder_hoodwink_tree_special"
		end

		local tree = CreateUnitByName(tree_model, point, true, nil, nil, DOTA_TEAM_GOODGUYS)
		tree:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = tree_time})
		tree:AddNewModifier(self:GetCaster(), self, "modifier_pathfinder_temp_tree", {})
		tree:SetForwardVector(RandomVector(2))

		if self:GetCaster():HasAbility("pathfinder_acorn_shot_tree") then
			local thinker = CreateModifierThinker(
				self:GetCaster(), -- player source
				self, -- ability source
				"modifier_pathfinder_acorn_shot_thinker", -- modifier name
				{duration =  tree_time }, -- kv
				point,
				self:GetCaster():GetTeamNumber(),
				false
			)
			thinker:FindModifierByName("modifier_pathfinder_acorn_shot_thinker").tree = tree
		end		


		local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_tree.vpcf"
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, tree )
		ParticleManager:SetParticleControl( effect_cast, 0, tree:GetOrigin() )
		ParticleManager:SetParticleControl( effect_cast, 1, Vector( 1, 1, 1 ) )
		ParticleManager:ReleaseParticleIndex( effect_cast )

		local units = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			point,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			70,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)
		if #units > 0 then
			for _,unit in pairs(units) do
				FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
			end
		end
		
		particle_cast = "particles/econ/items/juggernaut/bladekeeper_healing_ward/juggernaut_healing_ward_eruption_dc.vpcf"
		effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( effect_cast, 0, tree:GetOrigin()+Vector(1,0,0) )
		ParticleManager:ReleaseParticleIndex( effect_cast )
	end
	-- create thinker at location
	local target = CreateModifierThinker(
		caster, -- player source
		self, -- ability source
		"modifier_pathfinder_bushwhack_thinker", -- modifier name
		{
			duration = delay + added_delay,
			wait_time = delay,
			tree_time = added_delay,
		}, -- kv
		point,
		caster:GetTeamNumber(),
		false
	)
end

---------
--------
---------

modifier_pathfinder_bushwhack_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_bushwhack_debuff:IsHidden()
	return false
end

function modifier_pathfinder_bushwhack_debuff:IsDebuff()
	return true
end

function modifier_pathfinder_bushwhack_debuff:IsStunDebuff()
	return true
end

function modifier_pathfinder_bushwhack_debuff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_pathfinder_bushwhack_debuff:OnCreated( kv )
	self.parent = self:GetParent()

	-- references
	self.height = self:GetAbility():GetSpecialValueFor( "visual_height" )
	self.rate = self:GetAbility():GetSpecialValueFor( "animation_rate" )

	self.distance = 150
	self.speed = 900
	self.interval = 0.1

	if not IsServer() then return end
	self.tree = EntIndexToHScript( kv.tree )
	self.tree_origin = self.tree:GetOrigin()

	-- apply motion controller
	if not self:ApplyHorizontalMotionController() then
		-- self:Destroy()
		return
	end

	-- tree cut down thinker
	self:StartIntervalThink( self.interval )

	-- Play Effects
	self:PlayEffects1()
end

function modifier_pathfinder_bushwhack_debuff:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_pathfinder_bushwhack_debuff:OnRemoved()
end

function modifier_pathfinder_bushwhack_debuff:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController( self )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_pathfinder_bushwhack_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_FIXED_DAY_VISION,
		MODIFIER_PROPERTY_FIXED_NIGHT_VISION,

		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
	}

	return funcs
end

function modifier_pathfinder_bushwhack_debuff:GetFixedDayVision()
	return 0
end

function modifier_pathfinder_bushwhack_debuff:GetFixedNightVision()
	return 0
end

function modifier_pathfinder_bushwhack_debuff:GetOverrideAnimation()
	if not self:GetParent():HasModifier("modifier_absolute_no_cc") then
		return ACT_DOTA_FLAIL
	end
end

function modifier_pathfinder_bushwhack_debuff:GetOverrideAnimationRate()
	return self.rate
end

function modifier_pathfinder_bushwhack_debuff:GetVisualZDelta()
	return self.height
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_pathfinder_bushwhack_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_pathfinder_bushwhack_debuff:OnIntervalThink()
	-- check if the tree is still standing
	
end

--------------------------------------------------------------------------------
-- Motion Effects
function modifier_pathfinder_bushwhack_debuff:UpdateHorizontalMotion( me, dt )
	-- get data
	local origin = me:GetOrigin()
	local dir = self.tree_origin-origin
	local dist = dir:Length2D()
	dir.z = 0
	dir = dir:Normalized()

	-- check if close
	if dist<self.distance then
		self:GetParent():RemoveHorizontalMotionController( self )

		self:PlayEffects2( dir )

		return
	end

	-- move closer to tree
	local target = dir * self.speed*dt
	me:SetOrigin( origin + target )
end

function modifier_pathfinder_bushwhack_debuff:OnHorizontalMotionInterrupted()
	self:GetParent():RemoveHorizontalMotionController( self )
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_pathfinder_bushwhack_debuff:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack_target.vpcf"
	local sound_cast = "Hero_Hoodwink.Bushwhack.Target"

	-- Get Data

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
    ParticleManager:SetParticleControl( effect_cast, 15, self.tree_origin )
    ParticleManager:SetParticleControlEnt( effect_cast, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	EmitSoundOn( sound_cast, self.parent )
end

function modifier_pathfinder_bushwhack_debuff:PlayEffects2( dir )
	-- Get Resources
	local particle_cast = "particles/econ/items/juggernaut/bladekeeper_healing_ward/juggernaut_healing_ward_eruption_dc.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, self.parent:GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

------
------
------

modifier_pathfinder_bushwhack_thinker = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_bushwhack_thinker:IsHidden()
	return false
end

function modifier_pathfinder_bushwhack_thinker:IsDebuff()
	return false
end

function modifier_pathfinder_bushwhack_thinker:IsStunDebuff()
	return false
end

function modifier_pathfinder_bushwhack_thinker:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_pathfinder_bushwhack_thinker:OnCreated( kv )
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()

	-- references
	self.damage = self:GetAbility():GetSpecialValueFor( "total_damage" )
	self.duration = self:GetAbility():GetSpecialValueFor( "debuff_duration" )
	self.speed = self:GetAbility():GetSpecialValueFor( "projectile_speed" )
	self.radius = self:GetAbility():GetSpecialValueFor( "trap_radius" )

	if not IsServer() then return end

	self.location = self:GetParent():GetOrigin()
	self.abilityDamageType = self:GetAbility():GetAbilityDamageType()

	if self.caster:HasAbility("pathfinder_bushwhack_ground") then
		self.delay = kv.wait_time
		local delay = self.delay

		local loc = self.location
		local mod = self
		local radius = self.radius		

		Timers(delay - 0.1, function()
			StopSoundOn("Hero_Hoodwink.Bushwhack.Cast", mod.caster)
			-- local trees = GridNav:GetAllTreesAroundPoint( loc, radius, false )
			-- if #trees<1 then
			

			loc = loc + Vector(0,0,20)
			local point = loc + Vector(radius, 0, 0)
			local qangle = QAngle(0,36,0)

			for i=1,10 do

				local acorn = ParticleManager:CreateParticle( "particles/acorn_persistent.vpcf", PATTACH_WORLDORIGIN, self:GetParent() )
				ParticleManager:SetParticleControl(acorn, 10, point)
				mod:AddParticle(
					acorn,
					false, -- bDestroyImmediately
					false, -- bStatusEffect
					-1, -- iPriority
					false, -- bHeroEffect
					false -- bOverheadEffect
				)

				local rope = ParticleManager:CreateParticle( "particles/units/heroes/hero_windrunner/windrunner_shackleshot_rope.vpcf", PATTACH_WORLDORIGIN, self:GetParent() )
				ParticleManager:SetParticleControl(rope, 0, point)

				point = RotatePosition(loc, qangle, point)

				ParticleManager:SetParticleControl(rope, 1, point)
				mod:AddParticle(
					rope,
					false, -- bDestroyImmediately
					false, -- bStatusEffect
					-1, -- iPriority
					false, -- bHeroEffect
					false -- bOverheadEffect
				)


			end

			local enemies = FindUnitsInRadius(
				self.caster:GetTeamNumber(),	-- int, your team number
				loc,	-- point, center point
				nil,	-- handle, cacheUnit. (not known)
				radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
				DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
				0,	-- int, flag filter
				0,	-- int, order filter
				false	-- bool, can grow cache
			)
			if #enemies > 0 then
				mod:Destroy()
			else
				mod:StartIntervalThink(delay)
			end
		end)
	end

	self:PlayEffects1()
end

function modifier_pathfinder_bushwhack_thinker:OnRefresh( kv )

end

function modifier_pathfinder_bushwhack_thinker:OnRemoved()
end

function modifier_pathfinder_bushwhack_thinker:OnDestroy()
	if not IsServer() then return end

	-- vision
	AddFOWViewer( self.caster:GetTeamNumber(), self.location, self.radius, self.duration, false )

	-- find enemies
	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(),	-- int, your team number
		self.location,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	if #enemies<1 then

		local vo = {
			"hoodwink_hoodwink_net_miss_01",
			"hoodwink_hoodwink_net_miss_02",
			"hoodwink_hoodwink_net_miss_03",
			"hoodwink_hoodwink_net_miss_04",
			"hoodwink_hoodwink_net_miss_05",
			"hoodwink_hoodwink_net_miss_06",
			"hoodwink_hoodwink_net_miss_07_02",

			"hoodwink_hoodwink_net_miss_08",
			"hoodwink_hoodwink_net_miss_09",
			"hoodwink_hoodwink_net_miss_10",

		}
		self:GetCaster():EmitSoundParams(vo[RandomInt(1, #vo)], 0, 3, 0)

		self:PlayEffects2( false )
		return
	end

	-- find trees
	local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
		self.location,
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_OTHER,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false)	
	for ind,unit in pairs(units) do
		if unit:GetUnitName() ~= "pathfinder_hoodwink_tree" or unit:GetUnitName() ~= "pathfinder_hoodwink_tree_special" then
			table.remove(unit, ind)
		end
	end
	local trees = GridNav:GetAllTreesAroundPoint( self.location, self.radius, false )	
	if #trees<1 and #units < 1 then

		local vo = {
			"hoodwink_hoodwink_net_miss_01",
			"hoodwink_hoodwink_net_miss_02",
			"hoodwink_hoodwink_net_miss_03",
			"hoodwink_hoodwink_net_miss_04",
			"hoodwink_hoodwink_net_miss_05",
			"hoodwink_hoodwink_net_miss_06",
			"hoodwink_hoodwink_net_miss_07_02",

			"hoodwink_hoodwink_net_miss_08",
			"hoodwink_hoodwink_net_miss_09",
			"hoodwink_hoodwink_net_miss_10",

		}
		self:GetCaster():EmitSoundParams(vo[RandomInt(1, #vo)], 0, 3, 0)

		self:PlayEffects2( false )
		return
	end

	-- precache damage
	local damageTable = {
		-- victim = target,
		attacker = self.caster,
		damage = self.damage,
		damage_type = self.abilityDamageType,
		ability = self.ability, --Optional.
		damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
	}

	-- match enemies with closest trees
	for _,enemy in pairs(enemies) do

		-- damage
		damageTable.victim = enemy
		ApplyDamage( damageTable )

		-- get closest tree
		local origin = enemy:GetOrigin()
		local mytree = trees[1]
		local mytreedist = 9000

		if mytree then
			mytreedist = (trees[1]:GetOrigin()-origin):Length2D()
			for _,tree in pairs(trees) do
				local treedist = (tree:GetOrigin()-origin):Length2D()
				if treedist<mytreedist then
					mytree = tree
					mytreedist = treedist
				end
			end
		end

		for _,unit in pairs(units) do
			local treedist = (unit:GetOrigin()-origin):Length2D()
			if treedist<mytreedist then
				mytree = unit
				mytreedist = treedist
			end
		end

		enemy:AddNewModifier(
			self.caster, -- player source
			self.ability, -- ability source
			"modifier_pathfinder_bushwhack_debuff", -- modifier name
			{
				duration = self.duration,
				tree = mytree:entindex(),
			} -- kv
		)

	end

	-- play effects
	self:PlayEffects2( true )

	local vo = {
			"hoodwink_hoodwink_net_hit_01",
			"hoodwink_hoodwink_net_hit_02",
			"hoodwink_hoodwink_net_hit_03",
			"hoodwink_hoodwink_net_hit_04",
			"hoodwink_hoodwink_net_hit_05",
			"hoodwink_hoodwink_net_hit_06",
			"hoodwink_hoodwink_net_hit_07",
			"hoodwink_hoodwink_net_hit_08",
			"hoodwink_hoodwink_net_hit_09",
			"hoodwink_hoodwink_net_hit_10",
			"hoodwink_hoodwink_net_hit_11",
			"hoodwink_hoodwink_net_hit_12",

			"hoodwink_hoodwink_net_hit_12_02",
			"hoodwink_hoodwink_net_hit_12_03",

			"hoodwink_hoodwink_net_hit_13",
			"hoodwink_hoodwink_net_hit_14",
			"hoodwink_hoodwink_net_hit_15",
			"hoodwink_hoodwink_net_hit_16",
		}
		self:GetCaster():EmitSoundParams(vo[RandomInt(1, #vo)], 0, 3, 0)

	UTIL_Remove( self:GetParent() )
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_pathfinder_bushwhack_thinker:OnIntervalThink()
	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(),	-- int, your team number
		self.location,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	if #enemies > 0 then
		self:StartIntervalThink(-1)
		local mod = self
		Timers(1, function()
			mod:Destroy()
		end)
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_pathfinder_bushwhack_thinker:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack_projectile.vpcf"
	local sound_cast = "Hero_Hoodwink.Bushwhack.Cast"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self.caster:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( self.speed, 0, 0 ) )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	if IsServer() and self:GetCaster():HasAbility("pathfinder_bushwhack_ground") then
		local delay = self.delay
		Timers(delay, function()
			if effect_cast then
				ParticleManager:DestroyParticle(effect_cast, false)
				ParticleManager:ReleaseParticleIndex(effect_cast)
			end
		end)
	end

	-- Create Sound
	EmitSoundOn( sound_cast, self.caster )
end

function modifier_pathfinder_bushwhack_thinker:PlayEffects2( success )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack_fail.vpcf"
	local sound_cast = "Hero_Hoodwink.Bushwhack.Impact"
	if success then
		particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack.vpcf"
	end

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, self.location )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	if success then return end

	-- Create Sound
	EmitSoundOnLocationWithCaster( self.location, sound_cast, self.caster )
end


modifier_pathfinder_bushwhack_multi_attack = class({
    IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,
	RemoveOnDeath			= function(self) return false end,
})
LinkLuaModifier( "modifier_pathfinder_bushwhack_multi_attack_preattack", "pathfinder/furry/pathfinder_hoodwink", LUA_MODIFIER_MOTION_HORIZONTAL )

function modifier_pathfinder_bushwhack_multi_attack:DeclareFunctions()
	if IsServer() and self:GetCaster():HasAbility("pathfinder_bushwhack_multi_attack") then
		return {
			MODIFIER_EVENT_ON_ATTACK,
		}
	end
end

function modifier_pathfinder_bushwhack_multi_attack:OnAttack(params)
	if not self:GetCaster():HasAbility("pathfinder_bushwhack_multi_attack") or params.no_attack_cooldown or params.attacker ~= self:GetParent() or not params.target or params.target:IsBuilding() then
		return
	else
		local enemies = FindUnitsInRadius(
           	self:GetParent():GetTeamNumber(),	-- int, your team number
            params.target:GetOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            2000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_NO_INVIS,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
		)
		if params.target:HasModifier("modifier_pathfinder_bushwhack_debuff") then
			params.target:FindModifierByName("modifier_pathfinder_bushwhack_debuff"):SetDuration(params.target:FindModifierByName("modifier_pathfinder_bushwhack_debuff"):GetDuration(), true)
		end
		for _,enemy in pairs(enemies) do			
			if enemy:HasModifier("modifier_pathfinder_bushwhack_debuff") and enemy ~= params.target then				
				enemy:FindModifierByName("modifier_pathfinder_bushwhack_debuff"):SetDuration(enemy:FindModifierByName("modifier_pathfinder_bushwhack_debuff"):GetDuration(), true)
				self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_pathfinder_bushwhack_multi_attack_preattack", {})
				self:GetParent():PerformAttack(enemy, false, true, true, true, true, false, false)				
				self:GetParent():RemoveModifierByName("modifier_pathfinder_bushwhack_multi_attack_preattack")
			end
		end
	end

end

modifier_pathfinder_bushwhack_multi_attack_preattack = class({
    IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,
})

function modifier_pathfinder_bushwhack_multi_attack_preattack:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
  }

  return funcs
end

function modifier_pathfinder_bushwhack_multi_attack_preattack:GetModifierDamageOutgoing_Percentage()	
    return self:GetCaster():FindAbilityByName("pathfinder_bushwhack_multi_attack"):GetLevelSpecialValueFor("dmg_percent", 1) - 100
end


--------------
--------------

modifier_pathfinder_temp_tree = class({
    IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,
})

function modifier_pathfinder_temp_tree:CheckState()
	if not IsServer() then return end
	local state = {
		
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true,
	}

	return state
end

