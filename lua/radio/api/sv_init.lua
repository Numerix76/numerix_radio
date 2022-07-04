--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]

local gwsocketsExist = file.Exists("bin/gmsv_gwsockets_*.dll", "LUA")

if gwsocketsExist then
	require("gwsockets")
end

hook.Add("PlayerInitialSpawn", "Radio:PlayerInitialSpawnCheckGWSocket", function(ply)
	if ply:IsSuperAdmin() and !gwsocketsExist then
		timer.Simple(10, function()
			ply:RadioChatInfo(Radio.GetLanguage("The module GWSocket is not present on the server"), 3)
		end)
	end
end)

local ensFunctions
function Radio.SetMusic(ply, ent, url)
	if ent.isloading then return end

	ent.isloading = true

	ent:SetNWString( "Radio:URL", "")
    ent:SetNWString( "Radio:Mode", "0")
    ent:SetNWString( "Radio:Info", Radio.GetLanguage("Connection to the backend"))

	ent.socket = GWSockets.createWebSocket( "ws://92.222.234.121:3000/get/mp3" )

	function ent.socket:onMessage(txt)
		local data = util.JSONToTable(txt)

		ensFunctions[data.type](ply, ent, data)
	end
	
	function ent.socket:onError(txt)
		error(ply, ent, {message = txt})
		ent.isloading = false
	end
	
	function ent.socket:onConnected()
		ent.socket:write(url)
	end
	
	function ent.socket:onDisconnected()
		ent:SetNWString( "Radio:Info", "")
		ent.isloading = false
	end

	ent.socket:open()
end

local function infos_music(ply, ent, data)
	if data.duration > Radio.Settings.MaxDuration then
		if ent.socket then
			ent.socket:close()
		end

		Radio.Error(ply, string.format(Radio.GetLanguage("The duration of the sound is too big. Max : %s"), Radio.SecondsToClock(Radio.Settings.MaxDuration) ) )

		return
	end

    ent:SetNWString( "Radio:Title", data.title)
	ent:SetNWString( "Radio:Author", data.artist)
	ent:SetNWString( "Radio:Thumbnail", data.thumbnail)

	ent.live = data.live
	ent.duration = data.duration -- we need to sent the duration after the Radio:URL
end

local function download_started(ply, ent, data)
	ent:SetNWString( "Radio:Info", Radio.GetLanguage("Starting download") )
end

local function download_progress(ply, ent, data)
	ent:SetNWString( "Radio:Info", string.format(Radio.GetLanguage("Download progress"), data.percent) )
end

local function download_finished(ply, ent, data)
	ent:SetNWString( "Radio:Info", Radio.GetLanguage("Finished download") )
end

local function conversion_started(ply, ent, data)
	ent:SetNWString( "Radio:Info", Radio.GetLanguage("Starting conversion") )
end

local function conversion_progress(ply, ent, data)
	ent:SetNWString( "Radio:Info", string.format(Radio.GetLanguage("Conversion progress"), data.percent) )
end

local function conversion_finished(ply, ent, data)
	ent:SetNWString( "Radio:Info", Radio.GetLanguage("Finished conversion") )
end

local function finished(ply, ent, data)
	if ent.socket then
		ent.socket:close()
	end

	ent:SetNWString( "Radio:URL", data.url)
	ent:SetNWInt   ( "Radio:Duration", ent.duration)
	ent:SetNWString( "Radio:Mode", "1")
	ent:SetNWInt   ( "Radio:Time", CurTime())

	if ent.live then
		ent:SetNWString( "Radio:Mode", "3")
	end
end

local function error(ply, ent, data)
	if ent.socket then
		ent.socket:close()
	end

	ent:SetNWString( "Radio:Info", Radio.GetLanguage("An error occured. Check the message in chat") )
	Radio.Error(ply, data.message)

	if ( data.log ) then
		Radio.Error(ply, Radio.GetLanguage("Logs") .. " : " .. data.log)
	end
end

--Need to set it after all functions have been created
ensFunctions = {
	["infos_music"] = infos_music,
	["download_started"] = download_started,
	["download_progress"] = download_progress,
	["download_finished"] = download_finished,
	["conversion_started"] = conversion_started,
	["conversion_progress"] = conversion_progress,
	["conversion_finished"] = conversion_finished,
	["finished"] = finished,
	["error"] = error,
}