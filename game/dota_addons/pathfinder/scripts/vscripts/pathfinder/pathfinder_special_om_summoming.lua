pathfinder_special_om_summoming = class({})
LinkLuaModifier( "modifier_pathfinder_mini_ogre_passive", "pathfinder/pathfinder_special_om_summoming", LUA_MODIFIER_MOTION_NONE )

require("libraries.has_shard")
require("libraries.timers")


function pathfinder_special_om_summoming:GetChannelAnimation()	
    return ACT_DOTA_VICTORY
end

function pathfinder_special_om_summoming:GetChannelTime()	
    return self:GetLevelSpecialValueFor("channel_time",1)
end

function pathfinder_special_om_summoming:OnUpgrade()
	if IsServer() then
		self:GetCaster():SwapAbilities("pathfinder_special_om_summoming", "ogre_magi_multicast_lua", true, true)
	end
end


function pathfinder_special_om_summoming:OnAbilityPhaseStart()
	if not IsServer() then return end
	self.interrupted = false	
	self.caster = self:GetCaster()

	self.interval = self:GetLevelSpecialValueFor("interval", 1)
	self.internal_timer = 0

	self.delay = 1.05	
	return true
end

function pathfinder_special_om_summoming:OnAbilityPhaseInterrupted()
	self.interrupted = true
	self:StartCooldown(self:GetCooldown(self:GetLevel()))
end

function pathfinder_special_om_summoming:OnChannelThink(eInterval)		
	if self.interrupted then 
		self:StartCooldown(self:GetCooldown(self:GetLevel()))
		return
	end

	if self.delay > 0 then
		self.delay = self.delay - eInterval
		return
	end

	self.internal_timer = self.internal_timer - eInterval

	if self.internal_timer > 0 then				
		return
	end

	local caster = self.caster

	print(self.interval)
	
	self.internal_timer = self.interval	
	local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 10000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )

	particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_duel.vpcf", PATTACH_ABSORIGIN, caster)	
	ParticleManager:SetParticleControl(particle, 7, caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle)

	local hUnit = CreateUnitByName( "om_summon", self:GetCaster():GetAbsOrigin() + RandomVector(RandomInt(50,150)), true, nil, nil, DOTA_TEAM_GOODGUYS )
	hUnit:AddNewModifier(self:GetCaster(), self, "modifier_pathfinder_mini_ogre_passive", {})
	hUnit:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = self:GetLevelSpecialValueFor("lifetime", 1)})
	if #enemies > 0 then		
		hUnit:MoveToTargetToAttack( enemies[1] )		
	end
end


modifier_pathfinder_mini_ogre_passive = class({})

function modifier_pathfinder_mini_ogre_passive:CheckState()
	local state =
	{				
		-- [MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
	}

	return state
end

function modifier_pathfinder_mini_ogre_passive:DeclareFunctions()
	local funcs =
	{
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end

function modifier_pathfinder_mini_ogre_passive:OnCreated(table)
	self.delay = 0
	self.radius = 10
end

function modifier_pathfinder_mini_ogre_passive:GetEffectName()
	return "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_guided_missile.vpcf"
end

function modifier_pathfinder_mini_ogre_passive:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function modifier_pathfinder_mini_ogre_passive:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		self:GetParent():ForceKill(false)
	end
end


function modifier_pathfinder_mini_ogre_passive:OnDeath(table)
	if table.unit ~= self:GetParent() then return end
	local fireblast = self:GetCaster():FindAbilityByName("ogre_magi_fireblast_lua")
	if fireblast and fireblast:GetLevel() > 0 then
		local caster = self:GetCaster()
		local this_mod = self
		Timers:CreateTimer(self.delay, function()			
			local nFXIndex2 = ParticleManager:CreateParticle( "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_guided_missile_death.vpcf", PATTACH_CUSTOMORIGIN, nil )
			ParticleManager:SetParticleControl( nFXIndex2, 0, table.unit:GetOrigin() )			
			ParticleManager:ReleaseParticleIndex( nFXIndex2 )			

			local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
				table.unit:GetAbsOrigin(),
				nil,
				200,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
				FIND_CLOSEST,
				false )

			local old_cursor = caster:GetCursorCastTarget()
			if #enemies > 0 then
				caster:SetCursorCastTarget(enemies[1])
					fireblast:OnSpellStart()	

					local multicast = caster:FindModifierByName("modifier_ogre_magi_multicast_lua")
					if multicast then
						local param = {}
						param.unit = caster
						param.ability = fireblast
						param.target = enemies[1]
						multicast:OnAbilityFullyCast(param)			
					end
				if old_cursor then
					caster:SetCursorCastTarget(old_cursor)
				end
			else
				table.unit:EmitSound("Hero_OgreMagi.Fireblast.Target")
			end
		end)
	end
end

