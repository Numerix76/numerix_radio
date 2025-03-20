--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]
local alreadystart
hook.Add( "PlayerButtonDown", "Radio:KeyPressVehicle", function(ply, button)
	if input.IsKeyDown(GetConVar("radio_open_menu"):GetInt()) and !alreadystart then
		alreadystart = true

		timer.Simple(0.5, function()
			alreadystart = false
		end)
	
		if IsValid( ply ) and ply:InVehicle() then
			local plyvehicle = ply:GetVehicle()
			local vehicle = IsValid(plyvehicle:GetParent()) and plyvehicle:GetParent() or plyvehicle

			if Radio.IsCarHaveRadio(vehicle) then
				Radio.OpenStreamMenu(vehicle)
			else
				ply:RadioChatInfo(Radio.GetLanguage("Please install a radio in the vehicle."), Radio.Chat.INFO)                  
			end
		end
	end

	if input.IsKeyDown(GetConVar("radio_retrieve"):GetInt()) and !alreadystart then
		alreadystart = true

		timer.Simple(0.5, function()
			alreadystart = false
		end)

		if IsValid( ply ) and !ply:InVehicle() then
            local tr = util.TraceLine(util.GetPlayerTrace( ply ))
            if IsValid(tr.Entity) and Radio.IsCar(tr.Entity) then 
				net.Start("Radio:RetrieveFromVehicle")
				net.WriteEntity(tr.Entity)
                net.SendToServer()
            end
        end
    end
end)

local radio_open_menu = CreateClientConVar( "radio_open_menu", KEY_M )
local radio_retrieve = CreateClientConVar( "radio_retrieve", KEY_K )

hook.Add( "AddToolMenuCategories", "Radio:MakeCategoryOption", function()
	spawnmenu.AddToolCategory( "Options", "Radio", "Radio" )
end)

hook.Add( "PopulateToolMenu", "Radio:MakeOptions", function()
	spawnmenu.AddToolMenuOption( "Options", "Radio", "Radio_Numerix_Config", "Config", "", "", function( panel )
		panel:SetName("Radio Config")
		panel:AddControl("Numpad", {
			Label = Radio.GetLanguage("Open menu in car"),
			Command = "radio_open_menu"
		})

		panel:AddControl("Numpad", {
			Label = Radio.GetLanguage("Take the radio in the car"),
			Command = "radio_retrieve"
		})
	end )
end )