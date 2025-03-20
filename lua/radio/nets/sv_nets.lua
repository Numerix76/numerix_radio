--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]

util.AddNetworkString("Radio:OpenStreamMenu")


util.AddNetworkString("Radio:StopMusic")
local function StopMusic(len, ply)
	if !ply:IsValid() then return end
	local ent = net.ReadEntity()

	if !ent:IsValid() then return end
	local radio = ent:GetRadioComponent()
	if !radio then return end

	if !Radio.CanEdit(ply, ent) then return end
	
	if radio:Stop() then
		hook.Call("Radio:PlayerStopMusic", nil, ply, self)
		ServerLog(string.format("[Radio] %s (%s) has stopped the music.\n", ply:Name(), ply:SteamID()))
	end
end
net.Receive("Radio:StopMusic", StopMusic)

util.AddNetworkString("Radio:UpdateVolume")
local function UpdateVolume(len, ply)
	if !ply:IsValid() then return end
	local ent = net.ReadEntity()
	local volume = net.ReadUInt(7)
 
	if !ent:IsValid() then return end
	local radio = ent:GetRadioComponent()
	if !radio then return end

	if !Radio.CanEdit(ply, ent) then return end 

	volume = math.Clamp(volume, 0, 100)
	radio:SetVolume(volume)

	hook.Call("Radio:PlayerUpdateVolume", nil, ply, ent, volume)
	ServerLog(string.format("[Radio] %s (%s) has changed the volume to %d.\n", ply:Name(), ply:SteamID(), volume))
end
net.Receive("Radio:UpdateVolume", UpdateVolume)

util.AddNetworkString("Radio:SetMusic")
local function SetMusic(len, ply)
	if !ply:IsValid() then return end
	local ent = net.ReadEntity()
	local url = net.ReadString()

	if !ent:IsValid() then return end
	local radio = ent:GetRadioComponent()
	if !radio then return end

	if !Radio.CanEdit(ply, ent) then return end 
	if radio:IsLoading() then ply:RadioChatInfo(Radio.GetLanguage("Please wait the end of last loading"), Radio.Chat.ERROR) return end
	if ( (radio:IsServer() and Radio.Settings.ActivePresetOnlyServer) or ( !radio:IsServer() and Radio.Settings.ActivePresetOnlyRadio ) ) and !Radio.Settings.Preset[url] then return end

	radio:Play(url, ply)

	hook.Call("Radio:PlayerSetMusic", nil, ply, ent, url)
	ServerLog(string.format("[Radio] %s (%s) has changed the music for '%s'.\n", ply:Name(), ply:SteamID(), url))
end
net.Receive("Radio:SetMusic", SetMusic)

util.AddNetworkString("Radio:PauseMusic")
local function PauseMusic(len, ply)
	if !ply:IsValid() then return end
	local ent = net.ReadEntity()
	local pause = net.ReadBool()

	if !ent:IsValid() then return end
	local radio = ent:GetRadioComponent()
	if !radio then return end

	if !Radio.CanEdit(ply, ent) then return end 

	if pause then
		radio:Pause()
	else
		radio:Resume()
	end

	hook.Call("Radio:PlayerPauseMusic", nil, ply, ent, pause)
	ServerLog(string.format("[Radio] %s (%s) has %s the music.\n", ply:Name(), ply:SteamID(), pause and "paused" or "resumed"))
end
net.Receive("Radio:PauseMusic", PauseMusic)

util.AddNetworkString("Radio:SeekMusic")
local function SeekMusic(len, ply)
	if !Radio.Settings.Seek then return end

	if !ply:IsValid() then return end
	local ent = net.ReadEntity()
	local time = net.ReadFloat()
	
	if !ent:IsValid() then return end
	local radio = ent:GetRadioComponent()
	if !radio then return end

	if !Radio.CanEdit(ply, ent) then return end 

	radio:SetCurrentTime(time)

	hook.Call("Radio:PlayerSeekMusic", nil, ply, ent, time)
	ServerLog(string.format("[Radio] %s (%s) has seeked the music.\n", ply:Name(), ply:SteamID()))
end
net.Receive("Radio:SeekMusic", SeekMusic)

util.AddNetworkString("Radio:Take")
local function TakeRadio(len, ply)
	if !Radio.Settings.EnableSWEP then return end
	if !ply:IsValid() then return end
	local ent = net.ReadEntity()

	if !ent:IsValid() then return end
	if ent:GetClass() != "numerix_radio" then return end

	if ply:HasWeapon("numerix_radio_swep") then return end

	local radio = ent:GetRadioComponent()
	if !radio then return end

	if !Radio.CanEdit(ply, ent) then return end 

	radio:SetColor(ent:GetColor())
	ent:Remove()

	local weapon = ply:Give("numerix_radio_swep")
	weapon:SetRadioComponent(radio)

	ply:SelectWeapon(weapon)
end
net.Receive("Radio:Take", TakeRadio)

