require("libraries.timers")

AddStackModifier = function(npc, data)
    data.data = data.data or {}
    data.data.duration = (data.duration or -1)
    if npc:HasModifier(data.modifier) then
        local current_stack = npc:GetModifierStackCount(data.modifier, data.ability)
        if data.updateStack then
            npc:AddNewModifier(data.caster or npc, data.ability, data.modifier, data.data)
        end
        npc:SetModifierStackCount(data.modifier, data.ability, current_stack + (data.count or 1))
        if npc:GetModifierStackCount(data.modifier, data.ability) < 1 then
            npc:RemoveModifierByName(data.modifier)
        end
    else
        npc:AddNewModifier(data.caster or npc, data.ability, data.modifier, data.data)
        npc:SetModifierStackCount(data.modifier, data.ability, (data.count or 1))
    end
    return npc:GetModifierStackCount(data.modifier, data.ability)
end

RandomChoice = function(t) -- Selects a random item from a table
    local keys = {}
    for key, value in pairs(t) do
        keys[#keys + 1] = key -- Store keys in another table
    end
    local index = keys[math.random(1, #keys)]
    return t[index]
end

FindTalentValue = function(unit, talentName)

    if IsServer() and unit:HasAbility(talentName) then
        return unit:FindAbilityByName(talentName):GetSpecialValueFor("value")
    end
    return 0
end

HasShard = function(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then
            return true
        end
    end
    return false
end

FindRadius = function(unit, radius, isEnemy)
    if not IsServer() then
        return
    end
    local search_team = DOTA_UNIT_TARGET_TEAM_ENEMY
    if not isEnemy then
        search_team = DOTA_UNIT_TARGET_TEAM_FRIENDLY
    end
    local units = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, radius, search_team,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    return units
end

FindRadiusPoint = function(caster, point, radius, isEnemy)
    if not IsServer() then
        return
    end
    local search_team = DOTA_UNIT_TARGET_TEAM_ENEMY
    if not isEnemy then
        search_team = DOTA_UNIT_TARGET_TEAM_FRIENDLY
    end
    local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, search_team,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    return units
end

patron_particles =
    {"particles/econ/items/windrunner/windranger_arcana/windranger_arcana_focusfire_v2_ground_butterfly.vpcf",
     "particles/econ/courier/courier_nian/courier_nian_bag_coin.vpcf",
     "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf"}

patron_id = {
    ["76561198047074313"] = {
        name = "first sea patron",
        tier = 4,
        courier = "models/heroes/aghanim/aghanim_model.vmdl",
        courier_effect = "particles/econ/courier/courier_babyroshan_ti9/courier_babyroshan_ti9_ambient.vpcf",
        golden = 8,
        model_scale = -15,
        trail = "particles/econ/courier/courier_trail_blossoms/courier_trail_blossoms.vpcf"
    },
    ["76561198138876421"] = {
        name = "first sea patron's friend",
        tier = 4,
        courier = "models/heroes/aghanim/aghanim_model.vmdl",
        courier_effect = "particles/econ/courier/courier_babyroshan_ti9/courier_babyroshan_ti9_ambient.vpcf",
        golden = 4,
        model_scale = -60,
        trail = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf"
    },
    ["76561198073588617"] = {
        name = "friday",
        tier = 1,
        courier = "models/courier/smeevil_mammoth/smeevil_mammoth.vmdl",
        courier_effect = "",
        golden = 1,
        model_scale = 50,
        trail = "particles/econ/events/ti9/ti9_emblem_effect_ground_flower_base.vpcf"
    },
    ["76561197998173893"] = {
        name = "mastiphal",
        tier = 4,
        courier = "models/heroes/invoker_kid/invoker_kid_trainer_dragon.vmdl",
        courier_effect = "particles/units/heroes/hero_invoker_kid/invoker_kid_forge_spirit_ambient_fire.vpcf",
        golden = 1,
        model_scale = 70,
        trail = "particles/econ/events/ti10/emblem/ti10_emblem_effect_ground_base.vpcf"
    },
    ["76561198034316974"] = {
    	name = "slootoo",
    	tier = 1,
    	courier = "models/heroes/invoker_kid/invoker_kid_trainer_dragon.vmdl",
        courier_effect = "particles/units/heroes/hero_invoker_kid/invoker_kid_forge_spirit_ambient_fire.vpcf",
    	golden = 0,
    	model_scale = 70,
    },
    ["76561198119675831"] = {
        name = "geogorna",
        tier = 4,
        courier = "models/items/lycan/ultimate/blood_moon_hunter_shapeshift_form/blood_moon_hunter_shapeshift_form.vmdl",
        courier_effect = "",
        golden = 5,
        model_scale = -55,
        trail = "particles/econ/courier/courier_trail_int_2012/courier_trail_international_2012.vpcf"
    },
    ["76561198019995637"] = {
        name = "the first canadian donator - angel",
        tier = 3,
        courier = "models/courier/baby_rosh/babyroshan_winter18_flying.vmdl",
        courier_effect = "particles/econ/courier/courier_trail_winter_2012/courier_trail_winter_2012.vpcf",
        golden = 0,
        model_scale = 0,
        trail = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf"
    },
    ["76561197987437476"] = {
        name = "Byte from Discord",
        tier = 1,
        courier = "models/items/courier/amaterasu/amaterasu.vmdl",
        courier_effect = "",
        golden = 0,
        model_scale = 0,
        trail = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf"
    },
    ["76561198102682440"] = {
        name = "Itvara",
        tier = 3,
        courier = "models/items/courier/snaggletooth_red_panda/snaggletooth_red_panda_flying.vmdl",
        courier_effect = "",
        golden = 0,
        model_scale = 0,
        trail = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf"
    },
    ["76561198143351798"] = {
        name = "Zhouliang He",
        tier = 3,
        courier = "models/items/courier/tory_the_sky_guardian/tory_the_sky_guardian.vmdl",
        courier_effect = "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_ambient_v2.vpcf",
        golden = 0,
        model_scale = 0,
        trail = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf"
    },
    ["76561198077340469"] = {
        name = "Kraken - Gareth",
        tier = 3,
        courier = "models/courier/flopjaw/flopjaw.vmdl",
        courier_effect = "particles/econ/courier/courier_flopjaw_gold/courier_flopjaw_ambient_gold.vpcf",
        golden = 0,
        model_scale = 50,
        trail = "particles/econ/items/windrunner/windrunner_cape_cascade/windrunner_windrun_cascade.vpcf"
    },
    ["76561198051037310"] = {
        name = "Hypnoflip",
        tier = 3,
        courier = "models/courier/baby_rosh/babyroshan_winter18.vmdl",
        courier_effect = "particles/econ/courier/courier_flopjaw_gold/courier_flopjaw_ambient_gold.vpcf",
        golden = 0,
        model_scale = 0,
        trail = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf"
    },
    ["76561197994333648"] = {
        name = "Shush",
        tier = 3,
        courier = "models/items/courier/courier_fall20/courier_fall20.vmdl",
        courier_effect = "particles/econ/courier/courier_babyroshan_ti9/courier_babyroshan_ti9_ambient.vpcf",
        golden = 0,
        model_scale = 0,
        trail = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf"
    },
    -- ["76561198043131895"] = {
    -- 	name = "Devil Engineer",
    -- 	tier = 4,
    -- 	courier = "models/courier/baby_rosh/babyroshan_winter18.vmdl",
    -- 	courier_effect = "particles/econ/courier/courier_babyroshan_ti9/courier_babyroshan_ti9_ambient.vpcf",
    -- 	golden = 1,
    -- 	model_scale = 0,
    -- },
    -- ["76561198100146533"] = {
    -- 	name = "Devil Engineer's Friend",
    -- 	tier = 4,
    -- 	courier = "models/items/broodmother/spiderling/the_glacial_creeper_creepling/the_glacial_creeper_creepling.vmdl",
    -- 	courier_effect = "particles/econ/courier/courier_babyroshan_ti9/courier_babyroshan_ti9_ambient.vpcf",
    -- 	golden = 40,
    -- 	model_scale = 0,
    -- },
    ["76561198134133784"] = {
        name = "狗头鱼家的米缸",
        tier = 3,
        courier = "models/courier/baby_rosh/babyroshan_ti10.vmdl",
        courier_effect = "particles/econ/courier/courier_roshan_ti8/courier_roshan_ti8.vpcf",
        golden = 0,
        model_scale = 0,
        trail = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf"
    },
    -- ["76561198944037188"] = {
    -- 	name = "MOON man",
    -- 	tier = 1,
    -- 	courier = "models/heroes/aghanim/aghanim_model.vmdl",
    -- 	courier_effect = "particles/units/heroes/hero_tusk/tusk_frozen_sigil.vpcf",
    -- 	golden = 0,
    -- 	model_scale = -10,
    -- 	trail = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf",
    -- },
    ["76561198208498759"] = {
        name = "iSupporT",
        tier = 4,
        courier = "models/courier/baby_rosh/babyroshan_ti10_dire_flying.vmdl",
        courier_effect = "particles/econ/courier/courier_trail_hw_2012/courier_trail_hw_2012.vpcf",
        golden = 1,
        model_scale = 0,
        trail = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf"
    },
    ["76561198098431449"] = {
        name = "MVS",
        tier = 4,
        courier = "models/courier/skippy_parrot/skippy_parrot_flying_rowboat.vmdl",
        courier_effect = "particles/econ/courier/courier_babyroshan_ti9/courier_babyroshan_ti9_ambient.vpcf",
        golden = 1,
        model_scale = 0,
        trail = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf"
    },
    ["76561198026817948"] = {
        name = "ElladaN",
        tier = 1,
        courier = "models/items/courier/amaterasu/amaterasu.vmdl",
        courier_effect = "particles/econ/courier/courier_babyroshan_ti9/courier_babyroshan_ti9_ambient.vpcf",
        golden = 1,
        model_scale = 0,
        trail = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf"
    },
    ["76561198047079617"] = {
        name = "Throwdo Baggins",
        tier = 1,
        courier = "models/items/courier/itsy/itsy.vmdl",
        courier_effect = "particles/econ/courier/courier_babyroshan_ti9/courier_babyroshan_ti9_ambient.vpcf",
        golden = 0,
        model_scale = 0,
        trail = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf"
    },
    -- ["76561198047082063"] = {
    -- 	name = "Anon A",
    -- 	tier = 1,
    -- 	courier = "models/items/courier/shagbark/shagbark.vmdl",
    -- 	courier_effect = "particles/econ/courier/courier_babyroshan_ti9/courier_babyroshan_ti9_ambient.vpcf",
    -- 	golden = 0,
    -- 	model_scale = 0,
    -- 	trail = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf",
    -- },
    ["76561198082588362"] = {
        name = "zatral.tmf Ezekiel Sampson",
        tier = 1,
        courier = "models/courier/seekling/seekling_flying.vmdl",
        courier_effect = "particles/econ/courier/courier_babyroshan_ti9/courier_babyroshan_ti9_ambient.vpcf",
        golden = 0,
        model_scale = 0,
        trail = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf"
    },
    -- ["76561198061782395"] = {
    -- 	name = "Byob",
    -- 	tier = 2,
    -- 	courier = "models/courier/huntling/huntling_flying.vmdl",
    -- 	courier_effect = "particles/econ/courier/courier_babyroshan_ti9/courier_babyroshan_ti9_ambient.vpcf",
    -- 	golden = 0,
    -- 	model_scale = 0,
    -- 	trail = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf",
    -- },
    -- ["76561198249380460"] = {
    -- 	name = "clife19119",
    -- 	tier = 4,
    -- 	courier = "models/items/courier/nian_courier/nian_courier.vmdl",
    -- 	courier_effect = "particles/econ/courier/courier_nian/courier_nian_bag.vpcf",
    -- 	golden = 1,
    -- 	model_scale = 0,
    -- },
    -- ["76561198081584743"] = {
    -- 	name = "Tesla Pua",
    -- 	tier = 3,
    -- 	courier = "models/heroes/shopkeeper/shopkeeper.vmdl",
    -- 	courier_effect = "particles/econ/courier/courier_trail_int_2012/courier_trail_international_2012.vpcf",
    -- 	golden = 0,
    -- 	model_scale = -20,
    -- },
    -- ["76561198135348255"] = {
    -- 	name = "Massela - AHoraDaEstrela ",
    -- 	tier = 4,
    -- 	courier = "models/courier/baby_rosh/babyroshan_ti10_flying.vmdl",
    -- 	courier_effect = "particles/creatures/greevil/greevil_prison_coin_suckin.vpcf",
    -- 	golden = 6,
    -- 	model_scale = 10,
    -- },
    -- ["76561198879531796"] = {
    -- 	name = "MINYI YU - Yuui ",
    -- 	tier = 3,
    -- 	courier = "models/items/courier/jumo/jumo.vmdl",
    -- 	courier_effect = "particles/econ/courier/courier_trail_blossoms/courier_trail_blossoms.vpcf",
    -- 	golden = 0,
    -- 	model_scale = 10,
    -- 	trail = "particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_arcana_ground_ambient.vpcf",
    -- },
    -- ["76561198372470764"] = {
    -- 	name = "Louis",
    -- 	tier = 4,
    -- 	courier = "models/courier/baby_rosh/babyroshan_ti10_dire_flying.vmdl",
    -- 	courier_effect = "particles/econ/courier/courier_babyroshan_ti10/courier_babyroshan_ti10_ambient.vpcf",
    -- 	golden = 0,
    -- 	model_scale = 20,
    -- },
    -- ["76561198420652718"] = {
    -- 	name = "Louis +1",
    -- 	tier = 4,
    -- 	courier = "models/courier/donkey_trio/mesh/donkey_trio.vmdl",
    -- 	courier_effect = "particles/econ/courier/courier_flopjaw_gold/courier_flopjaw_ambient_gold.vpcf",
    -- 	golden = 0,
    -- 	model_scale = 0,
    -- },
    -- ["76561198166108952"] = {
    -- 	name = "Azshara",
    -- 	tier = 3,
    -- 	courier = "models/items/courier/onibi_lvl_21/onibi_lvl_21.vmdl",
    -- 	courier_effect = "particles/econ/courier/courier_onibi/courier_onibi_black_lvl21_ambient.vpcf",
    -- 	golden = 0,
    -- 	model_scale = 0,
    -- },
    ["76561197988918559"] = {
        name = "Antonio - megact",
        tier = 1,
        courier = "models/items/courier/pangolier_squire/pangolier_squire.vmdl",
        courier_effect = "particles/econ/courier/courier_flopjaw_gold/courier_flopjaw_ambient_gold.vpcf",
        golden = 0,
        model_scale = 0,
        trail = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf"
    },
    ["76561197997190620"] = {
        name = "Lusca",
        tier = 1,
        courier = "models/courier/octopus/octopus.vmdl",
        courier_effect = "particles/econ/courier/courier_flopjaw_gold/courier_flopjaw_ambient_gold.vpcf",
        golden = 0,
        model_scale = 0
    },
    -- ["76561198420652718"] = {
    -- 	name = "Yanghan Lu - 步惊云",									
    -- 	tier = 3,
    -- 	courier = "models/courier/baby_rosh/babyroshan.vmdl",
    -- 	courier_effect = "particles/econ/courier/courier_roshan_darkmoon/courier_roshan_darkmoon.vpcf",
    -- 	golden = 0,
    -- 	model_scale = 20,
    -- },
    ["76561198046996677"] = {
        name = "CaramelTheCalf",
        tier = 4,
        courier = "models/courier/baby_rosh/babyroshan_ti10.vmdl",
        courier_effect = "particles/econ/items/windrunner/windrunner_cape_cascade/windrunner_windrun_cascade.vpcf",
        golden = 1,
        model_scale = 10,
        trail = "particles/econ/items/windrunner/windrunner_cape_cascade/windrunner_windrun_cascade.vpcf"
    },
    ["76561198060713767"] = {
        name = "Ben",
        tier = 3,
        courier = "models/courier/baby_rosh/babyroshan_ti10.vmdl",
        courier_effect = "particles/econ/courier/courier_babyroshan_ti9/courier_babyroshan_ti9_ambient.vpcf",
        golden = 0,
        model_scale = 10,
        trail = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf"
    },
    -- ["76561198124767395"] = {
    --     name = "Kruizer",
    --     tier = 3,
    --     courier = "models/items/courier/mango_the_courier/mango_the_courier.vmdl",
    --     courier_effect = "",
    --     golden = 0,
    --     model_scale = 60,
    --     trail = "particles/econ/events/ti9/ti9_emblem_effect_ground_flower_base.vpcf"
    -- },
    ["76561198156235299"] = {
        name = "Bitcoin Donator, not a patron",
        tier = 4,
        courier = "models/items/broodmother/spiderling/witchs_grasp_spiderling/witchs_grasp_spiderling.vmdl",
        courier_effect = "",
        golden = 1,
        model_scale = -15,
        trail = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf"
    },
    ["76561199091724262"] = {
        name = "Rising yuenlunwong96@gmail.com",
        tier = 3,
        courier = "models/courier/baby_rosh/babyroshan_elemental.vmdl",
        courier_effect = "particles/econ/courier/courier_babyroshan_ti10/courier_babyroshan_ti10_ambient.vpcf",
        golden = 0,
        model_scale = 15,
        trail = "particles/econ/courier/courier_roshan_desert_sands/baby_roshan_desert_sands_ambient.vpcf"
    },
    ["76561198053098358"] = {
        name = "Admiral Bulldog",
        tier = 1,
        courier = "models/items/courier/butch_pudge_dog/butch_pudge_dog.vmdl",
        courier_effect = "0",
        golden = 0,
        model_scale = 20,
        trail = "particles/econ/events/ti9/ti9_emblem_effect_ground_flower_base.vpcf"
    },
    ["76561198043754187"] = {
        name = "Skitter",
        tier = 4,
        courier = "models/items/courier/amaterasu/amaterasu.vmdl",
        courier_effect = "0",
        golden = 1,
        model_scale = 1,
        trail = "particles/econ/items/windrunner/windrunner_cape_cascade/windrunner_windrun_cascade.vpcf"
    },
    -- ["76561198053337786"] = {
    -- 	name = "Z S",
    -- 	tier = 3,
    -- 	courier = "models/items/courier/faceless_rex/faceless_rex.vmdl",
    -- 	courier_effect = "0",
    -- 	golden = 0,
    -- 	model_scale = -15,
    -- 	trail = "particles/econ/courier/courier_trail_03/courier_trail_03.vpcf",
    -- },
    -- ["76561197960966523"] = {
    -- 	name = "T-Reckt",
    -- 	tier = 3,
    -- 	courier = "models/items/courier/faceless_rex/faceless_rex.vmdl",
    -- 	courier_effect = "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_l2_dire.vpcf",
    -- 	golden = 0,
    -- 	model_scale = 15,
    -- 	trail = "particles/econ/courier/courier_trail_int_2012/courier_trail_international_2012.vpcf",
    -- },
    ["76561198007479564"] = {
        name = "Derk - i3anaan",
        tier = 1,
        courier = "models/items/courier/little_fraid_the_courier_of_simons_retribution/little_fraid_the_courier_of_simons_retribution.vmdl",
        courier_effect = "0",
        golden = 0,
        model_scale = 15,
        trail = "particles/econ/events/ti9/ti9_emblem_effect_ground_flower_base.vpcf"
    },
    ["76561198107181525"] = {
        name = "snike",
        tier = 2,
        courier = "models/items/courier/devourling/devourling_flying.vmdl",
        courier_effect = "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_gold_lvl2.vpcf",
        golden = 0,
        model_scale = 15,
        trail = "particles/econ/courier/courier_platinum_roshan/platinum_roshan_ambient.vpcf"
    },
    ["76561198124589941"] = {
        name = "Sirr Squirtlle",
        tier = 3,
        courier = "models/items/courier/faceless_rex/faceless_rex.vmdl",
        courier_effect = "0",
        golden = 0,
        model_scale = 15,
        trail = "particles/econ/items/windrunner/windrunner_cape_cascade/windrunner_windrun_cascade.vpcf"
    },
    ["76561198060371862"] = {
        name = "Shayan - GrayFox",
        tier = 1,
        courier = "models/heroes/invoker_kid/invoker_kid_trainer_dragon.vmdl",
        courier_effect = "0",
        golden = 0,
        model_scale = 15,
        trail = "particles/econ/items/windrunner/windrunner_cape_cascade/windrunner_windrun_cascade.vpcf"
    },
    ["76561198092212451"] = {
        name = "Angmon",
        tier = 1,
        courier = "models/courier/baby_rosh/babyroshan_ti10.vmdl",
        courier_effect = "0",
        golden = 0,
        model_scale = 15,
        trail = "particles/econ/items/windrunner/windrunner_cape_cascade/windrunner_windrun_cascade.vpcf"
    },
    ["76561198036504065"] = {
        name = "Heartless",
        tier = 1,
        courier = "models/courier/baby_rosh/babyroshan_ti10.vmdl",
        courier_effect = "0",
        golden = 0,
        model_scale = 15,
        trail = "particles/econ/items/windrunner/windrunner_cape_cascade/windrunner_windrun_cascade.vpcf"
    },
}

AddPatronEffect = function(unit)
    if not IsServer() then
        return
    end
    local playerID = tostring(PlayerResource:GetSteamID(unit:GetPlayerOwnerID()))

    local patron_effect = nil
    local model = courier_models[RandomInt(1, #courier_models)]

    for id, table in pairs(patron_id) do
        if playerID == id then
            model = table.courier
            scale = table.model_scale
            if table.tier > 0 then
                -- patron_effect = ParticleManager:CreateParticle( table.courier_effect, PATTACH_ABSORIGIN_FOLLOW, unit )

                patron_effect = table.courier_effect

                -- ParticleManager:SetParticleControl( patron_effect, 0, unit:GetAbsOrigin() )
                -- ParticleManager:SetParticleControlEnt( patron_effect, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true )

            end
        end
    end
    return {patron_effect, model, scale}
end

courier_models = {"models/items/courier/snowl/snowl.vmdl", "models/items/courier/snowl/snowl_flying.vmdl"}

EmitManySounds = function(soundlist, delay)
    for i = 1, #soundlist do
        Timers:CreateTimer(i * delay, function()
            EmitGlobalSound(soundlist[i])
        end)
    end
end
