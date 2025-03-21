--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]

local function drawCircle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

local PANEL = {}

function PANEL:Init()   
end

function PANEL:PerformLayout(width, height)
	self:SetSize(width, height)
end

function PANEL:MakeContent(ent, type)
	local radio = ent:GetRadioComponent()
	if ( !radio ) then return end
	
	self.Paint = function(s, w, h)
		if ( !IsValid(radio) ) then return end

		if radio:GetInformation() != "" then
			draw.DrawText(radio:GetInformation(), "Radio.Menu", w/2, h/2 - 10, Radio.Color["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			return
		end

		if radio:GetURL() == "" then
			if radio:IsConnectedToServer() then
				draw.SimpleText(Radio.GetLanguage("Waiting for a server music"), "Radio.Menu", w/2, h/2 - 10, Radio.Color["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(Radio.GetLanguage("Enter a Youtube/MP3/SoundCloud URL"), "Radio.Menu", w/2, h/2 - 10, Radio.Color["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end
	
	local lastThumbnail = radio:GetMusicThumbnail()

	local icon = vgui.Create("DImage", self)
	icon:SetPos(5, 0)
	icon:SetSize(self:GetTall() + 25, self:GetTall() - 5)
	Radio.GetImage( radio:GetMusicThumbnail(), "thumbnail.jpg", function(url, filename)
		icon:SetImage(filename)
	end)

	self.Think = function()
		if ( !IsValid(radio) ) then return end

		if radio:GetMusicThumbnail() != lastThumbnail then
			Radio.GetImage( radio:GetMusicThumbnail(), "thumbnail.jpg", function(url, filename)
				if !IsValid(icon) then return end
				icon:SetImage(filename)
				lastThumbnail = radio:GetMusicThumbnail()
			end)
		end

		if IsValid(icon) then
			if radio:GetURL() == "" or radio:GetMusicThumbnail() == "" then
				icon:SetAlpha(0)
			else
				icon:SetAlpha(255)
			end
		end
	end

	local lastPauseState = radio:IsPaused()
	local PlayPauseButton = vgui.Create( "DImageButton", self )
	PlayPauseButton:SetSize( self:GetTall()/2, self:GetTall()/2 )			
	PlayPauseButton:SetPos( self:GetWide()/10, 0 )	
	PlayPauseButton:SetText( "" )			
	PlayPauseButton:SetImage(lastPauseState and "numerix_radio/play.png" or "numerix_radio/pause.png")
	PlayPauseButton:SetTooltip(lastPauseState and Radio.GetLanguage("Pause") or Radio.GetLanguage("UnPause"))
	PlayPauseButton:CenterVertical(0.5)
	PlayPauseButton.Think = function( self )
		if ( !IsValid(radio) ) then return end

		if radio:IsConnectedToServer() or radio:GetURL() == "" then
			self:SetAlpha(0)
		else
			self:SetAlpha(255)
		end

		if radio:IsPaused() then
			if !lastPauseState then
				self:SetToolTip( Radio.GetLanguage("Pause") )

				self:SetImage("numerix_radio/play.png")
				lastPauseState = true
			end
		else
			if lastPauseState then
				self:SetToolTip(Radio.GetLanguage("UnPause") )
			
				self:SetImage("numerix_radio/pause.png")

				lastPauseState = false
			end
		end
	end
	PlayPauseButton.Paint = function( self, w, h )            
		if self:IsHovered() or self:IsDown() then
			draw.RoundedBox( 5, 0, 0, w, h, Radio.Color["button_hover"] )
		end
	end
	PlayPauseButton.DoClick = function()
		if ( !IsValid(radio) ) then return end

		if !radio:IsConnectedToServer() and radio:GetURL() != "" then
			net.Start("Radio:PauseMusic")
			net.WriteEntity(ent)
			net.WriteBool(!radio:IsPaused())
			net.SendToServer()
		end
	end
	
	local StopMusic = vgui.Create( "DImageButton", self )		
	StopMusic:SetPos( self:GetWide()/10 + self:GetTall()/2 + 10, 0 )
	StopMusic:SetSize( self:GetTall()/2, self:GetTall()/2 )			
	StopMusic:SetToolTip( Radio.GetLanguage("Stop") )
	StopMusic:SetFont("Radio.Button")
	StopMusic:SetImage( "numerix_radio/stop.png" )
	StopMusic:CenterVertical(0.5)
	StopMusic.Paint = function( self, w, h )            
		if self:IsHovered() or self:IsDown() then
			draw.RoundedBox( 5, 0, 0, w, h, Radio.Color["button_hover"] )
		end
	end
	StopMusic.Think = function(self)
		if ( !IsValid(radio) ) then return end

		if radio:IsConnectedToServer() or radio:GetURL() == "" then
			self:SetAlpha(0)
		else
			self:SetAlpha(255)
		end
	end
	StopMusic.DoClick = function()
		if ( !IsValid(radio) ) then return end

		if !radio:IsConnectedToServer() and radio:GetURL() != "" then
			net.Start("Radio:StopMusic")
			net.WriteEntity(ent)
			net.SendToServer()
		end
	end

	local LoopMusic = vgui.Create( "DImageButton", self )		
	LoopMusic:SetPos( self:GetWide()/10 + (self:GetTall()/2 + 10)*2, 0 )
	LoopMusic:SetSize( self:GetTall()/2, self:GetTall()/2 )			
	LoopMusic:SetToolTip( Radio.GetLanguage("Loop") )
	LoopMusic:SetFont("Radio.Button")
	LoopMusic:SetImage( "numerix_radio/loop.png" )
	LoopMusic:CenterVertical(0.5)
	LoopMusic.Paint = function( self, w, h )            
		if self:IsHovered() or self:IsDown() or radio:IsLooping() then
			draw.RoundedBox( 5, 0, 0, w, h, Radio.Color["button_hover"] )
		end
	end
	LoopMusic.Think = function(self)
		if ( !IsValid(radio) ) then return end

		if radio:IsConnectedToServer() or radio:GetURL() == "" or radio:IsLive() then
			self:SetAlpha(0)
		else
			self:SetAlpha(255)
		end
	end
	LoopMusic.DoClick = function()
		if ( !IsValid(radio) ) then return end

		if !radio:IsConnectedToServer() and radio:GetURL() != "" and !radio:IsLive() then
			net.Start("Radio:ChangeLoopState")
			net.WriteEntity(ent)
			net.WriteBool(!radio:IsLooping())
			net.SendToServer()
		end
	end
	
	local TimeInfo = vgui.Create( "DLabel", self )
	TimeInfo:SetText( "" )
	TimeInfo:SetTextColor(Radio.Color["text"])
	TimeInfo:SetFont("Radio.Menu")
	TimeInfo:SizeToContents()
	TimeInfo:CenterVertical(0.5)
	TimeInfo:CenterHorizontal(0.25)
	TimeInfo.Think = function(self)
		if ( !IsValid(radio) ) then return end

		if radio:IsPlaying() then
			if !radio:IsLive() then
				self:SetText(Radio.SecondsToClock(radio:GetCurrentTime(false)).."/"..Radio.SecondsToClock(radio:GetMusicDuration()))	
			else
				self:SetText(Radio.SecondsToClock(radio:GetCurrentTime(false)))
			end

			self:SetAlpha(255)

			self:SizeToContents()
		else
			self:SetAlpha(0)
		end
	end

	local TimeSlider = vgui.Create( "DNumSlider", self )			
	TimeSlider:SetSize( self:GetWide()/4, 40 )		
	TimeSlider:SetText( "" )
	TimeSlider.Label:Dock(0)
	TimeSlider.Label:SetSize(0,0)	
	TimeSlider.Label:SetTextColor( Radio.Color["text"] )
	TimeSlider.Label:SetFont("Radio.Button")
	TimeSlider.Scratch:Dock(0)
	TimeSlider.Scratch:SetSize(0,0)
	TimeSlider.Slider:Dock(0)
	TimeSlider.Slider:SetPos(0,0)
	TimeSlider.Slider:SetSize(TimeSlider:GetWide(), 40)
	TimeSlider:SetMin( 0 )				
	TimeSlider:SetMax( isnumber(radio:GetMusicDuration()) and radio:GetMusicDuration() or 0 )				
	TimeSlider:SetDecimals( 0 )	
	TimeSlider:SetValue(radio:GetCurrentTime(false) or 0)
	TimeSlider.TextArea:SetVisible(false)
	TimeSlider.Think = function(s)
		if ( !IsValid(radio) ) then return end

		if radio:IsPlaying() and !radio:IsLive() then
			if( !s:IsEditing() ) then
				s:SetValue(radio:GetCurrentTime(false))
			end

			s:SetMax( radio:GetMusicDuration() or 0 )		
			s:SetAlpha(255)
			
		else
			s:SetAlpha(0)
		end

		local _, y = s:GetPos()
		local x, _ = TimeInfo:GetPos()
		s:SetPos( x + TimeInfo:GetWide() + 10, y)
		s:CenterVertical(0.5)
	end
	TimeSlider.Slider.Think = function(self)
		if ( !IsValid(radio) ) then return end

		if radio:IsPlaying() and !radio:IsLive() then
			self:SetAlpha(255)
		else
			self:SetAlpha(0)
		end
	end
	TimeSlider.Slider.Paint = function(self, w, h)
		surface.SetDrawColor( Radio.Color["button_line"] )
		surface.DrawRect( 0, h / 2 - 1, w-12, 5 )
		
		local x, y = self.Knob:GetPos()
		surface.SetDrawColor( Radio.Color["button_hover"] )
		surface.DrawRect( 0, h / 2 - 1, x+(7.5/2), 5 )
	end 
	TimeSlider.Slider.Knob.Paint = function(self, w, h)
		if TimeSlider:IsHovered() or self:IsHovered() then
			surface.SetDrawColor( Radio.Color["button_hover"] )
			draw.NoTexture()
	
			drawCircle( 7.5/2, 10, 7.5, 360 )
		end
	end
	function TimeSlider.Slider:OnMouseReleased( mcode )
		self:SetDragging( false );
		self:MouseCapture( false );

		if ( !IsValid(radio) ) then return end

		if radio:IsPlaying() and !radio:IsLive() and Radio.Settings.Seek and !radio:IsConnectedToServer() then
			net.Start("Radio:SeekMusic")
			net.WriteEntity(ent)
			net.WriteFloat(self:GetSlideX() * radio:GetMusicDuration())
			net.SendToServer()
		end
	end
	function TimeSlider.Slider.Knob:OnMouseReleased( mcode )
		if ( !IsValid(radio) ) then return end

		if radio:IsPlaying() and !radio:IsLive() and Radio.Settings.Seek and !radio:IsConnectedToServer() then
			net.Start("Radio:SeekMusic")
			net.WriteEntity(ent)
			net.WriteFloat(self:GetParent():GetSlideX() * radio:GetMusicDuration())
			net.SendToServer()
		end

		return DLabel.OnMouseReleased( self, mcode );
	end

	local VolumeInfo = vgui.Create( "DLabel", self )
	VolumeInfo:SetText( Radio.GetLanguage("Volume") )
	VolumeInfo:SetFont("Radio.Menu")
	VolumeInfo:SetTextColor(Radio.Color["text"])
	VolumeInfo:SizeToContents()
	VolumeInfo:CenterVertical(0.5)
	VolumeInfo:CenterHorizontal(0.8)
	VolumeInfo.Think = function(self)
		if ( !IsValid(radio) ) then return end

		if radio:IsPlaying() then
			self:SetAlpha(255)
		else
			self:SetAlpha(0)
		end
	end

	local x, y = VolumeInfo:GetPos()
	local VolumeSlider = vgui.Create( "DNumSlider", self )
	VolumeSlider:SetPos( x + VolumeInfo:GetWide() + 10, 0 )	
	VolumeSlider:SetSize( self:GetWide()/6, 40 )		
	VolumeSlider:SetText( "" )
	VolumeSlider.Label:Dock(0)
	VolumeSlider.Label:SetSize(0,0)	
	VolumeSlider.Label:SetTextColor( Radio.Color["text"] )
	VolumeSlider.Label:SetFont("Radio.Button")
	VolumeSlider.Scratch:Dock(0)
	VolumeSlider.Scratch:SetSize(0,0)
	VolumeSlider.Slider:Dock(0)
	VolumeSlider.Slider:SetPos(0,0)
	VolumeSlider.Slider:SetSize(VolumeSlider:GetWide(), 40)
	VolumeSlider:SetMin( 0 )				
	VolumeSlider:SetMax( 100 )				
	VolumeSlider:SetDecimals( 0 )	
	VolumeSlider:SetValue(radio:GetVolume())
	VolumeSlider.TextArea:SetVisible(false)
	VolumeSlider:CenterVertical(0.5)	
	VolumeSlider.Think = function(self)
		if ( !IsValid(radio) ) then return end

		if radio:IsPlaying() then
			self:SetAlpha(255)
		else
			self:SetAlpha(0)
		end
	end		
	VolumeSlider.Slider.Paint = function(self, w, h)
		surface.SetDrawColor( Radio.Color["button_line"] )
		surface.DrawRect( 0, h / 2 - 1, w-12, 5 )

		local x, y = self.Knob:GetPos()
		surface.SetDrawColor( Radio.Color["button_hover"] )
		surface.DrawRect( 0, h / 2 - 1, x+(7.5)/2, 5 )
	end
		
	VolumeSlider.Slider.Knob.Paint = function(self, w, h)
		if VolumeSlider:IsHovered() or self:IsHovered() then
			surface.SetDrawColor( Radio.Color["button_hover"] )
			draw.NoTexture()
	
			drawCircle( 7.5/2, 10, 7.5, 360 )
		end
	end
	function VolumeSlider.Slider:OnMouseReleased( mcode )
		self:SetDragging( false );
		self:MouseCapture( false );

		if ( !IsValid(radio) ) then return end
		if radio:GetVolume() == self:GetSlideX() * 100 then return end

		net.Start("Radio:UpdateVolume")
		net.WriteEntity(ent)
		net.WriteUInt(self:GetSlideX() * 100, 7)
		net.SendToServer()
		
	end
	function VolumeSlider.Slider.Knob:OnMouseReleased( mcode )
		if ( !IsValid(radio) ) then return end
		if radio:GetVolume() == self:GetParent():GetSlideX() * 100 then return end

		net.Start("Radio:UpdateVolume")
		net.WriteEntity(ent)
		net.WriteUInt(self:GetParent():GetSlideX() * 100, 7)
		net.SendToServer()

		return DLabel.OnMouseReleased( self, mcode )
	end
end
vgui.Register("Radio_Foot", PANEL, "DPanel")