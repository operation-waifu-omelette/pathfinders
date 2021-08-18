axe_battle_hunger_lua = class({})
LinkLuaModifier( "modifier_axe_battle_hunger_lua", "pathfinder/axe/modifier_axe_battle_hunger_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_axe_battle_hunger_lua_debuff", "pathfinder/axe/modifier_axe_battle_hunger_lua_debuff", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
require("libraries.has_shard")

-- Ability Start
function axe_battle_hunger_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target_loc = self:GetCursorPosition()

	-- load data
	local duration = self:GetSpecialValueFor("duration")

	local enemies = FindRadiusPoint(caster, target_loc, self:GetLevelSpecialValueFor("radius", self:GetLevel() - 1), true)

	for _,target in pairs(enemies) do
		target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_axe_battle_hunger_lua_debuff", -- modifier name
		{ duration = duration } -- kv
		)
		
		-- local debuff = target:FindModifierByName("modifier_axe_battle_hunger_lua_debuff")
		-- if debuff:GetStackCount() < 1 or debuff:GetStackCount() < self:GetSpecialValueFor("max_stacks") then
		-- 	debuff:IncrementStackCount()
		-- end


		caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_axe_battle_hunger_lua", -- modifier name
		{ duration = duration } -- kv
	)
	end

	-- effects
	local sound_cast = "Hero_Axe.Battle_Hunger"
	caster:EmitSound( sound_cast)
end

function axe_battle_hunger_lua:OnSpellStartSingle(unit)
	-- unit identifier
	local caster = self:GetCaster()
	local target = unit

	-- load data
	local duration = self:GetSpecialValueFor("duration")
		
	target:AddNewModifier(
	caster, -- player source
	self, -- ability source
	"modifier_axe_battle_hunger_lua_debuff", -- modifier name
	{ duration = duration } -- kv
	)	
	

	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_axe_battle_hunger_lua", -- modifier name
		{ duration = duration } -- kv
	)	
end

function axe_battle_hunger_lua:GetAOERadius()
	return self:GetLevelSpecialValueFor("radius", self:GetLevel() - 1)
end

--------------------------------------------------------------------------------
-- function axe_battle_hunger_lua:PlayEffects()
-- 	-- Get Resources
-- 	local particle_cast = "string"
-- 	local sound_cast = "string"

-- 	-- Get Data

-- 	-- Create Particle
-- 	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_NAME, hOwner )
-- 	ParticleManager:SetParticleControl( effect_cast, iControlPoint, vControlVector )
-- 	ParticleManager:SetParticleControlEnt(
-- 		effect_cast,
-- 		iControlPoint,
-- 		hTarget,
-- 		PATTACH_NAME,
-- 		"attach_name",
-- 		vOrigin, -- unknown
-- 		bool -- unknown, true
-- 	)
-- 	ParticleManager:SetParticleControlForward( effect_cast, iControlPoint, vForward )
-- 	SetParticleControlOrientation( effect_cast, iControlPoint, vForward, vRight, vUp )
-- 	ParticleManager:ReleaseParticleIndex( effect_cast )

-- 	-- Create Sound
-- 	EmitSoundOnLocationWithCaster( vTargetPosition, sound_location, self:GetCaster() )
-- end

