modifier_generic_talent_handler = class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,
	RemoveOnDeath 			= function(self) return false end,
	AllowIllusionDuplicate	= function(self) return false end
})

LinkLuaModifier( "modifier_ascension_armor", "modifiers/modifier_ascension_armor", LUA_MODIFIER_MOTION_NONE )

require("utility_functions")
--------------------------------------------------------------------------------
function modifier_generic_talent_handler:split(s, sep)
    local fields = {}
    
    local sep = sep or " "
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)
    
    return fields
end


function modifier_generic_talent_handler:OnCreated(table)
	if not IsServer() then return end

	ListenToGameEvent("dota_player_learned_ability", Dynamic_Wrap(modifier_generic_talent_handler, 'OnAbilityLearned'), self)

	self.unique_list = {}
	for i = 6,13 do
		local name = self:GetParent():GetAbilityByIndex(i)
		if name then 
			name = name:GetAbilityName()			
			if string.sub(name, 1, 25) == "special_bonus_pathfinder_" then		
				local short_name = string.sub(name, 26)				
				local temp_table = self:split(short_name, "+")
				
				self.unique_list[name] = {}
				self.unique_list[name]["description"] = name 
				self.unique_list[name]["ability_name"] = temp_table[1]
				self.unique_list[name]["special_value_name"] = temp_table[2]

				if temp_table[2] == "cooldown" then
					self.unique_list[name]["operator"] = MINOR_ABILITY_UPGRADE_OP_MUL
				else
					self.unique_list[name]["operator"] = MINOR_ABILITY_UPGRADE_OP_ADD
				end

				self.unique_list[name]["value"] = tonumber(self:GetParent():FindAbilityByName(name):GetLevelSpecialValueFor(temp_table[2],1))
				-- PrintTable(self.unique_list[name], "  ")

			end
		else
			print("no name")
		end
	end

	local table_name = "TABLEP" .. self:GetParent():GetPlayerID()
	_G[table_name]["damage_dealt"] = 0	

	self:GiveItems()
end

function modifier_generic_talent_handler:GiveItems()					
	local blink = GrantItemDropToHero( self:GetParent(), "item_blink_bootleg" )		
	self:GetParent():SwapItems(16,8)

	

	if IsServer() and PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) < 2 then
		GameRules:SendCustomMessage("#PATHFINDERS_solo_welcome_message",2,0	)
		local midas = GrantItemDropToHero( self:GetParent(), "item_feet_of_midas" )
		if midas ~= nil then
			local charges = 5 + ((AGHANIM_STARTING_GOLD * 3) /midas:GetSpecialValueFor( "bonus_gold" ))
			midas:SetCurrentCharges( charges )
		
		end
		local tome = GrantItemDropToHero( self:GetParent(), "item_tome_of_greater_knowledge" )
		if tome then
			tome:SetCurrentCharges(3)
		end
		GrantItemDropToHero( self:GetParent(), "item_panic_button" )
		GrantItemDropToHero( self:GetParent(), "item_mirror_shield" )
		GrantItemDropToHero( self:GetParent(), "item_gem" )												
	elseif IsServer() and PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) < 3 then
		local midas = GrantItemDropToHero( self:GetParent(), "item_feet_of_midas" )		
		if midas ~= nil then
			local charges = 2 + ((AGHANIM_STARTING_GOLD * 2) /midas:GetSpecialValueFor( "bonus_gold" ))
			midas:SetCurrentCharges( charges )
		end
		GrantItemDropToHero( self:GetParent(), "item_panic_button" )		
	end		
end

function modifier_generic_talent_handler:OnAbilityLearned(kv)
	if not IsServer() then return end
	if self:GetParent():GetPlayerOwnerID() == kv.PlayerID then
		for name,table in pairs(self.unique_list) do
			if kv.abilityname == name then
				CAghanim:AddMinorAbilityUpgrade( self:GetParent(), self.unique_list[name] )			
			end
		end
	end	
end

function modifier_generic_talent_handler:DeclareFunctions()
	local funcs = {		
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

function modifier_generic_talent_handler:OnTakeDamage(params)
	if not params.attacker or params.attacker ~= self:GetParent() then return end

	 local table_name = "TABLEP" .. self:GetParent():GetPlayerID()
	_G[table_name]["damage_dealt"] = _G[table_name]["damage_dealt"] + params.damage	
end
