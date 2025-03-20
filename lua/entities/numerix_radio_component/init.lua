--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

function ENT:Initialize()
	self:SetNoDraw( true )
end

function ENT:SetMaxDistanceSound(distance)
	assert(isnumber(distance), "distance must be a number")

	self:SetNWInt("Radio:MaxDistanceSound", distance)
end

function ENT:Play(url, ply)
	local musicInfo = {};

	if ( self:IsLoading() ) then return end

	self:SetController(nil)
	self:Resume()

	self:SetLoading(true)

	Radio.GetFinalURL(
		url,
		ply,
		function(url)
			if ( !IsValid(self) ) then return end

			self:SetLoading(false)

			self:SetURL(url)
			self:SetLive(musicInfo.live or false)
			self:SetStartTime(SysTime())
			self:SetInformation("")
			self:SetMusicDuration(musicInfo.duration)
			self:SetMusicTitle(musicInfo.title)
			self:SetMusicAuthor(musicInfo.artist)
			self:SetMusicThumbnail(musicInfo.thumbnail)
		end,
		function(error)
			if ( !IsValid(self) ) then return end

			self:SetLoading(false)

			self:SetInformation(Radio.GetLanguage("An error occured. Check the message in chat"))
			Radio.Error(ply, error.message)
			if ( error.log ) then
				Radio.Error(ply, Radio.GetLanguage("Logs") .. " : " .. error.log)
			end
		end,
		function(data)
			if ( !IsValid(self) ) then return end

			musicInfo = data
		end,
		function(message)
			if ( !IsValid(self) ) then return end

			self:SetInformation(message)
		end
	)
end

function ENT:SetURL(url)
	if ( url ) then 
		assert(isstring(url), "url must be a string")

		if ( self:IsLoading() ) then return end
		if ( !string.gmatch("http(s)+://.*", url) ) then return end
	end

	if ( self:IsConnectedToServer() ) then return end

	self:SetNWString("Radio:URL", url)
end

function ENT:SetMusicAuthor(author)
	if ( author ) then 
		assert(isstring(author), "author must be a string")
	end

	if ( self:IsConnectedToServer() ) then return end

	self:SetNWString("Radio:Author", author)
end

function ENT:SetMusicTitle(title)
	if ( title ) then
		assert(isstring(title), "title must be a string")
	end

	if ( self:IsConnectedToServer() ) then return end

	self:SetNWString("Radio:Title", title)
end

function ENT:SetMusicThumbnail(thumbnail)
	if ( thumbnail ) then
		assert(isstring(thumbnail), "thumbnail must be a string")
	end

	if ( self:IsConnectedToServer() ) then return end

	self:SetNWString("Radio:Thumbnail", thumbnail)
end

function ENT:SetMusicThumbnailName(thumbnailName)
	if ( thumbnailName ) then
		assert(isstring(thumbnailName), "thumbnailName must be a string")
	end

	if ( self:IsConnectedToServer() ) then return end

	self:SetNWString("Radio:ThumbnailName", thumbnailName)
end

function ENT:SetMusicDuration(duration)
	if ( duration ) then
		assert(isnumber(duration), "duration must be a number")
	end

	if ( self:IsConnectedToServer() ) then return end

	self:SetNWFloat( "Radio:Duration", duration )
end

function ENT:SetInformation(information)
	if ( information ) then
		assert(isstring(information), "information must be a string")
	end

	self:SetNWString("Radio:Info", information)
end

function ENT:SetVisual(color)
	assert(isstring(color) or IsColor(color), "color must be a string or a Color")

	if IsColor(color) then
		color = string.FromColor(color) 
	end

	self:SetNWString("Radio:Visual", color)
end

function ENT:SetVolume(volume)
	assert(isnumber(volume), "volume must be a number")

	volume = math.Clamp(volume, 0, 100)

	self:SetNWInt("Radio:Volume", volume)
end

function ENT:SetStartTime(time)
	if ( time ) then
		assert(isnumber(time), "time must be a number")
	end

	if ( self:IsConnectedToServer() ) then return end

	self:SetNWFloat("Radio:Time", time)
end

function ENT:SetRainbow(rainbow)
	assert(isbool(rainbow), "rainbow must be a boolean")

	self:SetNWBool("Radio:Rainbow", rainbow)
end

function ENT:SetPrivate(private)
	assert(isbool(private), "private must be a boolean")

	self:SetNWBool("Radio:Private", private)
end

