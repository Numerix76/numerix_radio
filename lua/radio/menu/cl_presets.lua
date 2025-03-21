--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]
local PANEL = {}

function PANEL:Init()   
end

function PANEL:PerformLayout(width, height)
	self:SetSize(width, height)
end

function PANEL:MakeContent(ent, type)
	self.Paint = function(s, w, h) end

	local RadioScroll = vgui.Create( "DScrollPanel", self )
	RadioScroll:SetPos(5, 60)
	RadioScroll:SetSize(self:GetWide() - 10, self:GetTall() - 60)
	RadioScroll.VBar.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Radio.Color["scroll_background"] )
	end
	RadioScroll.VBar.btnUp.Paint = function( s, w, h ) 
		draw.RoundedBox( 0, 0, 0, w, h, Radio.Color["scroll_button"] )
	end
	RadioScroll.VBar.btnDown.Paint = function( s, w, h ) 
		draw.RoundedBox( 0, 0, 0, w, h, Radio.Color["scroll_button"] )
	end
	RadioScroll.VBar.btnGrip.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Radio.Color["scroll_bar"] )
	end
	
	local wide = table.Count(Radio.Settings.Preset)/4*30 > RadioScroll:GetTall() and RadioScroll:GetWide() or RadioScroll:GetWide() - 15
	
	local PresetList = vgui.Create( "DIconLayout", RadioScroll )
	PresetList:Dock( FILL )
	PresetList:SetSpaceY( 10 )
	PresetList:SetSpaceX( 10 )
	PresetList:SetSize(RadioScroll:GetWide(), self:GetTall()/2 - 10)

	for url, name in pairs(Radio.Settings.Preset) do

		local base = PresetList:Add("DPanel")
		base:SetPos(0,0)
		base:SetSize(wide/4.05-5, 90)
		base:SetContentAlignment(5)
		base.Paint = function(s, w, h) end
		
		local title = vgui.Create("DLabel", base)
		title:SetText(name)
		title:SetTextColor(Radio.Color["text"])
		title:SetFont("Radio.Video.Info")
		title:SetPos(0, 0)
		title:SetSize(base:GetWide(), 20)
		title:SetContentAlignment(8)

		local ChangeMusic = vgui.Create("DButton", base )		
		ChangeMusic:SetPos( 5, 30 )
		ChangeMusic:SetText( Radio.GetLanguage("Play") )
		ChangeMusic:SetToolTip( Radio.GetLanguage("Play") )
		ChangeMusic:SetFont("Radio.Button")
		ChangeMusic:SetTextColor( Radio.Color["text"] )
		ChangeMusic:SetSize( base:GetWide() - 5 , 25 )
		ChangeMusic.Paint = function( self, w, h )
			draw.RoundedBox(5, 0, 0, w, h, Radio.Color["button_background"])
			
			if self:IsHovered() or self:IsDown() then
				draw.RoundedBox( 5, 0, 0, w, h, Radio.Color["button_hover"] )
			end
		end
		ChangeMusic.DoClick = function()
			Radio.Play(url, ent)
		end
	
	end
end
vgui.Register("Radio_Preset", PANEL, "DPanel")