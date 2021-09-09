---------------------------------------------------------------------------------------------------------------------------------------------------------

LinkLuaModifier("modifier_npc_gyroshell_impact_check", "pathfinder/pangolier/modifier_pangolier_npc_gyroshell_lua", LUA_MODIFIER_MOTION_NONE) 
LinkLuaModifier("modifier_npc_gyroshell_impacted", "pathfinder/pangolier/modifier_pangolier_npc_gyroshell_lua", LUA_MODIFIER_MOTION_NONE) 
LinkLuaModifier("modifier_npc_gyroshell_end", "pathfinder/pangolier/modifier_pangolier_npc_gyroshell_lua", LUA_MODIFIER_MOTION_NONE) 

modifier_pangolier_npc_gyroshell_lua = modifier_pangolier_npc_gyroshell_lua or class({})
modifier_npc_gyroshell_impact_check = modifier_npc_gyroshell_impact_check or class({})
modifier_npc_gyroshell_impacted = modifier_npc_gyroshell_impacted or class({})
modifier_npc_gyroshell_end = modifier_npc_gyroshell_end or class({})

---------------------------------------------------------------------------------------------------------------------------------------------------------

--[[---------------------------------------------------------------------
						NPC GYROSHELL
]]------------------------------------------------------------------------

function modifier_pangolier_npc_gyroshell_lua:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true
	}
end

function modifier_pangolier_npc_gyroshell_lua:IsHidden() return false end
function modifier_pangolier_npc_gyroshell_lua:IsPurgable() return false end
function modifier_pangolier_npc_gyroshell_lua:IsDebuff() return false end
function modifier_pangolier_npc_gyroshell_lua:IgnoreTenacity() return true end

function modifier_pangolier_npc_gyroshell_lua:OnCreated()

	self.collision_modifier = "modifier_imba_gyroshell_ricochet"
	self.end_sound = "pangobabyrollend"
	self.loop_sound = "Hero_Pangolier.Gyroshell.Loop"

	self.sprinting_effect = "particles/units/heroes/hero_pangolier/pangolier_gyroshell.vpcf"
	self.tick_interval = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("tick_interval")
	self.radius = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("radius")
	self.hit_radius = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("hit_radius")
	self.stun_duration = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("stun_duration")
	self.knockback_radius = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("knockback_radius")

	EmitSoundOn(self.loop_sound, self:GetParent())

    local caster = self:GetCaster()

	if IsServer() then
		
		self.sprint = ParticleManager:CreateParticle(self.sprinting_effect, PATTACH_WORLDORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(self.sprint, 0, self:GetParent():GetAbsOrigin()) 
		self:AddParticle(self.sprint, false, false, -1, true, false)

		self.initial_direction = self:GetParent():GetForwardVector() 
		self.issued_order = false
		self.boosted_turn = true 
		self.boosted_turn_time = 0 

		self:StartIntervalThink(self.tick_interval)
        
        self:GetParent():AddNewModifier(self:GetCaster(), self, "modifier_npc_gyroshell_impact_check", {duration = self:GetDuration() })
		if RollPseudoRandomPercentage(5,DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, caster) then
			EmitSoundOn("pangobabybeep", self:GetParent())
		end

	end
end

function modifier_pangolier_npc_gyroshell_lua:OnIntervalThink()
	ParticleManager:SetParticleControl(self.sprint, 0, self:GetParent():GetAbsOrigin())
end

function modifier_pangolier_npc_gyroshell_lua:OnRemoved()    
	if IsServer() then
		self:GetParent():StopSound(self.loop_sound)
		EmitSoundOn(self.end_sound, self:GetParent())
        self:GetParent():ForceKill( true )
	end
end

function modifier_pangolier_npc_gyroshell_lua:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.sprint, false)
		ParticleManager:ReleaseParticleIndex(self.sprint)
	end
end

function modifier_pangolier_npc_gyroshell_lua:DeclareFunctions()
	local declfuncs = {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
						MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
						MODIFIER_PROPERTY_MODEL_CHANGE,
						MODIFIER_EVENT_ON_ORDER}
	return declfuncs
end 

