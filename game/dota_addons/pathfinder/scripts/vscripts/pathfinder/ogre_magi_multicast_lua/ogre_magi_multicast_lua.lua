-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
ogre_magi_multicast_lua = class({})
LinkLuaModifier( "modifier_ogre_magi_multicast_lua", "pathfinder/ogre_magi_multicast_lua/modifier_ogre_magi_multicast_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ogre_magi_multicast_lua_proc", "pathfinder/ogre_magi_multicast_lua/modifier_ogre_magi_multicast_lua_proc", LUA_MODIFIER_MOTION_NONE )

require("libraries.timers")
--------------------------------------------------------------------------------
-- Passive Modifier
function ogre_magi_multicast_lua:GetIntrinsicModifierName()
	return "modifier_ogre_magi_multicast_lua"
end

function ogre_magi_multicast_lua:OnSpellStart()
	if not IsServer() or not self:GetCaster():FindAbilityByName("pathfinder_special_om_alive_multicast") then return end

	local heal = self:GetCaster():FindAbilityByName("pathfinder_special_om_alive_multicast"):GetLevelSpecialValueFor("heal",1)
	local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_fireblast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
	EmitSoundOn( "DOTA_Item.ComboBreaker", self:GetCaster() )

	self:GetCaster():Heal(heal, self)

	local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			self:GetCaster():GetAbsOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			250,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)
	
	for _,enemy in pairs(enemies) do	
		enemy:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = 0.2 * (1 - enemy:GetStatusResistance())})

		local knockback =
			{
				knockback_duration = 0.2,
				duration = 0.2,
				knockback_distance = 100,
				knockback_height = 100,
				center_x = self:GetCaster():GetAbsOrigin().x,
				center_y = self:GetCaster():GetAbsOrigin().y,
				center_z = self:GetCaster():GetAbsOrigin().z,
			}
		enemy:RemoveModifierByName("modifier_knockback")
		enemy:AddNewModifier(self:GetCaster(), self, "modifier_knockback", knockback)		
		Timers(0.35, function()
			FindClearSpaceForUnit(enemy, enemy:GetAbsOrigin(), false)
		end)
	end
end


--------------------------------------------------------------------------------
