--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]
hook.Add("OnEntityCreated", "Radio:OnVehiculeCreate", function(ent)
	if Radio.IsCar(ent) and Radio.Settings.VehicleSpawnRadio then
		local radio = ents.Create("numerix_radio_component")
		radio:SetMaxDistanceSound( Radio.Settings.DistanceSoundRadio^2 )
		radio:SetServer(false)
		radio:Spawn()

		ent:SetRadioComponent(radio)

		ent.SpawnedWithRadio = true
	end
end)

hook.Add("canDropWeapon", "Radio:canDropWeapon", function(ply, ent)
	if ent:GetRadioComponent() then return false end
end)

hook.Add( "PlayerCanHearPlayersVoice", "Radio:CanPlayerHearRadioVoice", function( listener, talker ) 
	for _, radio in ipairs(ents.FindByClass("numerix_radio_component")) do
		if ( !radio:IsConnectedToServer() ) then continue end

		local controller = radio:GetController()
		if ( radio:CanHear(listener) and talker:GetPos():DistToSqr( controller:GetParent():GetPos() ) < 200^2 and controller:IsVoiceEnabled() ) then
			return true, false
		end
	end
end)

hook.Add( "playerGetSalary", "Radio:AnimSalary", function(ply, amount)
    if Radio.Settings.MakeSalary then
        if ply:Team() == Radio.Settings.TeamRadio then
            local total = 0
            for _, radio in ipairs(ents.FindByClass("numerix_radio_component")) do
				if !radio:IsServer() then continue end
                if radio:GetParent():GetOwner() != ply then continue end
				
                total = total + ent:GetListeners()*Radio.Settings.Salary
            end

            return false, DarkRP.getPhrase("payday_message", amount).." (+"..DarkRP.formatMoney(total)..")", total+amount
        end
    end
end)


hook.Add("PlayerLeaveVehicle", "Radio:LeaveCar", function(ply, veh)
	if ( !ply:HasWeapon("numerix_radio_swep") ) then return end

	local weapon = ply:GetWeapon("numerix_radio_swep")
	local isActive = ply:GetActiveWeapon() == weapon

	local radio = weapon:GetRadioComponent()
	radio:SetParent(nil) -- We detach to avoid delete when removing the old weapon
	ply:StripWeapon("numerix_radio_swep")

	weapon = ply:Give("numerix_radio_swep")
	weapon:SetRadioComponent(radio)

	if ( isActive ) then
		timer.Simple(0.01, function()
			ply:SelectWeapon(weapon)
		end)
	end
end)