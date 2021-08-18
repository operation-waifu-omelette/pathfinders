
pathfinder_juggernaut_summon_healing_ward = class({})
LinkLuaModifier("modifier_pathfinder_healing_ward_passive", "pathfinder/modifier_pathfinder_healing_ward_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_burning_aura", "pathfinder/modifier_burning_aura", LUA_MODIFIER_MOTION_NONE)

require("libraries.has_shard")

function pathfinder_juggernaut_summon_healing_ward:Precache( context )	
	PrecacheResource( "particle", "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack_latch_edge.vpcf", context )	
end


function pathfinder_juggernaut_summon_healing_ward:OnSpellStart()
	local caster = self:GetCaster()
	local targetPoint = self:GetCursorPosition()

	-- Play cast sound
	caster:EmitSound("Hero_Juggernaut.HealingWard.Cast")

	--local ward_name = "pathfinder_juggernaut_healing_ward"
	local ward_name = "npc_dota_juggernaut_healing_ward"
	if HasShard(caster, "pathfinder_special_juggernaut_healing_ward_creep") then
		ward_name = "pathfinder_aggressive_healing_ward"
	end	

	local healing_ward 
	if IsServer() then
		healing_ward = CreateUnitByName(ward_name, targetPoint, true, caster, caster, caster:GetTeamNumber())
		healing_ward:SetOwner(caster)	
		healing_ward:AddAbility("pathfinder_healing_ward_passive")
	end

	local ward_duration = self:GetLevelSpecialValueFor("duration", caster:FindAbilityByName("pathfinder_juggernaut_summon_healing_ward"):GetLevel() - 1)

	caster_dmg = caster:GetAverageTrueAttackDamage(nil)
	local dmg_pct = 50

	local max_health = self:GetLevelSpecialValueFor("ward_health", (self:GetLevel() - 1))
	if HasShard(caster, "pathfinder_special_juggernaut_healing_ward_creep") then		
		if IsServer() then
			local ward_creep_ability = caster:FindAbilityByName("pathfinder_special_juggernaut_healing_ward_creep")			
			max_health = max_health + (caster:GetMaxHealth() / 100 * ward_creep_ability:GetSpecialValueFor("health_multiplier"))			
			healing_ward:AddAbility("ascension_armor"):SetLevel(self:GetLevel())
			dmg_pct = ward_creep_ability:GetLevelSpecialValueFor("dmg_percent",1)			
			healing_ward:AddAbility("pathfinder_healing_ward_burning_aura"):SetLevel(1)	
		end
	end

	healing_ward:SetBaseDamageMin(caster_dmg / 100 * dmg_pct)
	healing_ward:SetBaseDamageMax(caster_dmg / 100 * dmg_pct)

	--healing_ward:SetMaxHealth(math.floor(max_health))
	healing_ward:SetBaseMaxHealth(math.floor(max_health))
	healing_ward:SetHealth(math.floor(max_health))
	-- Apply the Healing Ward duration modifier
	healing_ward:AddNewModifier(caster, self, "modifier_kill", {duration = ward_duration})	
	--healing_ward:AddNewModifier(healing_ward, self, "modifier_pathfinder_healing_ward_passive", nil)
	
	-- Grant the Healing Ward its abilities
	--healing_ward:AddAbility("pathfinder_healing_ward_passive"):SetLevel( self:GetLevel() )
	
	healing_ward:SetControllableByPlayer(caster:GetPlayerID(), true)	

	caster.active_healing_ward = healing_ward

	if HasShard(caster, "pathfinder_special_juggernaut_healing_ward_earthshock") and IsServer() then		
		healing_ward:AddAbility("pathfinder_healing_ward_earthshock"):SetLevel(1)	
	end

	-- if HasShard(caster, "pathfinder_special_juggernaut_healing_ward_radiance") then		
	-- 	if IsServer() then
	-- 		healing_ward:AddAbility("pathfinder_healing_ward_burning_aura"):SetLevel(1)	
	-- 	end
	-- end	
		
	healing_ward:SetContextThink(DoUniqueString(self:GetName()), function()
		--healing_ward:MoveToNPC(caster)
		if ward_name ~= "pathfinder_aggressive_healing_ward" then
			healing_ward:MoveToNPC(caster)					
		end
		return nil
	end, FrameTime())
	caster.active_healing_ward:SetControllableByPlayer(caster:GetPlayerID(), true)	

	if caster:HasAbility("pathfinder_special_juggernaut_healing_ward_allies") then
		local rad = caster:FindAbilityByName("pathfinder_special_juggernaut_healing_ward_allies"):GetLevelSpecialValueFor("radius",1)
		local dur_pct = caster:FindAbilityByName("pathfinder_special_juggernaut_healing_ward_allies"):GetLevelSpecialValueFor("duration_percent",1)
		self:MakeWardForAllies(rad, dur_pct)
	end
