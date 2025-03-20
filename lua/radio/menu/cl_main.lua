--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]

local PANEL = {}

function PANEL:Init()   
end

function PANEL:PerformLayout(width, height)
    self:SetSize(width, height)
end

function PANEL:MakeContent(ent)
	local RadioContent = self

	local radio = ent:GetRadioComponent()
	if ( !radio ) then return end

    RadioContent.Paint = function(self, w, h) end

    local Playing = vgui.Create( "DLabel", RadioContent )
	Playing:SetPos( 10, 40 )
	Playing:SetSize( RadioContent:GetWide()/2-25, 50 )
	Playing:SetText( Radio.GetLanguage("Now Playing :") )
	Playing:SetTextColor(Radio.Color["text"])
	Playing:SetFont("Radio.Menu")
	Playing.Think = function(self)
		if radio:IsPlaying() then
			self:SetAlpha(255)
		else
			self:SetAlpha(0)
		end
	end

	local Title = vgui.Create( "DLabel", RadioContent )
	Title:SetPos( 20, 70 )
	Title:SetSize( RadioContent:GetWide()/2-25, 50 )
	Title:SetText( Radio.GetLanguage("Title : ")..radio:GetMusicTitle() )
	Title:SetTextColor(Radio.Color["text"])
	Title:SetFont("Radio.Menu")
	Title.Think = function(self)
		if radio:IsPlaying() then
			if radio:IsLive() then
				self:SetText( Radio.GetLanguage("Radio Internet") )
			else
				self:SetText( Radio.GetLanguage("Title : ")..radio:GetMusicTitle() )
			end

			self:SetAlpha(255)
		else
			self:SetAlpha(0)
		end
	end

	local Author = vgui.Create( "DLabel", RadioContent )
	Author:SetPos( 20, 90 )
	Author:SetSize( RadioContent:GetWide()/2-25, 50 )
	Author:SetText( Radio.GetLanguage("Author : ")..radio:GetMusicAuthor() )
	Author:SetTextColor(Radio.Color["text"])
	Author:SetFont("Radio.Menu")
	Author.Think = function(self)
		if radio:IsPlaying() and !radio:IsLive() then
			self:SetText( Radio.GetLanguage("Author : ")..radio:GetMusicAuthor() )

			self:SetAlpha(255)
		else
			self:SetAlpha(0)
		end
	end
	
	local SetURL
	if (radio:IsServer() and !Radio.Settings.ActivePresetOnlyServer) or (!radio:IsServer() and !Radio.Settings.ActivePresetOnlyRadio) then
		SetURL = vgui.Create( "DTextEntry", RadioContent )
		SetURL:SetPos( 5, 10 )
		SetURL:SetSize( RadioContent:GetWide()/2-10, 30 )
		SetURL:SetPlaceholderText("https://gmod-radio-numerix.mtxserv.com/exemple/Dennis%20Lloyd%20-%20NEVERMIND.mp3")
		SetURL:SetDrawLanguageID(false)
		SetURL:SetDrawBorder( false )
		SetURL:SetDrawBackground( false )
		SetURL:SetCursorColor( Radio.Color["text"] )
		SetURL:SetPlaceholderColor( Radio.Color["text_placeholder"] )
		SetURL:SetTextColor( Radio.Color["text"] )
		function SetURL:OnEnter()
			local url = self:GetValue()
			Radio.Play(url, ent)

			if IsValid(ServerList) then
				for k, line in pairs( ServerList:GetLines() ) do
					line:SetColumnText( 1, Radio.GetLanguage("No") )
				end
			end
		end
		function SetURL:Paint(w,h)
			if self:IsEditing() then
				draw.RoundedBox(10, 0, 0, w, h, Radio.Color["textentry_edit"])
			else
				draw.RoundedBox(10, 0, 0, w, h, Radio.Color["textentry_background"])
			end
            derma.SkinHook( "Paint", "TextEntry", self, w, h )
		end
	end

	if !radio:IsServer() then
		local connect = vgui.Create("Radio_Connect", RadioContent)
		connect:SetPos(RadioContent:GetWide()/2, 10)
		connect:SetSize(RadioContent:GetWide()/2 - 5, RadioContent:GetTall() - 10)
		connect:MakeContent(ent)
	else
		local server_settings = vgui.Create("Radio_Server_Settings", RadioContent)
		server_settings:SetPos(RadioContent:GetWide()/2, 10)
		server_settings:SetSize(RadioContent:GetWide()/2 - 5, RadioContent:GetTall() - 10)
		server_settings:MakeContent(ent)
	end
end
vgui.Register("Radio_Main", PANEL, "DPanel")