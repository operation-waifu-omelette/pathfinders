item_feet_of_midas = class({})
LinkLuaModifier("modifier_item_feet_of_midas", "pathfinder/item_feet_of_midas", LUA_MODIFIER_MOTION_NONE)



function item_feet_of_midas:CastFilterResultTarget(target)
	if IsServer() then
		local caster = self:GetCaster()

		-- If the target is in the caster's team, deny it
		if target:GetTeamNumber() == caster:GetTeamNumber() then
			return UF_FAIL_FRIENDLY
		end

		-- If the target is a hero, deny it
		if target:IsHero() then
			return UF_FAIL_HERO
		end

		-- If the target is a ward, deny it
		if target:IsOther() then
			return UF_FAIL_CUSTOM
		end

		-- If the target is a necronbook summon, deny it
		if string.find(target:GetUnitName(), "necronomicon") then
			return UF_FAIL_CUSTOM
		end

		-- If the target is a spirit bear, deny it
		if target:IsConsideredHero() then
			return UF_FAIL_CONSIDERED_HERO
		end

		-- If the target is a building, deny it
		if target:IsBuilding() then
			return UF_FAIL_BUILDING
		end

		return UF_SUCCESS
	end
end

function item_feet_of_midas:GetCustomCastErrorTarget(target)
	if IsServer() then
		local caster = self:GetCaster()

		-- Ward message
		if target:IsOther() then
			return "#dota_hud_error_cant_use_on_wards"
		end

		-- Necronomicon message
		if string.find(target:GetUnitName(), "necronomicon") then
			return "#dota_hud_error_cant_use_on_necrobook"
		end
	end
end

function item_feet_of_midas:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_POINT
end

function item_feet_of_midas:GetAbilityTextureName()
	if self:GetCurrentCharges() > 0 then
		return "hand_of_midas_ogre_arcana"
	else
		return "paw_of_lucius"
	end
end

function item_feet_of_midas:OnSpellStart()
	if self:GetCurrentCharges() == 0 then
		return
	end
	local caster = self:GetCaster()
	local target = CreateUnitByName("pathfinder_midas_penguin", self:GetCursorPosition(), true, nil, nil, DOTA_TEAM_NEUTRALS )
	local dust = ParticleManager:CreateParticle("particles/econ/items/pets/pet_frondillo/pet_spawn_dirt_frondillo.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(dust, 0, target:GetAbsOrigin())	
	ParticleManager:SetParticleControl(dust, 0, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(dust)
	local ability = self
	local sound_cast = "DOTA_Item.Hand_Of_Midas"

	-- Parameters and calculations
	local bonus_gold = ability:GetSpecialValueFor("bonus_gold")	
	self:SpendCharge()
	require("libraries.timers")

	Timers:CreateTimer( 1, function()
        	-- Play sound and show gold gain message to the owner
			target:EmitSound(sound_cast)
			SendOverheadEventMessage(PlayerResource:GetPlayer(caster:GetPlayerOwnerID()), OVERHEAD_ALERT_GOLD, target, bonus_gold, nil)

			-- Draw the midas gold conversion particle
			local midas_particle = ParticleManager:CreateParticle("particles/econ/items/alchemist/alchemist_midas_knuckles/alch_hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(midas_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)

			-- Grant gold and XP only to the caster
			target:SetDeathXP(0)
			target:SetMinimumGoldBounty(0)
			target:SetMaximumGoldBounty(0)
			target:DropItemAtPosition(target:GetAbsOrigin(), item_health_potion)
			target:Kill(ability, caster)
			-- target:ForceKill(true)

			-- If this is not a hero, get the player's hero
			if not caster:IsHero() then
				caster = caster:GetPlayerOwner():GetAssignedHero()
			end
			
			caster:ModifyGold(bonus_gold, true, 0)			

			if IsServer() and dust then
				ParticleManager:DestroyParticle(dust, true)
			end
			ParticleManager:ReleaseParticleIndex(dust)
        	return nil
	end)
	
end

function item_feet_of_midas:GetIntrinsicModifierName()
	return "modifier_item_feet_of_midas"
end

modifier_item_feet_of_midas = class({})

function modifier_item_feet_of_midas:IsHidden()			return true end
function modifier_item_feet_of_midas:IsPurgable()		return false end
function modifier_item_feet_of_midas:RemoveOnDeath()	return false end
function modifier_item_feet_of_midas:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end
