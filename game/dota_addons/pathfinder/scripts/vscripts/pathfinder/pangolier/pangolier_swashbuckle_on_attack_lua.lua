--------------------------------------------------------------------------------------------------------------------------------------------------------

LinkLuaModifier("modifier_pangolier_swashbuckle_on_attack", "pathfinder/pangolier/pangolier_swashbuckle_on_attack_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_pangolier_swashbuckle_lua", "pathfinder/pangolier/modifier_pangolier_swashbuckle_lua", LUA_MODIFIER_MOTION_NONE )

pangolier_swashbuckle_on_attack							= class({})
modifier_pangolier_swashbuckle_on_attack					= class({})

--------------------------------------------------------------------------------------------------------------------------------------------------------

--[[---------------------------------------------------------------------
	PANGOLIER SWASHBUCKLE ON ATTACK
]]------------------------------------------------------------------------


function pangolier_swashbuckle_on_attack:GetIntrinsicModifierName()
	return "modifier_pangolier_swashbuckle_on_attack"
end

function modifier_pangolier_swashbuckle_on_attack:IsHidden() return true end

function modifier_pangolier_swashbuckle_on_attack:DeclareFunctions()
	local funcs = {MODIFIER_EVENT_ON_ATTACK_LANDED}
	return funcs
end

function modifier_pangolier_swashbuckle_on_attack:OnAttackLanded(keys)
	if not IsServer() then return end
	local caster = self:GetCaster()
	if caster:FindAbilityByName("pangolier_swashbuckle_lua"):IsTrained()
		
		if keys.attacker == self:GetParent() and not self:GetParent():IsIllusion() and not self:GetParent():PassivesDisabled() and not keys.target:IsBuilding() then
		
			if RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("proc_chance"),DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, caster) then
				local direction = caster:GetForwardVector()
				if not caster:HasModifier(modifier_pangolier_swashbuckle_lua)(
					caster:AddNewModifier(
						caster, 
						self,
						"modifier_pangolier_swashbuckle_lua",
						{
							dir_x = direction.x,
							dir_y = direction.y,
							duration = 3, 
							from_crash = false,
						}			
					) 
				end 		
			end
		end
	end
end