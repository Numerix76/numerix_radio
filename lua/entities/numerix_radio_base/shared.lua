--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]

ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Radio Base"
ENT.Category		= "Numerix Scripts"
ENT.Author			= "Numerix"
ENT.Contact			= "https://steamcommunity.com/id/numerix/"
ENT.Purpose			= ""
ENT.Instructions	= ""					
ENT.Spawnable 		= false
ENT.IsAdmin			= false

function ENT:SetupDataTables()
	self:InitRadio()
end

function ENT:Think()
	self:ThinkRadio()
end