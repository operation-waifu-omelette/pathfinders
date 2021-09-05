LinkLuaModifier("modifier_npc_gyroshell_impact_check", "pathfinder/pangolier/modifier_pangolier_npc_gyroshell_lua", LUA_MODIFIER_MOTION_NONE) 
LinkLuaModifier("modifier_npc_gyroshell_impacted", "pathfinder/pangolier/modifier_pangolier_npc_gyroshell_lua", LUA_MODIFIER_MOTION_NONE) 

modifier_pangolier_npc_gyroshell_lua = modifier_pangolier_npc_gyroshell_lua or class({})


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

function modifier_pangolier_npc_gyroshell_lua:OnCreated()
	-- Ability properties
	self.collision_modifier = "modifier_imba_gyroshell_ricochet"
	self.end_sound = "Hero_Pangolier.Gyroshell.Stop"
	self.sprinting_effect = "particles/units/heroes/hero_pangolier/pangolier_gyroshell.vpcf"
	-- Ability specials
	self.tick_interval = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("tick_interval")
	self.forward_move_speed = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("forward_move_speed")
	self.turn_rate_boosted = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("turn_rate_boosted")
	self.boost_duration = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("turn_rate_boost_duration")
	self.turn_rate = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("turn_rate")
	self.radius = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("radius")
	self.hit_radius = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("hit_radius")
	self.bounce_duration = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("bounce_duration")
	self.stun_duration = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("stun_duration")
	self.knockback_radius = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("knockback_radius")
	self.jump_recover_time = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("jump_recover_time")
	self.pause_duration = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("pause_duration")
    local caster = self:GetCaster()
    print("caster", caster)
    print("hit speed", self.forward_move_speed)

	if IsServer() then
		--Add particles
		self.sprint = ParticleManager:CreateParticle(self.sprinting_effect, PATTACH_WORLDORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(self.sprint, 0, self:GetParent():GetAbsOrigin()) --origin
		self:AddParticle(self.sprint, false, false, -1, true, false)

		--declaring variables
		self.initial_direction = self:GetParent():GetForwardVector() --will be needed to stop turning after pangolier turn 180°
		self.issued_order = false --is pangolier turning?
		self.boosted_turn = true --is pangolier turning faster? (on start, collision, jump)
		self.boosted_turn_time = 0 --will count how many ticks have been passed with boosted turn rate
		--self:GetModifierTurnRate_Percentage() --start with boosted turn rate
		--start modifier interval thinking
		self:StartIntervalThink(self.tick_interval)
        
        self:GetParent():AddNewModifier(self:GetCaster(), self, "modifier_npc_gyroshell_impact_check", {duration = self:GetDuration() })


	end
end
function modifier_pangolier_npc_gyroshell_lua:IsHidden() return false end
function modifier_pangolier_npc_gyroshell_lua:IsPurgable() return false end
function modifier_pangolier_npc_gyroshell_lua:IsDebuff() return false end
function modifier_pangolier_npc_gyroshell_lua:IgnoreTenacity() return true end

function modifier_pangolier_npc_gyroshell_lua:OnIntervalThink()
	
	--center particles on Pangolier
	ParticleManager:SetParticleControl(self.sprint, 0, self:GetParent():GetAbsOrigin())
	-- --check what the turn rate should be
	-- if self.boosted_turn then
	-- 	--return to normal turn rate if boost duration expired
	-- 	if self.boosted_turn_time == self.boost_duration then
	-- 		self.boosted_turn = false
	-- 		self:GetModifierTurnRate_Percentage()
	-- 	end
	-- 	self.boosted_turn_time = self.boosted_turn_time + self.tick_interval
	-- end
	-- --check if we have to stop turning: stop the order once pangolier has turned 180° from the order launch
	-- if (self:GetParent():GetForwardVector() + self.initial_direction) == Vector(0,0,0) then
	-- 	self:GetParent():Interrupt() --stop turning
	-- 	self.issued_order = false
	-- end
	-- --if no orders are issued, Pangolier will move in a straight line
	
	-- self:GetParent():MoveToPosition(self:GetParent():GetAbsOrigin() + self:GetParent():GetForwardVector() * 100)
	
	-- --destroys nearby trees
	-- GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), self.radius, false)
	-- self:HorizontalMotion(self:GetParent(), self.tick_interval)
	-- -- Check Motion controllers
	
	-- -- Horizontal motion, don't move if Pangolier has just bounced
	-- if not self:GetParent():HasModifier(self.collision_modifier) then
	-- 	self:HorizontalMotion(self:GetParent(), self.tick_interval)
	-- end
