
--------------------------------------------------------------------------------
modifier_pathfinder_patron_lvl4 = class({})
function modifier_pathfinder_patron_lvl4:IsHidden()
	return false
end

function modifier_pathfinder_patron_lvl4:OnCreated(table)
	if IsServer() then
		if table.goldnum then 
			self.goldnum = table.goldnum
			self:SetHasCustomTransmitterData( true )
		else
			self.goldnum = 1
		end
	end
end

function modifier_pathfinder_patron_lvl4:AddCustomTransmitterData( )
	return
	{
		goldnum = self.goldnum,
	}
end

function modifier_pathfinder_patron_lvl4:HandleCustomTransmitterData( data )
	self.goldnum = data.goldnum
end



function modifier_pathfinder_patron_lvl4:IsDebuff()
	return false
end

function modifier_pathfinder_patron_lvl4:IsPurgable()
	return false
end

function modifier_pathfinder_patron_lvl4:RemoveOnDeath()
	return false
end

function modifier_pathfinder_patron_lvl4:GetTexture()
	return "ability_capture"
end

function modifier_pathfinder_patron_lvl4:GetStatusEffectName()
	local status = {
		"particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_gold_lvl2.vpcf", 
		"particles/econ/items/lifestealer/lifestealer_immortal_backbone/status_effect_life_stealer_immortal_rage.vpcf", --blood rage
		"particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_wm16_dire_lvl3.vpcf", --black gold
		"particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_wm16_radiant.vpcf", --room temp ice
		"particles/econ/items/effigies/status_fx_effigies/status_effect_statue_compendium_2014_dire.vpcf", -- volcanic black
		"particles/status_fx/status_effect_snapfire_magma.vpcf", --animated ember
		"particles/status_fx/status_effect_grimstroke_ink_over.vpcf", --black ink
		"particles/status_fx/status_effect_maledict.vpcf", --maledict cherry
		"particles/econ/courier/courier_trail_05/courier_trail_05.vpcf", --spotlight
	}												
	return status[self.goldnum]
end

function modifier_pathfinder_patron_lvl4:StatusEffectPriority()	
	return MODIFIER_PRIORITY_SUPER_ULTRA + 10000		
end

modifier_pathfinder_patron = class({})
LinkLuaModifier( "modifier_pathfinder_patron_lvl4", "pathfinder/modifier_pathfinder_patron", LUA_MODIFIER_MOTION_NONE )
require("constants")
require("libraries.has_shard")
--------------------------------------------------------------------------------
-- Classifications
function modifier_pathfinder_patron:IsHidden()
	return false
end

function modifier_pathfinder_patron:GetTexture()
	return "buyback"
end

function modifier_pathfinder_patron:IsDebuff()
	return false
end

function modifier_pathfinder_patron:IsPurgable()
	return false
end

function modifier_pathfinder_patron:RemoveOnDeath()
	return false
end


-- Initializations
function modifier_pathfinder_patron:OnCreated( kv )
	-- references
	if not IsServer() then return end	
	local particles = patron_particles
	if not particles then return end
	self.particle = nil	
	
	self.pfx1 = nil
	self.pfx2 = nil
	self.pfx3 = nil
	self.pfx4 = nil
	self.patron_effect = nil

	self.sparkle = particles[1]		
	self.gold = particles[2]
	-- self.fairies = particles[3] unused

	local playerID = PlayerResource:GetSteamID(self:GetParent():GetPlayerOwnerID())
	
	if not playerID then return end
	playerID = tostring(playerID)	

	for id,table in pairs(patron_id) do		
		if patron_id and playerID and playerID == id then		
			self.pfx1 = ParticleManager:CreateParticle(self.sparkle, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )

			if table.golden > 0 then
				self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_pathfinder_patron_lvl4", {goldnum = table.golden})						
			end

			if table.tier > 1 then

				-- if  id ~= "76561198073588617" then --exclude friday	
					self.pfx2 = ParticleManager:CreateParticle( self.gold, PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent() );
					self.pfx3 = ParticleManager:CreateParticle( self.gold, PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent() );
					self.pfx4 = ParticleManager:CreateParticle( self.gold, PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent() );
										
					ParticleManager:SetParticleControlEnt( self.pfx2, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true )	
					ParticleManager:SetParticleControlEnt( self.pfx2, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true )	
					ParticleManager:SetParticleControlEnt( self.pfx3, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetParent():GetAbsOrigin(), true )					
					ParticleManager:SetParticleControlEnt( self.pfx4, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )			
					ParticleManager:SetParticleControlEnt( self.pfx4, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
				-- end				
			end

			if table.tier > 2  or  id == "76561198073588617" then-- and id ~= "76561198073588617" then
				self.patron_effect = ParticleManager:CreateParticle( table.trail, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() ) 	
				ParticleManager:SetParticleControl( self.patron_effect, 0, self:GetParent():GetAbsOrigin() )		
			end				
		end
	end
end

function modifier_pathfinder_patron:OnRefresh( kv )
	if self.pfx1 then
		ParticleManager:DestroyParticle(self.pfx1,false)
		ParticleManager:ReleaseParticleIndex(self.pfx1)
	end
	if self.pfx2 then
		ParticleManager:DestroyParticle(self.pfx2,false)
		ParticleManager:ReleaseParticleIndex(self.pfx2)
	end
	if self.pfx3 then
		ParticleManager:DestroyParticle(self.pfx3,false)
		ParticleManager:ReleaseParticleIndex(self.pfx3)
	end
	if self.pfx4 then
		ParticleManager:DestroyParticle(self.pfx4,false)
		ParticleManager:ReleaseParticleIndex(self.pfx4)
	end
	if self.patron_effect then
		ParticleManager:DestroyParticle(self.patron_effect,false)
		ParticleManager:ReleaseParticleIndex(self.patron_effect)
	end
	self:OnCreated()
end


function modifier_pathfinder_patron:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

function modifier_pathfinder_patron:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

-- function modifier_pathfinder_patron:GetEffectName()
-- 	if self.particle then
-- 		return self.particle
-- 	end
-- end

-- function modifier_pathfinder_patron:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end