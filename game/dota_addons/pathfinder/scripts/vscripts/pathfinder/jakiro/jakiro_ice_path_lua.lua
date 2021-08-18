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
require("libraries.has_shard")
--------------------------------------------------------------------------------
jakiro_ice_path_lua = class({})
LinkLuaModifier( "modifier_jakiro_ice_path_lua", "pathfinder/jakiro/modifier_jakiro_ice_path_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_jakiro_ice_path_lua_thinker", "pathfinder/jakiro/modifier_jakiro_ice_path_lua_thinker", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function jakiro_ice_path_lua:GetCastRange(vLocation, hTarget)
	return self:GetLevelSpecialValueFor("range", self:GetLevel() - 1)
end

-- Ability Start
function jakiro_ice_path_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- calculate direction
	local dir = point - caster:GetOrigin()
	dir.z = 0
	dir = dir:Normalized()

	local range = self:GetLevelSpecialValueFor( "range", self:GetLevel() - 1 ) + self:GetCaster():GetCastRangeBonus()
	local start_range = self:GetLevelSpecialValueFor("start_range", self:GetLevel() - 1)
	local a = self:GetCaster():GetOrigin() + dir + start_range
	local b = a + dir * range

	-- create thinker
	CreateModifierThinker(
		caster, -- player source
		self, -- ability source
		"modifier_jakiro_ice_path_lua_thinker", -- modifier name
		{
			ax = a.x,
			ay = a.y,
			az = a.z,
			bx = b.x,
			by = b.y, 
			bz = b.z,
		}, -- kv
		caster:GetOrigin(),
		caster:GetTeamNumber(),
		false
	)

	if IsServer() and self:GetCaster():HasAbility("pathfinder_jakiro_ice_path_barrier") then			
		local distance = self:GetLevelSpecialValueFor( "range", self:GetLevel() - 1 )	* 0.7		
		local shard_num = distance / 120 --80 is the hull size of the shard
		local direction = dir

		local gap_width = self:GetCaster():FindAbilityByName("pathfinder_jakiro_ice_path_barrier"):GetLevelSpecialValueFor("gap_width",1)

		local shard_pos = self:GetCaster():GetOrigin() + (direction * gap_width / 2)
		
		local left_angle = QAngle(0,90,0) 
		local right_angle = QAngle(0,-90,0) 

		local shard_pos_left = RotatePosition(self:GetCaster():GetAbsOrigin(), left_angle, shard_pos) + (direction * gap_width)
		local shard_pos_right = RotatePosition(self:GetCaster():GetAbsOrigin(), right_angle, shard_pos)  + (direction * gap_width)


		local shard_pos_list_left = {}				
		local shard_pos_list_right = {}				
		local dur = self:GetLevelSpecialValueFor("duration", self:GetLevel() - 1) + self:GetCaster():FindAbilityByName("pathfinder_jakiro_ice_path_barrier"):GetLevelSpecialValueFor("duration_add",1)

		------
		local front_shard_pos = shard_pos + (direction * 50)
		local front_shard_pos_left = RotatePosition(shard_pos, left_angle, front_shard_pos) + (direction * gap_width / 2)
		local front_shard_pos_right = RotatePosition(shard_pos, right_angle, front_shard_pos) + (direction * gap_width / 2)
		local front_blocker_left = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = front_shard_pos_left})		
		local front_blocker_right = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = front_shard_pos_right})

		local front_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_ice_shards_base.vpcf",PATTACH_WORLDORIGIN,self:GetCaster())
		ParticleManager:SetParticleControl(front_particle,0,Vector(dur ,0,0))
		ParticleManager:SetParticleControl(front_particle,1, front_shard_pos_left)		
		ParticleManager:ReleaseParticleIndex(front_particle)					

		front_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_ice_shards_base.vpcf",PATTACH_WORLDORIGIN,self:GetCaster())
		ParticleManager:SetParticleControl(front_particle,0,Vector(dur + 0.4 ,0,0))
		ParticleManager:SetParticleControl(front_particle,1, front_shard_pos_right)
		ParticleManager:ReleaseParticleIndex(front_particle)	

		front_blocker_left:EmitSoundParams("Hero_Tusk.IceShards", 0, 0.3,0)

		Timers:CreateTimer(dur, function()
			front_blocker_left:EmitSoundParams("Hero_Tusk.TagTeam.Layer", 0,1,0)
			UTIL_Remove(front_blocker_left)    
			UTIL_Remove(front_blocker_right)    				
		end)
		------

		if shard_num < 3 then return end
		for i = 2,shard_num do	
			shard_pos_list_left[i] = shard_pos_left
			shard_pos_list_right[i] = shard_pos_right

			Timers:CreateTimer(0.1 * i, function()					
				local blocker_left = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = shard_pos_list_left[i]})		
				local blocker_right = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = shard_pos_list_right[i]})		
				
				blocker_left:EmitSoundParams("Hero_Tusk.IceShards", 0, 0.3,0)

				Timers:CreateTimer(dur, function()
					blocker_left:EmitSoundParams("Hero_Tusk.TagTeam.Layer", 0,1,0)
					UTIL_Remove(blocker_left)    
					UTIL_Remove(blocker_right)    				
				end)

				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_ice_shards_base.vpcf",PATTACH_WORLDORIGIN,self:GetCaster())
				ParticleManager:SetParticleControl(particle,0,Vector(dur ,0,0))
				ParticleManager:SetParticleControl(particle,1, shard_pos_list_left[i])		
				ParticleManager:ReleaseParticleIndex(particle)					

				particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_ice_shards_base.vpcf",PATTACH_WORLDORIGIN,self:GetCaster())
				ParticleManager:SetParticleControl(particle,0,Vector(dur + 0.4 ,0,0))
				ParticleManager:SetParticleControl(particle,1, shard_pos_list_right[i])
				ParticleManager:ReleaseParticleIndex(particle)					
			end)			
			shard_pos_left = shard_pos_left + (direction * 120)						
			shard_pos_right = shard_pos_right + (direction * 120)						
		end					
	end

