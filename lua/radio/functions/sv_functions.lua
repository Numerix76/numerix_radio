--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]

local ENT = FindMetaTable("Entity")

function ENT:SetRadioComponent(radio)
	local oldRadio = self:GetRadioComponent()
	if ( oldRadio ) then
		oldRadio:Remove()
	end

	radio:SetParent(self)
end