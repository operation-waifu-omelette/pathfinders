  
modifier_pathfinder_healing_ward_earthshock = class({})
LinkLuaModifier( "modifier_pathfinder_healing_ward_root", "pathfinder/modifier_pathfinder_healing_ward_root", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_healing_ward_earthshock:IsHidden()
	return true
end

function modifier_pathfinder_healing_ward_earthshock:IsDebuff()
	return false
end

function modifier_pathfinder_healing_ward_earthshock:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations

function modifier_pathfinder_healing_ward_earthshock:PlayEffects()

	require("libraries.timers")
	if not self:GetCaster() then return nil end

	local isDone = 0
	-- if self:GetCaster() then
	-- 	if self:GetCaster():GetOwner() then
	-- 		Timers:CreateTimer( self:GetCaster():GetOwner():FindAbilityByName("pathfinder_juggernaut_summon_healing_ward"):GetSpecialValueFor("duration"), function()
	-- 			isDone = 1
	-- 			return nil
	-- 		end
	-- 		)
	-- 	end
	-- end
	if not IsServer() then return nil end

	
		
	Timers:CreateTimer( function()
		-- do your stuffs
		--vpk:C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota\pak01.vpk:particles\econ\items\ursa\ursa_ti10\ursa_ti10_earthshock.vpcf_c
		if isDone == 1 then
			if earthshock_effect then
				ParticleManager:ReleaseParticleIndex(earthshock_effect)
			end
			return nil
		end

		if IsServer() and self then
			local earthshock_pfx = "particles/econ/items/ursa/ursa_ti10/ursa_ti10_earthshock_rings.vpcf"
			local earthshock_effect = ParticleManager:CreateParticle( earthshock_pfx, PATTACH_CUSTOMORIGIN, self:GetAbility():GetCaster() )
			ParticleManager:SetParticleControl(earthshock_effect, 0, self:GetCaster():GetAbsOrigin())

			local healing_radius = self:GetAbility():GetCaster():GetOwner():FindAbilityByName("pathfinder_juggernaut_summon_healing_ward"):GetLevelSpecialValueFor("radius", self:GetAbility():GetCaster():GetOwner():FindAbilityByName("pathfinder_juggernaut_summon_healing_ward"):GetLevel() - 1)

			ParticleManager:SetParticleControl( earthshock_effect, 1, Vector( 0, healing_radius / 2, 0 ) )

		

			local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			self:GetCaster():GetAbsOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			healing_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)    

			-- Do for each affected enemies
			for _,enemy in pairs(enemies) do
				-- Add slow modifier
				enemy:AddNewModifier(
					self:GetCaster(),
					self,
					"modifier_pathfinder_healing_ward_root",
					{ duration = self:GetAbility():GetLevelSpecialValueFor("root_duration", self:GetAbility():GetLevel() - 1) }
				)
			end
		end

        return self:GetAbility():GetLevelSpecialValueFor("root_interval", self:GetAbility():GetLevel() - 1)
    end
	)

end

function modifier_pathfinder_healing_ward_earthshock:OnCreated( kv )
	-- PlayEffects
	self:PlayEffects()	
end