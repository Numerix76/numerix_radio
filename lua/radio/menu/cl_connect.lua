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
	local radio = ent:GetRadioComponent()
	if ( !radio ) then return end

	self.Paint = function(self, w, h) end

	local selectedServer
	local selectedPanel
	ServerList = vgui.Create( "DListView", self )
	ServerList:SetPos(0, 0)					
	ServerList:SetSize(self:GetWide(), self:GetTall()/1.08)
	ServerList:SetMultiSelect( false )
	ServerList:AddColumn( Radio.GetLanguage("Connected") ):SetFixedWidth(ServerList:GetWide()/6)
	ServerList:AddColumn( Radio.GetLanguage("Station" ) )
	ServerList:AddColumn( Radio.GetLanguage("Actual Title") )
	ServerList:AddColumn( Radio.GetLanguage("Actual Author") )
	ServerList.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Radio.Color["list_background"])
		surface.SetDrawColor( color_white )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end
	ServerList.OnRequestResize = function() return end

	ServerList.VBar.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Radio.Color["scroll_background"] )
	end
	ServerList.VBar.btnUp.Paint = function( s, w, h ) 
		draw.RoundedBox( 0, 0, 0, w, h, Radio.Color["scroll_button"] )
	end
	ServerList.VBar.btnDown.Paint = function( s, w, h ) 
		draw.RoundedBox( 0, 0, 0, w, h, Radio.Color["scroll_button"] )
	end
	ServerList.VBar.btnGrip.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Radio.Color["scroll_bar"] )
	end

	for _, server in ipairs(ents.FindByClass("numerix_radio_component")) do
		if !IsValid(server) then continue end
		if !server:IsServer() then continue end
		
		local pnl = ServerList:AddLine(server == radio:GetController() and Radio.GetLanguage("Yes") or Radio.GetLanguage("No"), server:GetServerName(), server:GetMusicTitle(), server:GetMusicAuthor())
		pnl.server = server
	end
	
	for _, columns in ipairs(ServerList.Columns) do
		columns.Header:SetTextColor(Radio.Color["text"])
		columns.Header.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Radio.Color["button_background"])
		
			surface.SetDrawColor( Radio.Color["button_line"] )
			surface.DrawOutlinedRect( 0, 0, w+1, h )
		end
	end

	for k, line in ipairs( ServerList:GetLines() ) do
		for _, columns in ipairs(line.Columns) do
			columns:SetTextColor(Radio.Color["text"])
		end
	end

	ServerList.OnRowSelected = function( lst, index, pnl )
		selectedServer = pnl.server
		selectedPanel = pnl
	end
	
	local Connect = vgui.Create( "DButton", self )		
	Connect:SetPos( 0, self:GetTall()/1.08 + 5 )
	Connect:SetText( Radio.GetLanguage("Connect") )
	Connect:SetToolTip( Radio.GetLanguage("Connect") )
	Connect:SetFont("Radio.Button")
	Connect:SetTextColor( Radio.Color["text"] )
	Connect:SetSize( self:GetWide()/2-5, self:GetTall() - self:GetTall()/1.08 - 5 )
	Connect.Paint = function( self, w, h )
		draw.RoundedBox(5, 0, 0, w, h, Radio.Color["button_background"])

		if self:IsHovered() or self:IsDown() then
			draw.RoundedBox( 5, 0, 0, w, h, Radio.Color["button_hover"] )
		end
	end
	Connect.DoClick = function()
		if !IsValid(selectedServer) then return end
		
		net.Start("Radio:ConnectRadio")
		net.WriteEntity(ent)
		net.WriteEntity(selectedServer:GetParent())
		net.SendToServer()

		for k, line in ipairs( ServerList:GetLines() ) do
			line:SetColumnText( 1, Radio.GetLanguage("No") )
		end

		selectedPanel:SetColumnText( 1, Radio.GetLanguage("Yes") )
	end

	local Disconnect = vgui.Create( "DButton", self )		
	Disconnect:SetPos( self:GetWide()/2 + 5,  self:GetTall()/1.08 + 5 )
	Disconnect:SetText( Radio.GetLanguage("Disconnect") )
	Disconnect:SetToolTip( Radio.GetLanguage("Disconnect") )
	Disconnect:SetFont("Radio.Button")
	Disconnect:SetTextColor( Radio.Color["text"] )
	Disconnect:SetSize( self:GetWide()/2-5, self:GetTall() - self:GetTall()/1.08 - 5 )
	Disconnect.Paint = function( self, w, h )
		draw.RoundedBox(5, 0, 0, w, h, Radio.Color["button_background"])
			
		if self:IsHovered() or self:IsDown() then
			draw.RoundedBox( 5, 0, 0, w, h, Radio.Color["button_hover"] )
		end
	end
	Disconnect.DoClick = function()
		net.Start("Radio:ConnectRadio")
		net.WriteEntity(ent)
		net.WriteEntity(nil)
		net.SendToServer()
		
		for k, line in ipairs( ServerList:GetLines() ) do
			line:SetColumnText( 1, Radio.GetLanguage("No") )
		end
	end
end
vgui.Register("Radio_Connect", PANEL, "DPanel")