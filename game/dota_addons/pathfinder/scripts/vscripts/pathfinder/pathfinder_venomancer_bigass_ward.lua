pathfinder_venomancer_bigass_ward = class({})
LinkLuaModifier( "modifier_rooted", "pathfinder/modifier_rooted", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pathfinder_bigass_ward_passive", "pathfinder/modifier_pathfinder_bigass_ward_passive", LUA_MODIFIER_MOTION_NONE )

require("libraries.has_shard")

function pathfinder_venomancer_bigass_ward:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("venomancer_venm_anger_06")
	return true
end


function pathfinder_venomancer_bigass_ward:OnSpellStart()	
	self:GetCaster():EmitSound("Hero_Venomancer.PoisonNova")
	--The Plague Ward should initialize facing away from Venomancer, so find that direction.
	local caster_origin = self:GetCaster():GetAbsOrigin()
	local direction = (self:GetCursorPosition() - caster_origin):Normalized()
	direction.z = 0	
			
		local plague_ward_unit = CreateUnitByName("pathfinder_venomancer_big_ward", self:GetCursorPosition(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeam())		
		plague_ward_unit.veno = self:GetCaster()
		if self:GetCaster().terry ~= nil and self:GetCaster().terry:IsAlive() then			
			self:GetCaster().terry:ForceKill(false)
		end
		self:GetCaster().terry = plague_ward_unit
		plague_ward_unit:SetForwardVector(direction)		
		plague_ward_unit:SetOwner(self:GetCaster())
		--plague_ward_unit:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
		plague_ward_unit:SetBaseMoveSpeed(0)
		
		plague_ward_unit:SetBaseMaxHealth(self:GetLevelSpecialValueFor("health_multiplier", self:GetLevel() - 1) * self:GetCaster():GetMaxHealth())
		plague_ward_unit:SetHealth(self:GetLevelSpecialValueFor("health_multiplier", self:GetLevel() - 1) * self:GetCaster():GetMaxHealth())

		plague_ward_unit:SetBaseHealthRegen(self:GetLevelSpecialValueFor("regen_multiplier", self:GetLevel() - 1) * self:GetCaster():GetHealthRegen())


		--Display particle effects for Venomancer as well as the plague ward.
		local venomancer_plague_ward_cast_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_venomancer/venomancer_ward_cast.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
		local plague_ward_spawn_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_venomancer/venomancer_ward_spawn.vpcf", PATTACH_ABSORIGIN, plague_ward_unit)

		plague_ward_unit:AddNewModifier(plague_ward_unit, nil, "modifier_rooted", nil)
		plague_ward_unit:AddNewModifier(plague_ward_unit, nil, "modifier_kill", {duration = self:GetCooldown(1) - 15})
		local temp = plague_ward_unit:AddNewModifier(plague_ward_unit, nil, "modifier_pathfinder_bigass_ward_passive", nil)
		temp.creator = self:GetCaster()
		
		
		--Store the unit that spawned this plague ward (i.e. Venomancer).
		plague_ward_unit.venomancer_plague_ward_parent = self:GetCaster()
		plague_ward_unit.venomancer_plague_ward_parent.bigass_ward = plague_ward_unit				
end
