--[[ Smol Bear AI ]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity.vNagaPosition = nil
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
    behaviorSystem = AICore:CreateBehaviorSystem( thisEntity, { BehaviorNone, BehaviorHop} )
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

BehaviorHop = {}

function BehaviorHop:Evaluate()
	--print( "BehaviorHop:Evaluate()" )
	local desire = 0

	self.HopAbility = thisEntity:FindAbilityByName( "smol_bear_hop" )
	if self.HopAbility and self.HopAbility:IsFullyCastable() then
		local nRange = 1200
		local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, nRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS, 0, false )
		for _,enemy in pairs(enemies) do
			local enemyVec = enemy:GetOrigin() - thisEntity:GetOrigin()
			local myForward = thisEntity:GetForwardVector()			

			local distance = enemyVec:Length2D()
			if distance < 1000 then
				--print( "hop range valid" )
				desire = 100
				self.target = enemy
			end
			
		end
	end

	return desire
end

function BehaviorHop:Begin()
	--print( "BehaviorHop:Begin()" )

	if self.target and self.target:IsAlive() then
		if self.HopAbility and self.HopAbility:IsFullyCastable() then
			--print( "Casting Star Fall" )
			local order =
			{
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = self.HopAbility:entindex(),
				Queue = false,
			}
			return order
		end
	end

	return nil
end

BehaviorHop.Continue = BehaviorHop.Begin


--------------------------------------------------------------------------------------------------------

AICore.possibleBehaviors = { BehaviorNone, BehaviorHop }