end

function jakiro_ice_path_lua:IceFromAToB(a,b)
	-- unit identifier
	local caster = self:GetCaster()	


	-- create thinker
	CreateModifierThinker(
		caster, -- player source
		self, -- ability source
		"modifier_jakiro_ice_path_lua_thinker", -- modifier name
		{
			ax = a.x,
			ay = a.y,
			az = a.z,
			bx = b.x,
			by = b.y,
			bz = b.z,
		}, -- kv
		caster:GetOrigin(),
		caster:GetTeamNumber(),
		false
	)

	if IsServer() and self:GetCaster():HasAbility("pathfinder_jakiro_ice_path_barrier") then			
		local distance = self:GetLevelSpecialValueFor( "range", self:GetLevel() - 1 )	* 0.7	
		local shard_num = distance / 120 --80 is the hull size of the shard

		if shard_num < 3 then return end

		local direction = (b - a):Normalized()
		direction.z = 0

		local gap_width = self:GetCaster():FindAbilityByName("pathfinder_jakiro_ice_path_barrier"):GetLevelSpecialValueFor("gap_width",1)

		local shard_pos = a + (direction * gap_width / 2)
		
		local left_angle = QAngle(0,90,0) 
		local right_angle = QAngle(0,-90,0) 

		local shard_pos_left = RotatePosition(a, left_angle, shard_pos)  + (direction * gap_width)
		local shard_pos_right = RotatePosition(a, right_angle, shard_pos)  + (direction * gap_width)


		local shard_pos_list_left = {}				
		local shard_pos_list_right = {}				
		local dur = self:GetLevelSpecialValueFor("duration", self:GetLevel() - 1) + self:GetCaster():FindAbilityByName("pathfinder_jakiro_ice_path_barrier"):GetLevelSpecialValueFor("duration_add",1)

		------
		local front_shard_pos = shard_pos + (direction * 50)
		local front_shard_pos_left = RotatePosition(shard_pos, left_angle, front_shard_pos) + (direction * gap_width / 2)
		local front_shard_pos_right = RotatePosition(shard_pos, right_angle, front_shard_pos) + (direction * gap_width / 2)
		local front_blocker_left = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = front_shard_pos_left})		
		local front_blocker_right = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = front_shard_pos_right})

		local front_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_ice_shards_base.vpcf",PATTACH_WORLDORIGIN,self:GetCaster())
		ParticleManager:SetParticleControl(front_particle,0,Vector(dur ,0,0))
		ParticleManager:SetParticleControl(front_particle,1, front_shard_pos_left)		
		ParticleManager:ReleaseParticleIndex(front_particle)					

		front_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_ice_shards_base.vpcf",PATTACH_WORLDORIGIN,self:GetCaster())
		ParticleManager:SetParticleControl(front_particle,0,Vector(dur + 0.4 ,0,0))
		ParticleManager:SetParticleControl(front_particle,1, front_shard_pos_right)
		ParticleManager:ReleaseParticleIndex(front_particle)	

		front_blocker_left:EmitSoundParams("Hero_Tusk.IceShards", 0, 0.3,0)

		Timers:CreateTimer(dur, function()
			front_blocker_left:EmitSoundParams("Hero_Tusk.TagTeam.Layer", 0,1,0)
			UTIL_Remove(front_blocker_left)    
			UTIL_Remove(front_blocker_right)    				
		end)
		------

		for i = 1,shard_num do	
			shard_pos_list_left[i] = shard_pos_left
			shard_pos_list_right[i] = shard_pos_right

			Timers:CreateTimer(0.1 * i, function()					
				local blocker_left = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = shard_pos_list_left[i]})		
				local blocker_right = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = shard_pos_list_right[i]})		
				
				blocker_left:EmitSoundParams("Hero_Tusk.IceShards", 0, 0.3,0)

				Timers:CreateTimer(dur, function()
					blocker_left:EmitSoundParams("Hero_Tusk.TagTeam.Layer", 0,1,0)
					UTIL_Remove(blocker_left)    
					UTIL_Remove(blocker_right)    				
				end)

				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_ice_shards_base.vpcf",PATTACH_WORLDORIGIN,self:GetCaster())
				ParticleManager:SetParticleControl(particle,0,Vector(dur ,0,0))
				ParticleManager:SetParticleControl(particle,1, shard_pos_list_left[i])		
				ParticleManager:ReleaseParticleIndex(particle)					

				particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_ice_shards_base.vpcf",PATTACH_WORLDORIGIN,self:GetCaster())
				ParticleManager:SetParticleControl(particle,0,Vector(dur + 0.4 ,0,0))
				ParticleManager:SetParticleControl(particle,1, shard_pos_list_right[i])
				ParticleManager:ReleaseParticleIndex(particle)					
			end)			
			shard_pos_left = shard_pos_left + (direction * 120)						
			shard_pos_right = shard_pos_right + (direction * 120)						
		end					
	end
end