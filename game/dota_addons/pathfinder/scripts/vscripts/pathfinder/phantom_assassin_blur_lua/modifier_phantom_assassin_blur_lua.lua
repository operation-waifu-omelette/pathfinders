modifier_phantom_assassin_blur_lua = class({})
LinkLuaModifier( "modifier_absorb_spell", "pathfinder/modifier_absorb_spell", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_phantom_assassin_blur_lua_aura", "pathfinder/phantom_assassin_blur_lua/phantom_assassin_blur_lua", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
-- Classifications
function modifier_phantom_assassin_blur_lua:IsHidden()
	-- dynamic
	-- if IsServer() then
		return (self:GetParent():PassivesDisabled())
	-- end
end 

function modifier_phantom_assassin_blur_lua:IsDebuff()
	return false
end

function modifier_phantom_assassin_blur_lua:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_phantom_assassin_blur_lua:OnCreated( kv )
	-- references
	if IsServer() then
		self.bonus_evasion = self:GetCaster():FindAbilityByName("phantom_assassin_blur_lua"):GetSpecialValueFor( "bonus_evasion" )
		self.radius = self:GetCaster():FindAbilityByName("phantom_assassin_blur_lua"):GetSpecialValueFor( "radius" )
		self:SetHasCustomTransmitterData( true )
	end
	self.interval = 0.5	

	
	-- Start interval
	self:StartIntervalThink( self.interval )
	self:OnIntervalThink()
end

function modifier_phantom_assassin_blur_lua:OnRefresh( kv )
	-- references
	if IsServer() then
		self.bonus_evasion = self:GetCaster():FindAbilityByName("phantom_assassin_blur_lua"):GetSpecialValueFor( "bonus_evasion" )
		self.radius = self:GetCaster():FindAbilityByName("phantom_assassin_blur_lua"):GetSpecialValueFor( "radius" )
	end
end

function modifier_phantom_assassin_blur_lua:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_phantom_assassin_blur_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EVASION_CONSTANT,		
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_DEATH,
	}

	return funcs
end

function modifier_phantom_assassin_blur_lua:OnDeath(kv)
	if IsServer() then
		if self:GetCaster():HasAbility("pathfinder_special_pa_blur_cdr") and not self:GetAbility():IsCooldownReady() then
			local special = self:GetCaster():FindAbilityByName("pathfinder_special_pa_blur_cdr")
			local cdr_seconds = self:GetAbility():GetCooldown(self:GetAbility():GetLevel()) / 100 * special:GetLevelSpecialValueFor("reduce_percent",1)
			local valid_radius = special:GetLevelSpecialValueFor("radius",1)
			if kv.unit:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() and (kv.unit:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D() < valid_radius then
				local new_cd = math.max(0, self:GetAbility():GetCooldownTimeRemaining() - cdr_seconds)
				self:GetAbility():EndCooldown()
				self:GetAbility():StartCooldown(new_cd)
			end
		end
	end
end


function modifier_phantom_assassin_blur_lua:GetModifierIgnoreMovespeedLimit()	
	if self.bHasRegenBonus then
		return 1
	end
end

function modifier_phantom_assassin_blur_lua:GetModifierMoveSpeedBonus_Percentage()	
	if self.bHasRegenBonus and self:GetParent():IsInvisible() then
		return self.movespeed
	end
end

function modifier_phantom_assassin_blur_lua:GetModifierConstantHealthRegen()	
	if self.bHasRegenBonus and self:GetParent():IsInvisible() then
		return self.regen
	end
end

function modifier_phantom_assassin_blur_lua:GetModifierEvasion_Constant()
	if not self:GetParent():PassivesDisabled() then
		return self.bonus_evasion
	end
end
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Interval Effects
function modifier_phantom_assassin_blur_lua:OnIntervalThink()
	if IsServer() then
		
		if self:GetParent() == self:GetCaster() and self:GetCaster():HasAbility("pathfinder_special_pa_blur_aoe") and not self:GetCaster():HasModifier("modifier_phantom_assassin_blur_lua_aura") then
			print("adding blur aura")
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_phantom_assassin_blur_lua_aura", {})	
		end
		
		self.bHasRegenBonus = self:GetCaster():HasAbility("pathfinder_special_pa_blur_regen")
		if self.bHasRegenBonus then
			self.regen_bonus_ability = self:GetCaster():FindAbilityByName("pathfinder_special_pa_blur_regen")
			self.regen = self:GetParent():GetMaxHealth() / 100 * self.regen_bonus_ability:GetLevelSpecialValueFor("max_health_regen", 1)
			self.movespeed = self.regen_bonus_ability:GetLevelSpecialValueFor("bonus_movespeed_percentage", 1)			
		end
		-- Hero search flag based on detecting or undetecting

		-- Find Enemy Heroes in Radius
		local enemies = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self:GetParent():GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		-- Flip if detected
		if (#enemies>0) and self:GetCaster():FindAbilityByName("phantom_assassin_blur_lua").in_grace_period == false then
			if self:GetParent():HasModifier("modifier_invisible") then
				self:GetParent():RemoveModifierByName("modifier_invisible")				
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_phantom_assassin_blur_lua:GetEffectName()	
	return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_blur.vpcf"	
end

function modifier_phantom_assassin_blur_lua:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_phantom_assassin_blur_lua:AddCustomTransmitterData( )
	return
	{
		regen = self.regen,
		bonus_evasion = self.bonus_evasion,
		movespeed = self.movespeed,
		bHasRegenBonus = self.bHasRegenBonus,
	}
end

function modifier_phantom_assassin_blur_lua:HandleCustomTransmitterData( data )
	self.regen = data.regen
	self.bonus_evasion = data.bonus_evasion
	self.movespeed = data.movespeed
	self.bHasRegenBonus = data.bHasRegenBonus
end
