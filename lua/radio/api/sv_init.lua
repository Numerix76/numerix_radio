--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]

local forceDegradeMode = false
if !Radio.Settings.DegradeMode then
	xpcall(require, 
		function(err)
			MsgC( Color( 225, 20, 30 ), "[Radio]", Color(255,255,255), " Passing into a degraded mode.\n")
			Radio.Settings.DegradeMode = true
			forceDegradeMode = true
		end,
		"gwsockets"
	)
end

hook.Add("PlayerInitialSpawn", "Radio:PlayerInitialSpawnCheckGWSocket", function(ply)
	if ply:IsSuperAdmin() and forceDegradeMode then
		timer.Simple(10, function()
			ply:RadioChatInfo(Radio.GetLanguage("The module GWSocket is not present on the server"), 3)
		end)
	end
end)

local ensFunctions, ensFunctionsDegrade
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

local function errorRadio(ply, ent, data)
	if ent.socket then
		ent.socket:close()
	end

	ent:SetNWString( "Radio:Info", Radio.GetLanguage("An error occured. Check the message in chat") )
	Radio.Error(ply, data.message)

	if ( data.log ) then
		Radio.Error(ply, Radio.GetLanguage("Logs") .. " : " .. data.log)
	end
end

local function connectWebsite(ply, ent, url)
	ent:SetNWString( "Radio:Info", Radio.GetLanguage("Conversion on the backend (this can take some time)"))
	
	http.Fetch("http://92.222.234.121:3000/get/mp3/degrade", 
		function(body)
			for _, data in pairs(util.JSONToTable(body)) do
				if ensFunctionsDegrade[data.type] then
					ensFunctionsDegrade[data.type](ply, ent, data)
				end
			end

			ent:SetNWString( "Radio:Info", "")
			ent.isloading = false
		end,
		function(errorMessage)
			errorRadio(ply, ent, {message = string.format(Radio.GetLanguage("Can't connect to the backend or the conversion take too long. (%s)"), errorMessage) })
			ent.isloading = false
		end,

		{url = url}
	)
end

local function connectWebsocket(ply, ent, url)
	ent:SetNWString( "Radio:Info", Radio.GetLanguage("Connection to the backend"))

	ent.socket = GWSockets.createWebSocket( "ws://92.222.234.121:3000/get/mp3" )

	function ent.socket:onMessage(txt)
		local data = util.JSONToTable(txt)

		if ensFunctions[data.type] then
			ensFunctions[data.type](ply, ent, data)
		end
	end
	
	function ent.socket:onError(txt)
		errorRadio(ply, ent, {message = txt})
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

function Radio.SetMusic(ply, ent, url)
	if ent.isloading then return end

	ent.isloading = true

	ent:SetNWString( "Radio:URL", "")
    ent:SetNWString( "Radio:Mode", "0")

	if ( Radio.Settings.DegradeMode ) then
		connectWebsite(ply, ent, url)
	else
		connectWebsocket(ply, ent, url)
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
	["error"] = errorRadio,
}

ensFunctionsDegrade = {
	["infos_music"] = infos_music,
	["finished"] = finished,
	["error"] = errorRadio,
}