util.AddNetworkString("Radio:ConnectRadio")
local function ConnectRadio(len, ply)
	if !ply:IsValid() then return end

	local ent = net.ReadEntity()
	local server = net.ReadEntity() or nil

	if !ent:IsValid() then return end
	local radio = ent:GetRadioComponent()
	if !radio then return end

	local serverRadio = nil 
	if IsValid(server) then
		serverRadio = server:GetRadioComponent()
		if ( !serverRadio ) then return end
	end

	if !Radio.CanEdit(ply, ent) then return end 

	if radio:IsLoading() then ply:RadioChatInfo(Radio.GetLanguage("Please wait the end of last loading"), Radio.Chat.ERROR) return end

	
	if ( server == radio:GetController() ) then return end

	local oldServer = radio:GetController()

	radio:SetController(serverRadio)

	if ( oldServer != nil ) then
		hook.Call("Radio:DisconnectRadio", nil, ply, ent, oldServer)
	end

	if ( serverRadio != nil ) then
		hook.Call("Radio:ConnectRadio", nil, ply, ent, server)
	end
end
net.Receive("Radio:ConnectRadio", ConnectRadio)

util.AddNetworkString("Radio:SetNameServer") 
local function SetNameServer(len, ply)
	if !ply:IsValid() then return end

	local ent = net.ReadEntity()
	local name = net.ReadString()

	if !ent:IsValid() then return end
	local radio = ent:GetRadioComponent()
	if !radio then return end

	if !Radio.CanEdit(ply, ent) then return end 

	radio:SetServerName(name)

	hook.Call("Radio:SetNameServer", nil, ply, ent, name)
end
net.Receive("Radio:SetNameServer", SetNameServer)

util.AddNetworkString("Radio:TransmitVoice")
local function TransmitVoice(len, ply)
	if !ply:IsValid() then return end

	local ent = net.ReadEntity()
	local voice = net.ReadBool()

	if !ent:IsValid() then return end
	local radio = ent:GetRadioComponent()
	if !radio then return end

	if !Radio.CanEdit(ply, ent) then return end

	radio:SetVoiceEnabled(voice)
	hook.Call("Radio:TransmitVoice", nil, ply, ent, voice)
end
net.Receive("Radio:TransmitVoice", TransmitVoice)

util.AddNetworkString("Radio:ChangeLoopState")
local function ChangeLoopState(len, ply)
	if !ply:IsValid() then return end

	local ent = net.ReadEntity()
	local loop = net.ReadBool()

	if !ent:IsValid() then return end
	local radio = ent:GetRadioComponent()
	if !radio then return end

	if !Radio.CanEdit(ply, ent) then return end 

	radio:SetLooping(loop)
	hook.Call("Radio:ChangeLoopState", nil, ply, ent, loop)
end
net.Receive("Radio:ChangeLoopState", ChangeLoopState)

util.AddNetworkString("Radio:UpdateSettings")
local function UpdateSettings(len, ply)
	if !ply:IsValid() then return end

	local ent = net.ReadEntity()
	local color = net.ReadColor()
	local rainbow = net.ReadBool()
	local private = net.ReadBool()
	local privateBuddy = net.ReadBool()

	if !ent:IsValid() then return end
	local radio = ent:GetRadioComponent()
	if !radio then return end

	if !Radio.CanEdit(ply, ent) then return end 

	radio:SetVisual(color)
	radio:SetRainbow(rainbow)
	radio:SetPrivate(private)
	radio:SetPrivateBuddy(privateBuddy)

	hook.Call("Radio:PlayerUpdateSettings", nil, ply, ent)
	ServerLog(string.format("[Radio] %s (%s) has changed the visual of the radio.\n", ply:Name(), ply:SteamID()))
end
net.Receive("Radio:UpdateSettings", UpdateSettings)

util.AddNetworkString("Radio:RetrieveFromVehicle")
function Radio.RetrieveFromVehicle(len, ply)
	local ent = net.ReadEntity()

	if !IsValid(ent) or ply:InVehicle() then return end
	if !Radio.IsCar(ent) then return end
	if !Radio.Settings.EnableSWEP and !Radio.Settings.EnableEntity then return end
	if !Radio.Settings.VehicleSpawnRadioRetrieve and ent.SpawnedWithRadio then return end

	if ( !Radio.IsCarHaveRadio(ent) ) then
		ply:RadioChatInfo(Radio.GetLanguage("There is no radio in the car."), Radio.Chat.INFO)
		return
	end

	if !Radio.CanEdit(ply, ent) then
		ply:RadioChatInfo(Radio.GetLanguage("You are not the owner the car."), Radio.Chat.INFO)
		return 
	end

	local radio = ent:GetRadioComponent()

	if Radio.Settings.EnableSWEP and !ply:HasWeapon("numerix_radio_swep") then
		local weapon = ply:Give("numerix_radio_swep")
		weapon:SetRadioComponent(radio)

		ply:SelectWeapon(weapon)
	elseif Radio.Settings.EnableEntity then
		local entRadio = ents.Create( "numerix_radio" )
		entRadio:SetPos( ent:GetPos() + ent:GetRight()*100 + ent:GetUp()*50 )
		entRadio:Spawn()
		if FPP then
			entRadio:CPPISetOwner(ply)
		end

		entRadio:SetRadioComponent(radio)

		entRadio:SetColor(radio:GetColor())
	else
		ply:RadioChatInfo(Radio.GetLanguage("You already have a radio on you."), Radio.Chat.INFO)

		return
	end

	ply:RadioChatInfo(Radio.GetLanguage("You have retrieve the radio from the car."), Radio.Chat.SUCCESS)
end
net.Receive("Radio:RetrieveFromVehicle", Radio.RetrieveFromVehicle)