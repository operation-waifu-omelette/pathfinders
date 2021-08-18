modifier_pathfinder_treant_model_change = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_treant_model_change:IsHidden()
	return true
end

function modifier_pathfinder_treant_model_change:IsDebuff()
	return false
end

function modifier_pathfinder_treant_model_change:IsPurgable()
	return false
end

function modifier_pathfinder_treant_model_change:OnCreated(table)
	local models = {
		"models/heroes/furion/treant.vmdl",
		"models/items/furion/treant_flower_1.vmdl",
		"models/items/furion/treant_stump.vmdl",
		"models/items/furion/treant/abyssal_prophet_abyssal_prophet_treant/abyssal_prophet_abyssal_prophet_treant.vmdl",
		"models/items/furion/treant/allfather_of_nature_treant/allfather_of_nature_treant.vmdl",
		"models/items/furion/treant/defender_of_the_jungle_lakad_coconut/defender_of_the_jungle_lakad_coconut.vmdl",
		"models/items/furion/treant/eternalseasons_treant/eternalseasons_treant.vmdl",
		"models/items/furion/treant/father_treant/father_treant.vmdl",
		"models/items/furion/treant/furion_treant_nelum_red/furion_treant_nelum_red.vmdl",
		"models/items/furion/treant/hallowed_horde/hallowed_horde.vmdl",
		"models/items/furion/treant/primeval_treant/primeval_treant.vmdl",
		"models/items/furion/treant/ravenous_woodfang/ravenous_woodfang.vmdl",
		"models/items/furion/treant/shroomling_treant/shroomling_treant.vmdl",
		"models/items/furion/treant/the_ancient_guardian_the_ancient_treants/the_ancient_guardian_the_ancient_treants.vmdl",
		"models/items/furion/treant/treant_cis/treant_cis.vmdl",
	}
	if IsServer() then
		-- self:GetParent():SetModel(models[RandomInt(0, #models)])
		self:GetParent():SetOriginalModel(models[RandomInt(0, #models)])
	end
end


--------------------------------------------------------------------------------
-- function modifier_pathfinder_treant_model_change:DeclareFunctions()
-- 	local funcs = {		
-- 		MODIFIER_PROPERTY_MODEL_CHANGE,		
-- 	}
-- 	return funcs
-- end

-- function modifier_pathfinder_treant_model_change:GetModifierModelChange()
	
-- end