--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]

local ENT = FindMetaTable("Entity")
local SWEP = FindMetaTable("Weapon")

function ENT:CanModificateRadio(ply)
	if !IsValid(self) then return false end
	if !ply:Alive() then return false end
	
	local maxdist = self:IsCarRadio() and 22500 or 100000

	local canedit = hook.Call("Radio:CanModificate", nil, ply, self)
	if canedit == false then return false end
   
	if ply:GetPos():DistToSqr(self:GetPos()) > maxdist then return false end
	if !Radio.AllRadio[self] and !self:IsCarRadio() then return false end

	if self:IsCarRadio() then
		--Check he own the car or he can use it
		if DarkRP and !ply:canKeysLock(self) and !scripted_ents.IsBasedOn(self:GetClass(), "wac_hc_base") then return false end
		if FPP and !self:CPPICanUse(ply) then return false end
	end

	--Check property with FPP 
	local owner = self.FPPOwner or self.Owner
	if FPP and self:GetNWBool("Radio:Private") and (self:GetNWBool("Radio:PrivateBuddy") and !self:CPPICanUse(ply) or !self:GetNWBool("Radio:PrivateBuddy") and owner != ply) then return false end

	return true
end

function ENT:StopMusicRadio(ply)
	if !self:CanModificateRadio(ply) then return end 
	if self != self:GetControlerRadio() then return end

	self:SetNWString( "Radio:URL", "" )
	self:SetNWString( "Radio:Author", "" )
	self:SetNWString( "Radio:Title", "" )
	self:SetNWString( "Radio:Mode", "0" )
	self:SetNWInt   ( "Radio:Duration", 0)

	hook.Call("Radio:PlayerStopMusic", nil, ply, self)

	ServerLog("[Radio] "..ply:Name().."("..ply:SteamID()..") has stopped the music.\n")
end

function ENT:SetVolumeRadio(ply, volume)
	if !self:CanModificateRadio(ply) then return end
	
	volume = math.Clamp(volume, 0, 100)
	volume = math.Round(volume)

	self:SetNWInt("Radio:Volume", volume)

	local distance = !self:IsCarRadio() and self.DistanceSound*(volume+1)/50 or 200000
	self:SetNWInt("Radio:DistanceSound", distance)

	hook.Call("Radio:PlayerUpdateVolume", nil, ply, self, volume)

	ServerLog("[Radio] "..ply:Name().."("..ply:SteamID()..") has changed the volume.\n")
end

function ENT:SetMusicRadio(ply, url)
	if url == "" then return end 
	
	if !self:CanModificateRadio(ply) then return end
	if self.isloading then ply:RadioChatInfo(Radio.GetLanguage("Please wait the end of last loading"), 3) return end

	if ( (self.IsServer and Radio.Settings.ActivePresetOnlyServer) or ( ( self:IsCarRadio() or self.ENTRadio or self.SWEPRadio ) and Radio.Settings.ActivePresetOnlyRadio ) ) and !Radio.Settings.Preset[url] then return end    

	Radio.SetMusic(ply, self, url)

	self:SetNWBool("Radio:Pause", false)

	if self:GetControlerRadio() != self then
		self:RemoveListenerRadio()
	end

	hook.Call("Radio:PlayerSetMusic", nil, ply, self, id, mode)

	ServerLog("[Radio] "..ply:Name().."("..ply:SteamID()..") has changed the music.\n")
end

function ENT:SetPauseRadio(ply, pause)
	if !self:CanModificateRadio(ply) then return end
	if self != self:GetControlerRadio() then return end

	if pause then
		self.PauseTime = CurTime() - self:GetNWInt("Radio:Time")
	else
		self:SetNWInt("Radio:Time", CurTime() - (self.PauseTime or 0))
		self.PauseTime = nil
	end

	self:SetNWBool("Radio:Pause", pause)

	hook.Call("Radio:PlayerPauseMusic", nil, ply, self, pause)

	ServerLog("[Radio] "..ply:Name().."("..ply:SteamID()..") has paused the music.\n")
end

function ENT:SeekTimeRadio(ply, time)
	if !self:CanModificateRadio(ply) then return end
	if self != self:GetControlerRadio() then return end
	if self:IsPlayingLive() then return end

	time = math.Clamp(time, 0, self:GetDurationRadio())
	self:SetNWInt("Radio:Time", CurTime() - time)

	self:SetNWBool("Radio:Pause", false)

	hook.Call("Radio:PlayerSeekMusic", nil, ply, self, time)

	ServerLog("[Radio] "..ply:Name().."("..ply:SteamID()..") has seeked the music.\n")
end

