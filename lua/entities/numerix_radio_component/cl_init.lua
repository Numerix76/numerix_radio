--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]

include("shared.lua")

function ENT:IsPlaying()
	return self.playing
end

function ENT:GetCurrentTime(serverTime)
	if ( !serverTime and self.station ) then
		return self.station:GetTime()
	else
		return CurTime() - self:GetStartTime()
	end
end

function ENT:GetStation()
	return self.station
end

function ENT:OnRemove()
	self:Stop()
end

function ENT:Stop()
	if self.station and IsValid(self.station) then
		self.station:Stop()

		self.station = nil
		self.playing = false
	end
end

function ENT:Think()
	local ply = LocalPlayer()
	local url = self:GetURL()

	if url == "" and (self.playing or self.stationError) then 
		self:Stop()
	end

	--print(self.station, self.station:GetVolume())
	
	if url != "" and !self.playing and !self.startedPlaying then 
		self.startedPlaying = true --To not lunch multiple times the music
		sound.PlayURL(url, "3d noblock", function( station, errorID, errorName )
			if errorID then
				if !self.stationError then
					Radio.Error(ply, string.format(Radio.GetLanguage("Impossible to play the music. Contact an administrator if this persists. (Error : %s, Name : %s)"), errorID or "", errorName or ""))
				end
					
				self.stationError = true
				self.startedPlaying = false

				return
			end
		
			self.Error = false

			if ( IsValid( station ) and IsValid( self:GetParent() ) ) then
				station:SetPos( self:GetParent():GetPos() )
				station:Set3DFadeDistance( 0, 1 )
				station:Play()
				
				self.playing = true
				self.station = station
			end

			self.startedPlaying = false
		end)
	end

	if !self.playing then return end
	
	local maxDistance = self:GetDistanceSound()
	local volume = 0

	self.station:Set3DEnabled(maxDistance < 0)
	self.station:SetPos(self:GetParent():GetPos())

	if self:CanHear(ply) then
		volume = self:GetVolume()/100
		
		if maxDistance != -1 then
			volume = volume * ( 1 - ( self.station:GetPos():DistToSqr( ply:EyePos() ) ) / maxDistance )
			volume = math.Clamp(volume, 0, 1)
		end
	end

	if self.station:GetVolume() != volume then
		self.station:SetVolume(volume)
	end

	pause = self:IsPaused()
	music_state = self.station:GetState()

	if ( music_state != GMOD_CHANNEL_PAUSED and pause ) then
		self.station:Pause();
	elseif ( music_state == GMOD_CHANNEL_PAUSED and !pause ) then
		self.station:Play();
	elseif music_state == GMOD_CHANNEL_STOPPED and url then
		self.station:Play();
	end

	if ( !self:IsLive() and !pause ) then
		local serverTime = self:GetCurrentTime(true)

		if math.abs( self.station:GetTime() - serverTime ) > 0.5 then -- There is a difference between what he should listen
			serverTime = math.Clamp(serverTime, 0, self:GetMusicDuration())
			self.station:SetTime(serverTime)
		end
	end
end