end

-- function modifier_pangolier_npc_gyroshell_lua:HorizontalMotion(me, dt)
-- 	if IsServer() then
-- 			-- Go forward, check if Pangolier is going to collide with impassable terrain
-- 			local expected_location = self:GetParent():GetAbsOrigin() + self:GetParent():GetForwardVector() * self.forward_move_speed * dt
-- 			local isTraversable = GridNav:IsTraversable(expected_location)
				
-- 			self:GetParent():SetForwardVector(self:GetParent():GetForwardVector() * (-1))
-- 			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), self.collision_modifier, {duration = self.pause_duration})
-- 	end 
-- end

function modifier_pangolier_npc_gyroshell_lua:OnRemoved()    
	if IsServer() then
		--self:GetParent():SetUnitOnClearGround()
		self:GetParent():StopSound(self.loop_sound)
		EmitSoundOn(self.end_sound, self:GetParent())
        self:GetParent():ForceKill( true )

	end
end

function modifier_pangolier_npc_gyroshell_lua:OnDestroy()
	if IsServer() then
		--release particle index
		ParticleManager:DestroyParticle(self.sprint, false)
		ParticleManager:ReleaseParticleIndex(self.sprint)
	end
end

function modifier_pangolier_npc_gyroshell_lua:DeclareFunctions()
	local declfuncs = {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
						MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
						MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
						MODIFIER_PROPERTY_MODEL_CHANGE,
						MODIFIER_EVENT_ON_ORDER}
	return declfuncs
end 

-- -- function modifier_pangolier_npc_gyroshell_lua:OnOrder(keys)
-- -- 	if IsServer() then
-- -- 		--filter orders
-- -- 		if keys.unit == self:GetParent() then
-- -- 		local order_type = keys.order_type	
-- -- 		-- On any movement order, track the initial direction of Pangolier
-- -- 		if order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET 
-- -- 		or order_type == DOTA_UNIT_ORDER_ATTACK_MOVE or order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
-- -- 			self.initial_direction = self:GetParent():GetForwardVector()
-- -- 			self.issued_order = true
-- -- 		end
-- -- 	end
-- -- 	end
-- -- end

-- --Fixed movement speed. Motion controller will handle the movement
-- function modifier_pangolier_npc_gyroshell_lua:GetModifierMoveSpeed_Absolute()
-- 	return 1 
-- end

-- function modifier_pangolier_npc_gyroshell_lua:GetModifierTurnRate_Percentage()
-- 	if IsServer() then
-- 		local base_tr = 1.0 --HARDCODED because fucking volvo can't provide a simple function -.-
-- 		--calculating turn rates
-- 		--converting from degrees/second to radians/second
-- 		local tr_per_sec_in_radians = (self.turn_rate * math.pi) / 180
-- 		local boosted_tr_per_sec_in_radians = (self.turn_rate_boosted * math.pi) / 180 
-- 		--converting from radians/second to radians/0.03s (actual turn rate)
-- 		local tr_in_radians = tr_per_sec_in_radians * 0.03
-- 		local boosted_tr_in_radians = boosted_tr_per_sec_in_radians * 0.03
-- 		--calculating percentage needed to achieve the desired turn rates
-- 		local tr_percentage = 100 - ((100 * tr_in_radians) / base_tr )
-- 		local boosted_tr_percentage = 100 - ((100 * (tr_in_radians + boosted_tr_in_radians)) / base_tr)
-- 		if self.boosted_turn then
-- 			return boosted_tr_percentage * (-1)
-- 		end
-- 		return tr_percentage * (-1)
-- 	end
-- end

