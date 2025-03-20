--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]

local ENT = FindMetaTable("Entity")

function ENT:GetRadioComponent()
	local children = self:GetChildren()

	for k, v in ipairs(children) do
		if ( v:GetClass() == "numerix_radio_component" ) then
			return v
		end
	end

	return nil
end

local PLAYER = FindMetaTable("Player")

Radio.Chat.INFO = 1
Radio.Chat.SUCCESS = 2
Radio.Chat.ERROR = 3

function PLAYER:RadioChatInfo(msg, type)
	if SERVER then
		if type == Radio.Chat.INFO then
			self:SendLua("chat.AddText(Color( 225, 20, 30 ), [[[Radio] : ]] , Color( 0, 165, 225 ), [["..msg.."]])")
		elseif type == Radio.Chat.SUCCESS then
			self:SendLua("chat.AddText(Color( 225, 20, 30 ), [[[Radio] : ]] , Color( 180, 225, 197 ), [["..msg.."]])")
		else
			self:SendLua("chat.AddText(Color( 225, 20, 30 ), [[[Radio] : ]] , Color( 225, 20, 30 ), [["..msg.."]])")
		end
	end

	if CLIENT then
		if type == 1 then
			chat.AddText(Color( 225, 20, 30 ), [[[Radio] : ]] , Color( 0, 165, 225 ), msg)
		elseif type == 2 then
			chat.AddText(Color( 225, 20, 30 ), [[[Radio] : ]] , Color( 180, 225, 197 ), msg)
		else
			chat.AddText(Color( 225, 20, 30 ), [[[Radio] : ]] , Color( 225, 20, 30 ), msg)
		end
	end
end


local cachedIsCarResult = {}
function Radio.IsCar(ent)
	if !IsValid(ent) then return false end

	local result = function()
		if ( cachedIsCarResult[ent] != nil ) then return cachedIsCarResult[ent] end

		if IsValid(ent:GetParent()) then return false end --The ent is a part of a vehicle
	
		if ent:IsVehicle() then return true end
		if simfphys and simfphys.IsCar and simfphys.IsCar(ent) then return true end
		if ent:GetClass() == "prop_vehicle_jeep" then return true end
		if scripted_ents.IsBasedOn(ent:GetClass(), "wac_hc_base") then return true end
		
		local isCar = hook.Call("Radio:IsCar", nil, ent)
		if isCar != nil then return isCar end

		return false
	end

	cachedIsCarResult[ent] = result()
	
	return cachedIsCarResult[ent]
end

function Radio.CanEdit(ply, ent)
	if !IsValid(ent) then return false end
	if !ply:Alive() then return false end
	
	local isCar = Radio.IsCar(ent);
	local radio = ent:GetRadioComponent()

	local maxDistance = isCar and 22500 or 100000

	local canEdit = hook.Call("Radio:CanEdit", nil, ply, ent)
	if canEdit == false then return false end

	if ply:GetPos():DistToSqr(ent:GetPos()) > maxDistance then return false end

	if ( radio:IsPrivate() or radio:IsPrivateBuddy() ) then
		if isCar then
			if !Radio.IsCarOwner(ply, ent) then return false end
		end
	
		if radio then
			--Check property with FPP
			local owner = ent.FPPOwner or ent.Owner
			if FPP and radio:IsPrivate() and ( (radio:IsPrivateBuddy() and !ent:CPPICanUse(ply)) or (!radio:IsPrivateBuddy() and owner != ply) ) then return false end
		end
	end

	return true
end

function Radio.IsCarOwner(ply, ent)
	if !IsValid(ply) then return false end
	if !IsValid(ent) then return false end

	if !Radio.IsCar(ent) then return false end

	if DarkRP and ent:getDoorOwner() != nil and !ply:canKeysLock(ent) and !scripted_ents.IsBasedOn(ent:GetClass(), "wac_hc_base") then return false end
	if FPP and !ent:CPPICanUse(ply) then return false end
	
	return true
end

function Radio.IsCarHaveRadio(ent)
	if ( !Radio.IsCar(ent) ) then return false end
	if ( !ent:GetRadioComponent() ) then return false end

	return true
end