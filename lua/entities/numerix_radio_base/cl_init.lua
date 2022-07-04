--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]

include("shared.lua")

function ENT:OnRemove()
	self:StopMusicRadio()
end