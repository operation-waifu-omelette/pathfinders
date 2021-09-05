---------------------------------
-- Swashbuckle On Attack --
---------------------------------

LinkLuaModifier("modifier_pangolier_swashbuckle_on_attack", "pathfinder/pangolier/pangolier_swashbuckle_on_attack_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_pangolier_swashbuckle_lua", "pathfinder/pangolier/modifier_pangolier_swashbuckle_lua", LUA_MODIFIER_MOTION_NONE )

pangolier_swashbuckle_on_attack							= class({})
modifier_pangolier_swashbuckle_on_attack					= class({})

function pangolier_swashbuckle_on_attack:GetIntrinsicModifierName()
	return "modifier_pangolier_swashbuckle_on_attack"
end

-------------------------
-- Swashbuckle on attack modifier --
-------------------------

function modifier_pangolier_swashbuckle_on_attack:IsHidden() return true end

function modifier_pangolier_swashbuckle_on_attack:DeclareFunctions()
	local funcs = {MODIFIER_EVENT_ON_ATTACK_LANDED}

	return funcs
end

function modifier_pangolier_swashbuckle_on_attack:OnAttackLanded(keys)
	if not IsServer() then return end

	-- A bunch of conditionals that need to be passed to continue
	if keys.attacker == self:GetParent() and not self:GetParent():IsIllusion() and not self:GetParent():PassivesDisabled() and not keys.target:IsBuilding() then
		-- Roll!
        new_roller = CreateUnitByName("npc_dota_creature_pangolier_skeleton_summon", self:GetOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)
			new_roller:AddNewModifier(
				self:GetCaster(), -- player source
				self, -- ability source
				"modifier_pangolier_gyroshell", -- modifier name
				{ duration = 3 } -- kv
			)
		if RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("proc_chance"),DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, self:GetCaster()) then
            print("swashbuckle!")
            local direction = self:GetCaster():GetForwardVector()
            print(direction.x,direction.y)
            self:GetCaster():AddNewModifier(
            self:GetCaster(), 
			self,
			"modifier_pangolier_swashbuckle_lua", -- modifier name
			{
				dir_x = direction.x,
				dir_y = direction.y,
				duration = 3, -- max duration
			} -- kv
		)  		
		end
	end
end