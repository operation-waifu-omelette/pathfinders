pathfinder_juggernaut_blade_fury = class({})
LinkLuaModifier( "modifier_pathfinder_juggernaut_blade_fury", "pathfinder/modifier_pathfinder_juggernaut_blade_fury", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
require("libraries.has_shard")

-- Ability Start
function pathfinder_juggernaut_blade_fury:OnSpellStart()	
	if not IsServer() then return end
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local bDuration = self:GetSpecialValueFor("duration")

	
		caster:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_pathfinder_juggernaut_blade_fury", -- modifier name
			{ duration = bDuration } -- kv
		)
	

	if HasShard(caster, "pathfinder_special_juggernaut_blade_fury_ward") then

		local pct = self:GetCaster():FindAbilityByName("pathfinder_special_juggernaut_blade_fury_ward"):GetLevelSpecialValueFor("duration_pct",1)
		local allyDuration = self:GetSpecialValueFor( "duration" ) / 100 * pct

		local friendlies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), caster:GetAbsOrigin(), nil, caster:FindAbilityByName("pathfinder_special_juggernaut_blade_fury_ward"):GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_OTHER + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_NONE, 0, false )
				for _,friendly in pairs(friendlies) do
					
					if friendly ~= nil and friendly ~= caster and (friendly:IsHero() or friendly:HasAbility("pathfinder_healing_ward_passive")) then
						friendly:AddNewModifier(
						caster, -- player source
						self, -- ability source
						"modifier_pathfinder_juggernaut_blade_fury", -- modifier name
						{ duration = allyDuration } )-- kv
					end
				end
	end
end