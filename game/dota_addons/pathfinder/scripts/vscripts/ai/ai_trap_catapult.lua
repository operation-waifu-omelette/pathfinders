--[[
Catapult AI
]]

function Spawn( entityKeyValues )
	if IsServer() == false then
		return
	end
	thisEntity:SetContextThink( "CatapultAIThink", CatapultAIThink, 0.25 )

	thisEntity.hEntityKilledGameEvent = ListenToGameEvent( "entity_killed", Dynamic_Wrap( thisEntity:GetPrivateScriptScope(), 'OnEntityKilled' ), nil )
end

function UpdateOnRemove()
	StopListeningToGameEvent( thisEntity.hEntityKilledGameEvent )
end

function Precache( context )
	PrecacheResource( "particle", "particles/creatures/catapult/catapult_projectile.vpcf", context )
	PrecacheResource( "particle", "particles/siege_fx/siege_bad_death_01.vpcf", context )
end


function CatapultAIThink()
	if IsServer() == false then
		return
	end

	IgniteAbility = thisEntity:FindAbilityByName( "pathfinder_trap_catapult_ignite" )

	-- Get the current time
	local currentTime = GameRules:GetGameTime()
	local enemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 8000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false )
	if #enemies == 0 then
		return 1
	end


	local bIgniteReady = ( #enemies > 0 and IgniteAbility ~= nil and IgniteAbility:IsFullyCastable() )	
	

	if bIgniteReady then
		local chosen = nil
		for _,enemy in pairs(enemies) do			
			if (enemy:GetAbsOrigin() - thisEntity:GetAbsOrigin()):Length2D() > 600 then
				chosen = enemy
				break
			end
		end
		if chosen then
			return IgniteArea( chosen )
		end
	end

	return 1.0
end

function IgniteArea( hEnemy )
	--print( "Casting ignite on " .. hEnemy:GetUnitName() )

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = IgniteAbility:entindex(),
		Position = hEnemy:GetOrigin(),
		Queue = false,
	})

	return 0.55
end


function OnEntityKilled( event )
	local hVictim = nil
	if event.entindex_killed ~= nil then
		hVictim = EntIndexToHScript( event.entindex_killed )
	end

	if hVictim ~= thisEntity then
		return
	end

	EmitSoundOn( "Creep_Siege_Dire.Destruction", hVictim )

	hVictim:AddEffects( EF_NODRAW )

	local nFXIndex = ParticleManager:CreateParticle( "particles/siege_fx/siege_good_death_01.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControlEnt( nFXIndex, 0, hVictim, PATTACH_ABSORIGIN, nil, hVictim:GetOrigin(), true )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
end