function ENT:SetVisualRadio(ply, color, rainbow)
	if !self:CanModificateRadio(ply) then return end
	
	color = string.FromColor( color )

	self:SetNWString("Radio:Visual", color)
	self:SetNWBool("Radio:Rainbow", rainbow)

	hook.Call("Radio:PlayerUpdateVisual", nil, ply, self, color, rainbow)

	ServerLog("[Radio] "..ply:Name().."("..ply:SteamID()..") has change the visual of the radio.\n")
end

function ENT:TakeRadio(ply)
	if !self:CanModificateRadio(ply) then return end
	if self:GetClass() != "numerix_radio" then return end
	if ply:HasWeapon("numerix_radio_swep") then return end

	self:Remove()

	local radio = ply:Give("numerix_radio_swep")

	if not IsValid(radio) then return end

	self:ChangeModRadio(ply, radio)
end

function ENT:ConnectDisconnectRadio(ply, server, connect)
	if !self:CanModificateRadio(ply) then return end
	
	local oldserver = self:GetControlerRadio() 
	
	if self.isloading then ply:RadioChatInfo(Radio.GetLanguage("Please wait the end of last loading"),3) return end
	
	if !self:CanModificateRadio(ply) then return end
	
	if !connect then 
		hook.Call("Radio:DisconnectRadio", nil, ply, self, self:GetControlerRadio() )
		self:RemoveListenerRadio()
		if self.SWEPRadio then self.LastStation = server end
		
		return 
	end

	if !IsValid(server) or !server.IsServer or self:GetControlerRadio() == server then return end
	
	oldserver:SetNWInt("Radio:Viewer", oldserver:GetNWInt("Radio:Viewer")-1)
	self:SetNWInt("Radio:Controler", server:EntIndex())
	server:SetNWInt("Radio:Viewer", server:GetNWInt("Radio:Viewer")+1)

	self:SetNWString("Radio:URL", "")
	self:SetNWBool("Radio:Pause", false)

	if self.SWEPRadio then self.LastStation = server end  

	hook.Call("Radio:ConnectRadio", nil, ply, self, server)
end

function ENT:SetNameServerRadio(ply, name)
	if !self:CanModificateRadio(ply) then return end
	if !self.IsServer then return end
	
	self:SetNWString("Radio:StationName", name) 
	hook.Add("Radio:SetNameServer", nil, ply, self, name)
end

function ENT:SetTransmitVoiceRadio(ply, voice)
	if !self:CanModificateRadio(ply) then return end
	if !self.IsServer then return end

	self:SetNWBool("Radio:Voice", voice)
	hook.Call("Radio:TransmitVoice", nil, ply, self, voice)
end

function ENT:SetLoopRadio(ply, loop)
	if !self:CanModificateRadio(ply) then return end
	if self != self:GetControlerRadio() then return end

	self:SetNWBool("Radio:Loop", loop)
	hook.Call("Radio:ChangeLoopState", nil, ply, self, loop)
end

function ENT:SetPrivateRadio(ply, private)
	if !self:CanModificateRadio(ply) then return end

	self:SetNWBool("Radio:Private", private)
	hook.Call("Radio:ChangePrivateState", nil, ply, self, private)
end

function ENT:SetPrivateBuddyRadio(ply, privateBuddy)
	if !self:CanModificateRadio(ply) then return end

	self:SetNWBool("Radio:PrivateBuddy", privateBuddy)
	hook.Call("Radio:ChangePrivateBuddyState", nil, ply, self, privateBuddy)
end

util.AddNetworkString("Radio:OnRemove")
function ENT:DeleteRadio() 
	if !IsValid(self) then return end

	net.Start("Radio:OnRemove")
	net.WriteEntity(self)
	net.Broadcast()

	self:SetNWString( "Radio:URL", "" )
	self:SetNWString( "Radio:Author", "" )
	self:SetNWString( "Radio:Title", "" )
	self:SetNWString( "Radio:Mode", "0" )
	self:SetNWInt( "Radio:Duration", 0)

	if self.IsServer then
		for radio, _ in pairs(Radio.AllRadio) do
			if radio:GetControlerRadio() == self then radio:SetNWInt("Radio:Controler", radio:EntIndex()) end
		end
		
		Radio.AllServer[self] = nil
	else
		self:RemoveListenerRadio()
	end

	Radio.AllRadio[self] = nil
end

function ENT:RemoveListenerRadio()
	local controler = self:GetControlerRadio()

	if !IsValid(self) or !IsValid(controler) then return end
	if self == controler then return end
	
	self:SetNWInt("Radio:Controler", self:EntIndex())
	controler:SetNWInt("Radio:Viewer", controler:GetNWInt("Radio:Viewer")-1)