function modifier_pangolier_npc_gyroshell_lua:GetModifierModelChange()
	return "models/heroes/pangolier/pangolier_gyroshell2.vmdl"
end

function modifier_pangolier_npc_gyroshell_lua:GetOverrideAnimation()
	return ACT_DOTA_OVERRIDE_ABILITY_4
end




--Collision modifier: will disable Rolling Thunder motion controllers while it's active
-- modifier_imba_gyroshell_ricochet = modifier_imba_gyroshell_ricochet or class({})

-- function modifier_imba_gyroshell_ricochet:OnCreated()
-- 	--Ability properties
-- 	self.gyroshell = "modifier_pangolier_npc_gyroshell_lua"
-- 	self.bounce_sound = "Hero_Pangolier.Gyroshell.Carom"
-- 	--play the bounce sound
-- 	EmitSoundOn(self.bounce_sound, self:GetParent())
-- 	--play the bounce animation
-- 	self:GetParent():StartGesture(ACT_DOTA_FLAIL)
-- end
-- function modifier_imba_gyroshell_ricochet:OnDestroy()
-- 	--boost rolling thunder turn rate
-- 	local gyroshell_handler = self:GetParent():FindModifierByName(self.gyroshell)
-- 	if gyroshell_handler then
-- 		gyroshell_handler.boosted_turn = true
-- 		gyroshell_handler.boosted_turn_time = 0
-- 		gyroshell_handler:GetModifierTurnRate_Percentage()
-- 	end
-- end
-- function modifier_imba_gyroshell_ricochet:IsHidden() return true end
-- function modifier_imba_gyroshell_ricochet:IsPurgable() return true end
-- function modifier_imba_gyroshell_ricochet:IsDebuff() return false end





-- Impact checker, will extend Rolling Thunder duration on each hero hit will also hadle the targets and damage for Talent #7
modifier_npc_gyroshell_impact_check = modifier_npc_gyroshell_impact_check or class({})


function modifier_npc_gyroshell_impact_check:IsHidden() return false end
function modifier_npc_gyroshell_impact_check:IsPurgable() return false end
function modifier_npc_gyroshell_impact_check:IsDebuff() return false end

function modifier_npc_gyroshell_impact_check:OnCreated()
	if IsServer() then
		--Ability Specials
		self.hit_radius = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("hit_radius")
        self.stun_duration = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("stun_duration")
        local caster = self:GetCaster()
        print("caster", caster)
        print("hit radius", self.hit_radius)
		-- Increase think time so the talent damage hopefully doesn't stack in one instance
		self:StartIntervalThink(0.05)
	end
end

function modifier_npc_gyroshell_impact_check:OnIntervalThink()
	if IsServer() then		
		
		--If pangolier stopped rolling, remove this modifier
		if not self:GetParent():HasModifier("modifier_pangolier_npc_gyroshell_lua") then
			self:Destroy()
		end

		local enemies_hit = 0

		-- Find all enemies in AoE
		local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
			self:GetParent():GetAbsOrigin(),
			nil,
			self.hit_radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false)

		-- Check how many targets are valid (not impacted recently)
		for _,enemy in pairs(enemies) do
			if not enemy:IsMagicImmune() then
				--Is he affected by a previous impact? if so, ignore it
				if not enemy:HasModifier("modifier_npc_gyroshell_impacted") then
					
                    local extra_damage = self:GetCaster():FindAbilityByName("pangolier_rolling_thunder_lua"):GetSpecialValueFor("actual_damage")
                   

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
                    if enemy:GetHealth() <= 0  then
                        EmitSoundOn("Hero_Pangolier.Gyroshell.Carom", self:GetCaster())
                    end
                        
				end
			end
		end
		
	end
end

modifier_npc_gyroshell_impacted = modifier_npc_gyroshell_impacted or class({})
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



