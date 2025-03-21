--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]

ENT.Type            = "anim"
ENT.Base            = "numerix_radio_base"
 
ENT.PrintName       = "Radio Admin"
ENT.Category        = "Numerix Scripts"
ENT.Author          = "Numerix"
ENT.Contact         = "https://steamcommunity.com/id/numerix/"
ENT.Purpose         = ""
ENT.Instructions	= ""
ENT.Spawnable       = true
ENT.Admin           = true

ENT.Model           = "models/props_lab/servers.mdl"
ENT.IsServer        = true

function ENT:GetDefaultDistanceSound()
	return -1
end