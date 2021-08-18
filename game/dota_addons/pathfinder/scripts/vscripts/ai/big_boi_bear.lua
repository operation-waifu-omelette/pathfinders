--[[ Smol Bear AI ]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity.vNagaPosition = nil
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
    behaviorSystem = AICore:CreateBehaviorSystem( thisEntity, { BehaviorNone, BehaviorSlam, BehaviorRage} )
end

function AIThink() -- For some reason AddThinkToEnt doesn't accept member functions
	return behaviorSystem:Think( )
end

--------------------------------------------------------------------------------------------------------

BehaviorNone = {}

function BehaviorNone:Evaluate()
	return 1 -- must return a value > 0, so we have a default
end

function BehaviorNone:Begin()

	local orders = nil
	local hTarget = AICore:ClosestEnemyHeroInRange( thisEntity, thisEntity:GetDayTimeVisionRange() )
	if hTarget ~= nil then
		thisEntity.lastTargetPosition = hTarget:GetAbsOrigin()
		hTarget:MakeVisibleDueToAttack( DOTA_TEAM_BADGUYS, 100 )
		orders =
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = hTarget:entindex()
		}
	elseif thisEntity.lastTargetPosition ~= nil then
		orders =
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			Position = thisEntity.lastTargetPosition
		}
	else
		orders =
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_STOP
		}
	end

	return orders
end

BehaviorNone.Continue = BehaviorNone.Begin

--------------------------------------------------------------------------------------------------------

BehaviorSlam = {}

function BehaviorSlam:Evaluate()
	--print( "BehaviorSlam:Evaluate()" )
	local desire = 0

	self.SlamAbility = thisEntity:FindAbilityByName( "big_boi_slam" )
	if self.SlamAbility and self.SlamAbility:IsFullyCastable() then
		local nRange = 1000
		local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, nRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS, 0, false )
		for _,enemy in pairs(enemies) do
			local enemyVec = enemy:GetOrigin() - thisEntity:GetOrigin()	

			local distance = enemyVec:Length2D()
			if distance < 800 then
				--print( "Slam range valid" )
				desire = 8
				self.target = enemy
			end
			
		end
	end

	return desire
end

function BehaviorSlam:Begin()
	--print( "BehaviorSlam:Begin()" )

	if self.target and self.target:IsAlive() then
		if self.SlamAbility and self.SlamAbility:IsFullyCastable() then
			--print( "Casting Star Fall" )
			local order =
			{
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = self.SlamAbility:entindex(),
				Queue = false,
			}
			return order
		end
	end

	return nil
end

BehaviorSlam.Continue = BehaviorSlam.Begin


--------------------------------------------------------------------------------------------------------

BehaviorRage = {}

function BehaviorRage:Evaluate()
	--print( "BehaviorRage:Evaluate()" )
	local desire = 0

	self.RageAbility = thisEntity:FindAbilityByName( "big_boi_rage" )
	if self.RageAbility and self.RageAbility:IsFullyCastable() then		
		local babies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, 3200, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NO_INVIS, 0, false )
		if #babies <= 12 then			
			return 100
		end
	end

	return desire
end

function BehaviorRage:Begin()
	--print( "BehaviorRage:Begin()" )
	if self.RageAbility and self.RageAbility:IsFullyCastable() then
		--print( "Casting Star Fall" )
		local order =
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
			AbilityIndex = self.RageAbility:entindex(),
			Queue = false,
		}
		return order
	end
	return nil
end

BehaviorRage.Continue = BehaviorRage.Begin

-------------------------------------------------------

AICore.possibleBehaviors = { BehaviorNone, BehaviorSlam, BehaviorRage }