end




function pathfinder_juggernaut_summon_healing_ward:MakeWardForAllies(rad, dur_pct)

	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack_latch_edge.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetAbsOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( rad, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex(effect_cast)

	local caster = self:GetCaster()
	
	local allies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		self:GetCaster():GetAbsOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		rad,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,ally in pairs(allies) do 
		if ally ~= caster then
			local targetPoint = ally:GetAbsOrigin() + RandomVector(60)

			-- Play cast sound
			ally:EmitSound("Hero_Juggernaut.HealingWard.Cast")

			--local ward_name = "pathfinder_juggernaut_healing_ward"
			local ward_name = "npc_dota_juggernaut_healing_ward"
			if HasShard(caster, "pathfinder_special_juggernaut_healing_ward_creep") then
				ward_name = "pathfinder_aggressive_healing_ward"
			end	

			local healing_ward 
			if IsServer() then
				healing_ward = CreateUnitByName(ward_name, targetPoint, true, caster, caster, caster:GetTeamNumber())
				healing_ward:SetOwner(caster)	
				healing_ward:AddAbility("pathfinder_healing_ward_passive")
			end

			local ward_duration = self:GetLevelSpecialValueFor("duration", caster:FindAbilityByName("pathfinder_juggernaut_summon_healing_ward"):GetLevel() - 1) / 100 * dur_pct

			caster_dmg = caster:GetAverageTrueAttackDamage(nil)
			local dmg_pct = 50

			local max_health = self:GetLevelSpecialValueFor("ward_health", (self:GetLevel() - 1))
			if HasShard(caster, "pathfinder_special_juggernaut_healing_ward_creep") then		
				if IsServer() then
					local ward_creep_ability = caster:FindAbilityByName("pathfinder_special_juggernaut_healing_ward_creep")			
					max_health = max_health + (caster:GetMaxHealth() / 100 * ward_creep_ability:GetSpecialValueFor("health_multiplier"))			
					healing_ward:AddAbility("ascension_armor"):SetLevel(self:GetLevel())					
					dmg_pct = ward_creep_ability:GetLevelSpecialValueFor("dmg_percent",1)			
				end
			end

			healing_ward:SetBaseDamageMin(caster_dmg / 100 * dmg_pct)
			healing_ward:SetBaseDamageMax(caster_dmg / 100 * dmg_pct)

			--healing_ward:SetMaxHealth(math.floor(max_health))
			healing_ward:SetBaseMaxHealth(math.floor(max_health))
			healing_ward:SetHealth(math.floor(max_health))
			-- Apply the Healing Ward duration modifier
			healing_ward:AddNewModifier(caster, self, "modifier_kill", {duration = ward_duration})	
			--healing_ward:AddNewModifier(healing_ward, self, "modifier_pathfinder_healing_ward_passive", nil)
			
			-- Grant the Healing Ward its abilities
			--healing_ward:AddAbility("pathfinder_healing_ward_passive"):SetLevel( self:GetLevel() )
			
			healing_ward:SetControllableByPlayer(caster:GetPlayerID(), true)	

			caster.active_healing_ward = healing_ward

			if HasShard(caster, "pathfinder_special_juggernaut_healing_ward_earthshock") and IsServer() then		
				healing_ward:AddAbility("pathfinder_healing_ward_earthshock"):SetLevel(1)	
			end

			if HasShard(caster, "pathfinder_special_juggernaut_healing_ward_radiance") then		
				if IsServer() then
					healing_ward:AddAbility("pathfinder_healing_ward_burning_aura"):SetLevel(1)	
				end
			end	
				
			healing_ward:SetContextThink(DoUniqueString(self:GetName()), function()
				--healing_ward:MoveToNPC(caster)
				if ward_name ~= "pathfinder_aggressive_healing_ward" then
					healing_ward:MoveToNPC(ally)					
				end
				return nil
			end, FrameTime())
			caster.active_healing_ward:SetControllableByPlayer(caster:GetPlayerID(), true)	
		end
	end
end

------------------------------------------------------------------------------











