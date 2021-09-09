-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]

--------------------------------------------------------------------------------
modifier_pangolier_swashbuckle_lua = class({})
--------------------------------------------------------------------------------
--[[---------------------------------------------------------------------
	PANGOLIER SWASHBUCKLE MODIFIER
]]------------------------------------------------------------------------

function modifier_pangolier_swashbuckle_lua:IsHidden() return true end
function modifier_pangolier_swashbuckle_lua:IsPurgable() return false end

function modifier_pangolier_swashbuckle_lua:OnCreated( kv )
	local caster = self:GetCaster()
	local ability = caster:FindAbilityByName("pangolier_swashbuckle_lua")
	self.range = ability:GetSpecialValueFor( "range" )
	self.speed = ability:GetSpecialValueFor( "dash_speed" )
	self.radius = ability:GetSpecialValueFor( "start_radius" )
	self.interval = ability:GetSpecialValueFor( "attack_interval" )
	self.damage = ability:GetSpecialValueFor( "damage" )
	self.strikes = ability:GetSpecialValueFor( "strikes" )


	---------------------------------------- SWASHBUCKLE RANGE AND DAMAGE TALENTS -------------------------------------------------------------------------
	local rangeability = caster:FindAbilityByName("special_bonus_pathfinder_pangolier_swashbuckle_lua+range")
	local damageability = caster:FindAbilityByName("special_bonus_pathfinder_pangolier_swashbuckle_lua+damage")
	if rangeability:IsTrained() == true then
		self.range = self.range + rangeability:GetSpecialValueFor("range")
	end
	if damageability:IsTrained() == true then
		self.damage = self.damage + damageability:GetSpecialValueFor("damage")
	end
	--------------------------------------------------------------------------------------------------------------------------------------------------------

	if not IsServer() then return end

	self.origin = self:GetParent():GetOrigin()
	self.direction = Vector( kv.dir_x, kv.dir_y, 0 )
	self.target = self.origin + self.direction*self.range

	self.count = 0
	print(kv.from_crash)
	if kv.from_crash == 0 then
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
	end

	self:StartIntervalThink( self.interval )
	self:OnIntervalThink()
end


function modifier_pangolier_swashbuckle_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE,
	}
	return funcs
end

---------------- SWASHBUCKLE USES ATTACK SHARD ---------------------------------------
function modifier_pangolier_swashbuckle_lua:GetModifierOverrideAttackDamage()
	if self:GetCaster():FindAbilityByName("pangolier_swashbuckle_uses_attack") then	
		return 
	else		
		return self.damage
		
	end
end
-------------------------------------------------------------------------------------


function modifier_pangolier_swashbuckle_lua:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end


function modifier_pangolier_swashbuckle_lua:OnIntervalThink()
	local parent = self:GetParent()
	local targetr = self.origin + (parent:GetRightVector()*self.range)
	local targetl = self.origin + ((parent:GetRightVector()*(-1))*self.range)
	local targetf = self.origin + ((parent:GetForwardVector())*self.range)
	local targetb = self.origin + ((parent:GetForwardVector()*(-1))*self.range)

	local enemies = FindUnitsInLine(
		parent:GetTeamNumber(),	
		self.origin,	
		targetf,
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0
	)

	for _,enemy in pairs(enemies) do
		parent:PerformAttack( enemy, true, true, true, false, false, false, true )
		local sound_target = "Hero_Pangolier.Swashbuckle.Damage"
		EmitSoundOn( sound_target, enemy )
	end

	--------------------------- SWASHBUCKLE 360 SHARD ------------------------------------
	if	parent:FindAbilityByName("pangolier_swashbuckle_360") then

		local enemies2 = FindUnitsInLine(
			parent:GetTeamNumber(),
			self.origin,
			targetr,
			nil,
			self.radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			0	
		)
		for _,enemy in pairs(enemies2) do
			parent:PerformAttack( enemy, true, true, true, false, false, false, true )

			local sound_target = "Hero_Pangolier.Swashbuckle.Damage"
			EmitSoundOn( sound_target, enemy )
		end

		local enemies3 = FindUnitsInLine(
			parent:GetTeamNumber(),
			self.origin,
			targetl,
			nil,
			self.radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			0	
		)
		for _,enemy in pairs(enemies3) do		
			parent:PerformAttack( enemy, true, true, true, false, false, false, true )
			local sound_target = "Hero_Pangolier.Swashbuckle.Damage"
			EmitSoundOn( sound_target, enemy )
		end

		local enemies4 = FindUnitsInLine(
			parent:GetTeamNumber(),
			self.origin,
			targetb,
			nil,
			self.radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			0
		)
		for _,enemy in pairs(enemies4) do
			parent:PerformAttack( enemy, true, true, true, false, false, false, true )
			local sound_target = "Hero_Pangolier.Swashbuckle.Damage"
			EmitSoundOn( sound_target, enemy )
		end
	end
	--------------------------------------------------------------------------------------------------------
	-- Play effects
	self:PlayEffects()

	self.count = self.count+1
	if self.count>=self.strikes then
		self:Destroy()
	end
end

function modifier_pangolier_swashbuckle_lua:PlayEffects()

	local particle_cast = "particles/units/heroes/hero_pangolier/pangolier_swashbuckler.vpcf"
	local sound_cast = "Hero_Pangolier.Swashbuckle.Attack"
	
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 1, self.direction )

	self:AddParticle(
		effect_cast,
		false, 
		false, 
		-1,
		false, 
		false 
	)
	---------------------- SWASHBUCKLE 360 SHARD ---------------------------------------------------------------
	if	self:GetParent():FindAbilityByName("pangolier_swashbuckle_360") then
		local effect_cast2 = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( effect_cast2, 1, self.direction * (-1) )
		self:AddParticle(
			effect_cast2,
			false, 
			false, 
			-1, 
			false,
			false
		)
		local effect_cast3 = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( effect_cast3, 1, self:GetParent():GetRightVector() )
		self:AddParticle(
			effect_cast3,
			false, 
			false,
			-1, 
			false, 
			false 
		)
		local effect_cast4 = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( effect_cast4, 1, self:GetParent():GetRightVector() * (-1) )
		self:AddParticle(
			effect_cast4,
			false, 
			false,
			-1,
			false,
			false
		)
	end
	----------------------------------------------------------------------------------------------------------------

	EmitSoundOn( sound_cast, self:GetParent() )
end