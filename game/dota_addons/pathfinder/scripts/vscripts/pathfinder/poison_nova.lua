--[[Author: Pizzalol
	Date: 30.09.2015.
	Deals non lethal magic damage to the target]]

	require("libraries.has_shard")
	require("pathfinder.plague_ward")

function PoisonNova( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)

	if HasShard(caster, "pathfinder_special_venomancer_ward_nova") then
		plague_ward_ability = caster:FindAbilityByName("venomancer_plague_ward_datadriven")
		plague_ward_level = plague_ward_ability:GetLevel()
		--local leveled_ward = "plague_ward_" .. plague_ward_ability:GetLevel() .. "_datadriven"
		local keys = {}
		keys.caster = caster
		keys.Duration = plague_ward_ability:GetLevelSpecialValueFor("duration", plague_ward_level - 1)
		keys.ability = plague_ward_ability
		keys.target_points = {target:GetAbsOrigin()}
		if RandomInt(0, 100) < caster:FindAbilityByName("pathfinder_special_venomancer_ward_nova"):GetSpecialValueFor("spawn_chance") and plague_ward_level >= 1 then
			venomancer_plague_ward_datadriven_on_spell_start(keys)
		end
	end

	local damage_table = {}
	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.ability = ability
	damage_table.damage = damage
	damage_table.damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL

	ApplyDamage(damage_table)
end