function ENT:SetPrivateBuddy(privateBuddy)
	assert(isbool(privateBuddy), "privateBuddy must be a boolean")

	self:SetNWBool("Radio:PrivateBuddy", privateBuddy)
end

function ENT:IsPlaying()
	return self:GetURL() != ""
end

function ENT:Stop()
	if ( self:IsConnectedToServer() ) then return false end

	self:SetURL("")
	self:SetMusicAuthor("")
	self:SetMusicTitle("")
	self:SetMusicDuration(nil)

	return true
end

function ENT:Pause()
	if ( self:IsConnectedToServer() ) then return end

	self.pauseTime = self:GetCurrentTime()
	self:SetNWBool("Radio:Pause", true)
end

function ENT:Resume()
	if ( self:IsConnectedToServer() ) then return end

	self:SetCurrentTime(self.pauseTime or 0)
	self.pauseTime = nil

	self:SetNWBool("Radio:Pause", false)
end

function ENT:SetLive(live)
	assert(isbool(live), "live must be a boolean")

	self:SetNWBool("Radio:Live", live)
end

function ENT:SetLoading(loading)
	assert(isbool(loading), "loading must be a boolean")

	self:SetNWBool("Radio:Loading", loading)
end

function ENT:SetController(controller)
	assert(!self:IsLoading(), "You must not change the controller while a music is loading")

	if ( controller ) then
		assert(isentity(controller) and IsValid(controller), "controller must be an entity");
		assert(controller:GetClass() == "numerix_radio_component", "controller must be a 'numerix_radio_component'")
		assert(controller:IsServer(), "controller mus be a server")
	end

	self:Stop()
	self:Resume()

	self:GetController():RemoveListener();
	self:SetNWEntity("Radio:Controller", controller or self);
	self:GetController():AddListener();
end

function ENT:AddListener()
	if ( !self:IsServer() ) then return end

	self:SetNWInt("Radio:Viewer", self:GetListeners()+1)
end

function ENT:RemoveListener()
	if ( !self:IsServer() ) then return end

	self:SetNWInt("Radio:Viewer", math.max(self:GetListeners()-1, 0))
end

function ENT:SetCurrentTime(time)
	assert(isnumber(time), "time must be a number")

	time = math.Clamp(time, 0, self:GetMusicDuration() or 0)

	self:SetStartTime(SysTime() - time)
end

function ENT:SetVoiceEnabled(voice)
	assert(isbool(voice), "voice must be a boolean")

	if ( !self:IsServer() ) then return end

	self:SetNWBool("Radio:Voice", voice)
end

function ENT:SetServerName(name)
	assert(isstring(name), "name must be a string")
	
	if ( !self:IsServer() ) then return end

	self:SetNWString("Radio:ServerName", name)
end

function ENT:GetCurrentTime()
	return SysTime() - self:GetStartTime()
end

function ENT:SetServer(server)
	assert(isbool(server), "server must be a boolean")

	self:SetNWBool("Radio:IsServer", server)
end

function ENT:SetLooping(loop)
	assert(isbool(loop), "loop must be a boolean")

	self:SetNWBool("Radio:Loop", loop)
end

function ENT:OnRemove()
	self:GetController():RemoveListener();
	self:Stop();

	if ( self:IsServer() ) then
		for _, listener in ipairs(ents.FindByClass("numerix_radio_component")) do
			if ( listener:GetController() != self ) then continue end

			listener:SetController(nil)
		end
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:Think()
	self:CheckUnderWater()
	self:CheckMusicFinished()
end

function ENT:CheckUnderWater()
	if ( !IsValid(self:GetParent()) ) then return end
	if ( !self:IsConnectedToServer() and !self:IsPlaying() ) then return end

	local waterLevel = self:GetParent():WaterLevel()
	if ( self:GetParent():IsWeapon() ) then
		waterLevel = self:GetParent().Owner:WaterLevel()
	end

	if ( waterLevel == 3 ) then
		self:Stop()
		self:SetController(nil)

		self:GetParent():EmitSound("ambient/energy/spark5.wav")
	end
end

function ENT:CheckMusicFinished()
	if ( !self:IsPlaying() ) then return end
	if ( self:IsPaused() ) then return end
	if ( self:IsLive() ) then return end

	if ( self:GetCurrentTime() > self:GetMusicDuration() ) then
		if ( self:IsLooping() ) then
			self:SetCurrentTime(0)
		else
			self:Stop()
		end
	end
end

