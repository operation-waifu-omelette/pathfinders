--[[Author: Pizzalol
	Date: 30.09.2015.
	Applies the Venomous Gale modifier with a decaying slow]]
LinkLuaModifier( "modifier_banana_bomb", "pathfinder/modifier_banana_bomb", LUA_MODIFIER_MOTION_NONE )

function VenomousGaleImpact( keys )
	require("libraries.timers")
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local target = keys.target	

	if IsServer() and caster:HasAbility("pathfinder_special_venomancer_gale_bkb") then
		local bkb_duration = 0
		if caster:HasModifier("modifier_black_king_bar_immune") then
			bkb_duration = caster:FindModifierByName("modifier_black_king_bar_immune"):GetDuration()
		else
			caster:AddNewModifier(caster, ability, "modifier_black_king_bar_immune", {})
		end
		local new_duration = bkb_duration + caster:FindAbilityByName("pathfinder_special_venomancer_gale_bkb"):GetSpecialValueFor("duration")
		local max_duration = caster:FindAbilityByName("pathfinder_special_venomancer_gale_bkb"):GetSpecialValueFor("max_duration")
		caster:FindModifierByName("modifier_black_king_bar_immune"):SetDuration(math.min(new_duration,max_duration), true)
	end

	if caster:HasAbility("pathfinder_special_venomancer_banana_bomb") and caster:FindAbilityByName("venomancer_poison_nova_datadriven"):GetLevel() > 0 then
		local banana = CreateUnitByName("pathfinder_banana_bomb", target:GetAbsOrigin(), true, nil, nil, caster:GetTeam())
		banana:AddNewModifier(caster, ability, "modifier_banana_bomb", {})
		banana:FaceTowards(banana:GetAbsOrigin() + RandomVector(10))
	end

	-- Ability variables
	local modifier = keys.modifier
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
	local movement_slow = ability:GetLevelSpecialValueFor("movement_slow", ability_level) * -1 -- Turn it into a positive value

	-- Decay calculation
	local slow_per_second = movement_slow / duration
	local slow_rate = 1 / slow_per_second

	-- Remove the old timer if we are refreshing the duration
	if target.venomous_gale_timer then
		Timers:RemoveTimer(target.venomous_gale_timer)
	end

	-- Apply the Venomous Gale modifier and set the slow amount
	ability:ApplyDataDrivenModifier(caster, target, modifier, {duration = duration})
	target:SetModifierStackCount(modifier, caster, movement_slow)

	-- Create the timer thats responsible for the decaying movement slow
	-- Save it to the target so that we can remove it later
	target.venomous_gale_timer = Timers:CreateTimer(slow_rate, function()
		if IsValidEntity(target) and target:HasModifier(modifier) then
			local current_slow = target:GetModifierStackCount(modifier, caster)
			target:SetModifierStackCount(modifier, caster, current_slow - 1)

			return slow_rate
		else
			return nil
		end
	end)
end