function modifier_pangolier_npc_gyroshell_lua:GetModifierModelChange()
	return "models/heroes/pangolier/pangolier_gyroshell2.vmdl"
end

function modifier_pangolier_npc_gyroshell_lua:GetOverrideAnimation()
	return ACT_DOTA_OVERRIDE_ABILITY_4
end


--[[---------------------------------------------------------------------
	NPC GYROSHELL IMPACT CHECK MODIFIER
]]------------------------------------------------------------------------

function modifier_npc_gyroshell_impact_check:IsHidden() return true end
function modifier_npc_gyroshell_impact_check:IsPurgable() return false end
function modifier_npc_gyroshell_impact_check:IsDebuff() return false end

function modifier_npc_gyroshell_impact_check:OnCreated()
	if IsServer() then
	
		self.hit_radius = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("hit_radius")
        self.stun_duration = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("stun_duration")
        local caster = self:GetCaster()
		self:StartIntervalThink(0.05)

	end
end

function modifier_npc_gyroshell_impact_check:OnIntervalThink()
	if IsServer() then		
				
		if not self:GetParent():HasModifier("modifier_pangolier_npc_gyroshell_lua") then
			self:Destroy()
		end

		local enemies_hit = 0

		local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
			self:GetParent():GetAbsOrigin(),
			nil,
			self.hit_radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false)

		
		for _,enemy in pairs(enemies) do
			if not enemy:IsMagicImmune() then
				
				if not enemy:HasModifier("modifier_npc_gyroshell_impacted") then
					
					local damage = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("actual_damage")
					if self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_mega_ball") then
						damage = damage * self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_mega_ball"):GetSpecialValueFor("damage_multiplier")
					end	
                    local extra_damage = damage                  

                    local damageTable = {victim = enemy,
                        damage = extra_damage,
                        damage_type = DAMAGE_TYPE_MAGICAL,
                        damage_flags = DOTA_DAMAGE_FLAG_NONE,
                        attacker = self:GetCaster(),
                        ability = self:GetAbility()
                    }
     
                    local knockback =
                    {
                        knockback_duration = 0.5 * (1 - enemy:GetStatusResistance()),
                        duration = 0.5 * (1 - enemy:GetStatusResistance()),
                        knockback_distance = 0,
                        knockback_height = 300,
                    }

                    enemy:RemoveModifierByName("modifier_knockback")
                    enemy:AddNewModifier(self:GetCaster(), self, "modifier_knockback", knockback)
                    enemy:AddNewModifier(self:GetCaster(), self, "modifier_npc_gyroshell_impacted", {duration = self.stun_duration})
                    ApplyDamage(damageTable)
                    EmitSoundOn("Hero_Pangolier.Gyroshell.Carom", self:GetCaster())
					if not self:GetParent():HasModifier("modifier_npc_gyroshell_end") then
						self:GetParent():AddNewModifier(self:GetCaster(), self, "modifier_npc_gyroshell_end", {duration = 0.5})
					end
                        
				end
			end
		end
		
	end
end

--[[---------------------------------------------------------------------
	NPC GYROSHELL IMPACTED MODIFIER
]]------------------------------------------------------------------------


function modifier_npc_gyroshell_impacted:IsHidden() return true end
function modifier_npc_gyroshell_impacted:IsPurgable() return false end
function modifier_npc_gyroshell_impacted:IsDebuff() return false end
function modifier_npc_gyroshell_impacted:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_npc_gyroshell_impacted:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_npc_gyroshell_impacted:CheckState()
	state = {
			[MODIFIER_STATE_STUNNED] = true
			}
	return state
end

--[[---------------------------------------------------------------------
	NPC GYROSHELL END MODIFIER
]]------------------------------------------------------------------------

function modifier_npc_gyroshell_end:IsHidden() return true end
function modifier_npc_gyroshell_end:IsPurgable() return false end
function modifier_npc_gyroshell_end:IsDebuff() return false end

function modifier_npc_gyroshell_end:OnRemoved()    
	if IsServer() then
		self:GetParent():StopSound(self.loop_sound)
        self:GetParent():ForceKill( true )
	end
end