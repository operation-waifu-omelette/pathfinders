

--------------------------------------------------------------------------------
modifier_dummy = class({})
function modifier_dummy:RemoveOnDeath(  )
-- True/false if this modifier is removed when the parent dies.
	return false
end
