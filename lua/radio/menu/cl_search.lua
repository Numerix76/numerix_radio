--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]
Radio.Search = {
	{}, -- YouTube
	{}, -- SoundCloud
}


local PANEL = {}

function PANEL:Init()   
end

function PANEL:PerformLayout(width, height)
    self:SetSize(width, height)
end

function PANEL:MakeContent(ent, type)
	local RadioContent = self

    self.Paint = function(self, w, h) end

    local SetURL = vgui.Create( "DTextEntry", self )
	SetURL:SetPos( self:GetWide()/4, 10 )
	SetURL:SetSize( RadioContent:GetWide()/2, 30 )
	SetURL:SetPlaceholderText(Radio.GetLanguage("Search"))
	SetURL:SetDrawLanguageID(false)
	SetURL:SetDrawBorder( false )
	SetURL:SetDrawBackground( false )
	SetURL:SetCursorColor( Radio.Color["text"] )
	SetURL:SetPlaceholderColor( Radio.Color["text_placeholder"] )
	SetURL:SetTextColor( Radio.Color["text"] )
	function SetURL:OnEnter()
		Radio.GetSearch(type, self:GetValue(), RadioContent, ent)
	end
	function SetURL:Paint(w,h)
		if self:IsEditing() then
			draw.RoundedBox(10, 0, 0, w, h, Radio.Color["textentry_edit"])
		else
			draw.RoundedBox(10, 0, 0, w, h, Radio.Color["textentry_background"])
		end
		derma.SkinHook( "Paint", "TextEntry", self, w, h )
	end

	Radio.ReloadMenu(RadioContent, type, ent)
end
vgui.Register("Radio_Search", PANEL, "DPanel")

local RadioScroll
function Radio.ReloadMenu(menu, type, ent, error)
	local data = Radio.Search[type]
	
	if !IsValid(menu) then return end
	
	if ispanel(RadioScroll) then
		RadioScroll:Remove()
	end

	RadioScroll = vgui.Create( "DScrollPanel", menu )
    RadioScroll:SetPos(5, 60)
	RadioScroll:SetSize(menu:GetWide() - 10, menu:GetTall() - 60)
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
	
	menu.Paint = function(self, w, h)
		if error then
			draw.SimpleText(Radio.GetLanguage("An error occured. Check the message in chat"), "Radio.Menu", w/2, h/2, Radio.Color["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		elseif table.Count(data) < 1 then
			draw.SimpleText(Radio.GetLanguage("No result"), "Radio.Menu", w/2, h/2, Radio.Color["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	
	if error then return end
    
    local PresetList = vgui.Create( "DIconLayout", RadioScroll )
    PresetList:Dock( FILL )
    PresetList:SetSpaceY( 30 )
    PresetList:SetSpaceX( 10 )
	PresetList:SetSize(RadioScroll:GetWide(), menu:GetTall()/2 - 10)
	
	for k, v in ipairs(data) do
		local base = PresetList:Add("DPanel")
		base:SetPos(0,0)
		base:SetSize(PresetList:GetWide()/2.05-5, 90)
		base.Paint = function(s, w, h) end

		local icon = vgui.Create("DImage", base)
		icon:SetPos(0, 0)
		icon:SetSize(base:GetWide()/5, base:GetTall())
		icon:SetImage("vgui/avatar_default")

		if v.thumbnail then					
			Radio.GetImage(v.thumbnail, v.id..".jpg", function(url, filename)
				if !IsValid(base) then return end
				
				icon:SetImage(filename)
			end)
		end
		
		local title = vgui.Create("DLabel", base)
		title:SetText(v.title)
		title:SetTextColor(Radio.Color["text"])
		title:SetFont("Radio.Video.Info")
		title:SetPos(base:GetWide()/5 + 10, 0)
		title:SetSize(base:GetWide() - base:GetWide()/5 - 10, 20)
		
		local author = vgui.Create("DLabel", base)
		author:SetText(v.artist)
		author:SetTextColor(Radio.Color["text"])
		author:SetFont("Radio.Video.Info")
		author:SetPos(base:GetWide()/5 + 10, 20)
		author:SetSize(base:GetWide() - base:GetWide()/5 - 10, 20)

        local ChangeMusic = vgui.Create("DButton", base )		
        ChangeMusic:SetPos( base:GetWide()/5 + 10, 65 )
        ChangeMusic:SetText( Radio.GetLanguage("Play") )
        ChangeMusic:SetToolTip( Radio.GetLanguage("Play") )
        ChangeMusic:SetFont("Radio.Button")
        ChangeMusic:SetTextColor( Radio.Color["text"] )
		ChangeMusic:SetSize( base:GetWide()/4, 25 )
        ChangeMusic.Paint = function( self, w, h )
            draw.RoundedBox(5, 0, 0, w, h, Radio.Color["button_background"])
            
            if self:IsHovered() or self:IsDown() then
                draw.RoundedBox( 5, 0, 0, w, h, Radio.Color["button_hover"] )
            end
        end
		ChangeMusic.DoClick = function()
    		Radio.Play(v.url, ent)
		end
	end
	
	if !table.IsEmpty( data ) then return end
	menu.Paint = function(self, w, h)
		draw.SimpleText(Radio.GetLanguage("No result"), "Radio.Menu", w/2, h/2, Radio.Color["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function toURI(c)	
	return string.format ("%%%02X", string.byte(c))
end
 
function Radio.GetSearch(type, search, menu, ent)
	search = string.Replace( string.gsub(search, "([^%w ])", toURI), " ", "%20")

	http.Fetch("http://" .. Radio.Settings.BackEnd .. "/search/".. (type == 1 and "youtube" or "soundcloud").. "/" ..search, 
		function( body, len, headers, code )
			local data = util.JSONToTable(body)

			if istable(data) and !data.error then
				Radio.Search[type] = data
				Radio.ReloadMenu(menu, type, ent)
			else
				Radio.Search[type] = {}
				Radio.Error(LocalPlayer(), Radio.GetLanguage("An error occurred while retrieving the data. Contact an administrator if this persists."))
				Radio.Error(LocalPlayer(), data.error)
				
				Radio.ReloadMenu(menu, type, ent, true)
			end
		end, 
		function( error )
			Radio.Search[type] = {}
			Radio.Error(LocalPlayer(), string.format(Radio.GetLanguage("An error occurred while retrieving the data. Contact an administrator if this persists. Error : %s"), error))

			Radio.ReloadMenu(menu, type, ent, true)
		end
	)

	if ispanel(RadioScroll) then
		RadioScroll:Remove()
	end

	menu.Paint = function(self, w, h)
	    draw.SimpleText(Radio.GetLanguage("Searching..."), "Radio.Menu", w/2, h/2, Radio.Color["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end