
modifier_dark_willow_terror_shot_lua = class({})

function modifier_dark_willow_terror_shot_lua:IsHidden()	
    return true 
end

function modifier_dark_willow_terror_shot_lua:DeclareFunctions()
	local funcs = {MODIFIER_EVENT_ON_ATTACK_LANDED}
	return funcs
end

function modifier_dark_willow_terror_shot_lua:OnAttackLanded(keys)
	if not IsServer() then return end

	local ability = self:GetAbility()
	local parent = self:GetParent()
	local caster = self:GetCaster()

    local skeleton_spawn = false
    local skeleton_spawn = self:GetCaster():FindAbilityByName("dark_willow_terrorize_lua_skeleton")

    -- check if crazy
	local crazy = false
	if self:GetCaster():HasAbility("dark_willow_terrorize_lua_crazy") then
		crazy = true
	end

	if keys.attacker == parent and not parent:IsIllusion() and not parent:PassivesDisabled() and not keys.target:IsMagicImmune() and not keys.target:IsBuilding() then

		if RollPseudoRandomPercentage(ability:GetSpecialValueFor("chance_pct"),DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, caster) then

			:AddNewModifier(parent, ability, "modifier_pangolier_lucky_shot_lua_disarm", {duration = ability:GetSpecialValueFor("duration") * (1 - keys.target:GetStatusResistance())})	
			keys.target:EmitSound("Hero_DarkWillow.WispStrike.Cast")

            keys.target:AddNewModifier(
                self:GetCaster(), -- player source
                self, -- ability source
                "modifier_dark_willow_terrorize_lua", -- modifier name
                { 
                    duration = self:GetCaster():FindAbilityByName("dark_willow_terrorize_lua_skeleton"),
                    crazy = crazy,
                    teamnumber = keys.target:GetTeamNumber(),
                    angle = 0,
                } -- kv
            )

            if skeleton_spawn then

            end


		end
	end
end