end

function ENT:ChangeModRadio(ply, radio)
	if !IsValid(self) or !IsValid(radio) then return end

	radio.PauseTime = self.PauseTime

	radio:SetNWString( "Radio:URL", self:GetNWString("Radio:URL") )
	radio:SetNWString( "Radio:Author", self:GetNWString("Radio:Author") )
	radio:SetNWString( "Radio:Title", self:GetNWString("Radio:Title") )
	radio:SetNWString( "Radio:Mode", self:GetNWString("Radio:Mode") )
	radio:SetNWString( "Radio:Info", "" )
	radio:SetNWString( "Radio:Visual", self:GetNWString("Radio:Visual") )
	radio:SetNWString( "Radio:Color", string.FromColor(self:GetColor()))
	radio:SetNWString( "Radio:Thumbnail", self:GetNWString("Radio:Thumbnail"))
	radio:SetNWString( "Radio:ThumbnailName", self:GetNWString("Radio:ThumbnailName"))
	
	radio:SetNWInt( "Radio:Volume", self:GetNWInt("Radio:Volume") )
	radio:SetNWInt( "Radio:Time", self:GetNWInt("Radio:Time") )
	radio:SetNWInt( "Radio:Duration", self:GetNWInt("Radio:Duration"))
	radio:SetNWInt( "Radio:DistanceSound", radio:IsCarRadio() and 200000 or (radio.DistanceSound*self:GetNWInt("Radio:Volume")/50))

	radio:SetNWBool( "Radio:Rainbow", self:GetNWBool("Radio:Rainbow") )
	radio:SetNWBool( "Radio:Pause", self:GetNWBool("Radio:Pause"))
	radio:SetNWBool( "Radio:Loop", self:GetNWBool("Radio:Loop"))
	radio:SetNWBool( "Radio:Private", self:GetNWBool("Radio:Private"))
	radio:SetNWBool( "Radio:PrivateBuddy", self:GetNWBool("Radio:PrivateBuddy"))   
	
	if self:GetControlerRadio() != self then
		radio:SetNWInt("Radio:Controler", self:GetControlerRadio():EntIndex())
		self:GetControlerRadio():SetNWInt("Radio:Viewer", self:GetControlerRadio():GetNWInt("Radio:Viewer")+1)
	else
		radio:SetNWInt("Radio:Controler", radio:EntIndex())
	end

	if radio.SWEPRadio then 
		if self == self:GetControlerRadio() then
			radio.LastStation = radio
		else
			radio.LastStation = self:GetControlerRadio()
		end
	end

	self:SetNWString("Radio:URL", "")

	hook.Call("Radio:ChangeMod", nil, ply, self, radio)
end

function ENT:ThinkRadio()
	
	if IsValid(self:GetParent()) and !self:GetParent():IsPlayer() then return end
	
	local controler = self:GetControlerRadio()

	-- Force Stop ?
	if self:GetNWString("Radio:URL") == "" and self:GetDurationRadio() != 0 then
		self:SetNWString("Radio:Author", "")
		self:SetNWString("Radio:Title", "")
		self:SetNWString("Radio:Mode", "0")

		self:SetNWInt("Radio:Duration", 0)
		self:SetNWInt("Radio:Time", 0)

		return -- No need to check after
	end

	--Under Water ?
	if ( IsValid(self:GetParent()) and self:GetParent():IsPlayer() and self.Owner:WaterLevel() == 3 or 
		!IsValid(self:GetParent()) and self:WaterLevel() == 3 or ( self:IsCarRadio() and !self:GetNWBool("Radio:HasRadio") ) ) and 
		(self:GetNWString("Radio:URL") != "" or controler != self) then
			
		self:SetNWString("Radio:URL", "")

		if IsValid(self.Owner) then
			self.Owner:EmitSound("ambient/energy/spark5.wav")
		else
			self:EmitSound("ambient/energy/spark5.wav")
		end

		if controler != self then
			self:RemoveListenerRadio()
			self:SetNWInt("Radio:Controler", self:EntIndex()) 
		end

		return -- No need to check after
	end

	--Music is finished ?
	if !self:GetNWBool("Radio:Pause") and self:GetCurrentTimeRadio() > self:GetDurationRadio() and !self:IsPlayingLive() and 
		self:GetNWString("Radio:URL") !="" then
		
		if self:GetNWBool("Radio:Loop") then
			self:SetNWInt("Radio:Time", CurTime())
		else
			self:SetNWString("Radio:URL", "")
		end

		return -- No need to check after
	end
end