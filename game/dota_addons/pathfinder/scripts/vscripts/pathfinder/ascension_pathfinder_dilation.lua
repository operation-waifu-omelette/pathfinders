ascension_pathfinder_dilation = class( {} )
LinkLuaModifier("modifier_ascension_pathfinder_dilation", "pathfinder/ascension_pathfinder_dilation", LUA_MODIFIER_MOTION_NONE)
-----------------------------------------------------------------------------------------
require( "utility_functions" )
require("libraries.timers")
require("libraries.has_shard")

--------------------------------------------------------------------------------
function ascension_pathfinder_dilation:Precache( context )	
	PrecacheResource( "particle", "particles/econ/items/faceless_void/faceless_void_bracers_of_aeons/fv_bracers_of_aeons_dialatedebuf.vpcf", context )	
	PrecacheResource( "particle", "particles/econ/items/faceless_void/faceless_void_bracers_of_aeons/fv_bracers_of_aeons_timedialate.vpcf", context )	
end


function ascension_pathfinder_dilation:OnSpellStart()

	if not IsServer() then
		return
	end
	
	self.nPreviewFX = ParticleManager:CreateParticle( "particles/econ/items/faceless_void/faceless_void_bracers_of_aeons/fv_bracers_of_aeons_dialatedebuf.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( self.nPreviewFX, 0, self:GetCaster():GetAbsOrigin() + Vector(0,0,70))	

	Timers:CreateTimer(self:GetSpecialValueFor("windup_time"), function() 
		if self.nPreviewFX then
			ParticleManager:DestroyParticle(self.nPreviewFX, false)
			ParticleManager:ReleaseParticleIndex(self.nPreviewFX)
		end

		local fx = ParticleManager:CreateParticle( "particles/econ/items/faceless_void/faceless_void_bracers_of_aeons/fv_bracers_of_aeons_timedialate.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControlEnt( fx, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetOrigin(), true )
		ParticleManager:SetParticleControl( fx, 1, Vector( self:GetSpecialValueFor("radius"), 1, 1 ) )
		ParticleManager:SetParticleControl( fx, 6, Vector( self:GetSpecialValueFor("radius"), 1, 1 ) )
		ParticleManager:ReleaseParticleIndex(fx)

		EmitSoundOn( "Hero_FacelessVoid.Chronosphere", self:GetCaster() )

		local flDuration = self:GetSpecialValueFor( "duration" )

		local hEnemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), 
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false )

		for _,enemy in pairs(hEnemies) do
			if not enemy:IsMagicImmune() then
				enemy:AddNewModifier( self:GetCaster(), self, "modifier_ascension_pathfinder_dilation", { duration = flDuration } )
			end
		end		
	end)	
end

--------------------------------

--------------------------------
modifier_ascension_pathfinder_dilation = class( {} )
function modifier_ascension_pathfinder_dilation:IsDebuff() return true end
function modifier_ascension_pathfinder_dilation:IsPurgable() return true end
function modifier_ascension_pathfinder_dilation:RemoveOnDeath() return true end
function modifier_ascension_pathfinder_dilation:IsHidden() return false end

function modifier_ascension_pathfinder_dilation:GetEffectName()	
	return "particles/econ/items/faceless_void/faceless_void_bracers_of_aeons/fv_bracers_of_aeons_dialatedebuf.vpcf"	
end

function modifier_ascension_pathfinder_dilation:OnCreated(table)
	if not IsServer() then return end
	self:StartIntervalThink(1)
end


function modifier_ascension_pathfinder_dilation:OnIntervalThink()		
	if not IsServer() then return end
	for i = 0, 23 do
		local current_ability = self:GetParent():GetAbilityByIndex(i)
		if current_ability and not current_ability:IsPassive() and not current_ability:IsAttributeBonus() and not current_ability:IsCooldownReady() then
			local cd = current_ability:GetCooldownTimeRemaining()
			current_ability:EndCooldown()
			current_ability:StartCooldown( cd + self:GetAbility():GetSpecialValueFor("negative_cdr") )
		end
	end
end
