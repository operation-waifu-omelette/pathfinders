if IsClient() then
	CDOTA_BaseNPC = C_DOTA_BaseNPC
	CDOTABaseAbility = C_DOTABaseAbility
--	CDOTA_Item = C_DOTA_Item_LUA
end

function CDOTA_BaseNPC:HasTalent(talentName)
	if self and not self:IsNull() and self:HasAbility(talentName) then
		if self:FindAbilityByName(talentName):GetLevel() > 0 then 
            return true 
        end
	end

	return false
end

function CDOTA_BaseNPC:FindTalentValue(talentName, key)
	if self:HasAbility(talentName) then
		local value_name = key or "value"
		return self:FindAbilityByName(talentName):GetSpecialValueFor(value_name)
	end

	return 0
end

function CDOTA_BaseNPC:HighestTalentTypeValue(talentType)
	local value = 0
	for i = 0, 23 do
		local talent = self:GetAbilityByIndex(i)
		if talent and string.match(talent:GetName(), "special_bonus_"..talentType.."_(%d+)") and self:FindTalentValue(talent:GetName()) > value then
			value = self:FindTalentValue(talent:GetName())
		end
	end

	return value
end

function CDOTABaseAbility:GetTalentSpecialValueFor(value)
	local base = self:GetSpecialValueFor(value)
	local talentName
	local kv = self:GetAbilityKeyValues()
	for k,v in pairs(kv) do -- trawl through keyvalues
		if k == "AbilitySpecial" then
			for l,m in pairs(v) do
				if m[value] then
					talentName = m["LinkedSpecialBonus"]
				end
			end
		end
	end
	if talentName then 
		local talent = self:GetCaster():FindAbilityByName(talentName)
		if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
	end
	return base
end

function CDOTA_BaseNPC:SetUnitOnClearGround()
	Timers:CreateTimer(FrameTime(), function()
		self:SetAbsOrigin(Vector(self:GetAbsOrigin().x, self:GetAbsOrigin().y, GetGroundPosition(self:GetAbsOrigin(), self).z))		
		FindClearSpaceForUnit(self, self:GetAbsOrigin(), true)
		ResolveNPCPositions(self:GetAbsOrigin(), 64)
	end)
end