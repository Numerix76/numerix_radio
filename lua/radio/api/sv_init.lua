--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]
local baseUri = "http://81.16.177.58:3000"
local baseUriWS = "ws://81.16.177.58:3000"
local ensFunctions, ensFunctionsDegrade

local forceDegradeMode = false
if !Radio.Settings.DegradeMode then
	if util.IsBinaryModuleInstalled("gwsockets") then
		require("gwsockets")
	else
		MsgC( Color( 225, 20, 30 ), "[Radio]", Color(255,255,255), " Passing into a degraded mode.\n")
		Radio.Settings.DegradeMode = true
		forceDegradeMode = true
	end
end

hook.Add("PlayerInitialSpawn", "Radio:PlayerInitialSpawnCheckGWSocket", function(ply)
	if ply:IsSuperAdmin() and forceDegradeMode then
		timer.Simple(10, function()
			ply:RadioChatInfo(Radio.GetLanguage("The module GWSocket is not present on the server"), 3)
		end)
	end
end)

local function errorRadio(ply, ent, data)
	if ent.socket then
		ent.socket:close()
	end

	ent:SetNWString( "Radio:Info", Radio.GetLanguage("An error occured. Check the message in chat") )
	Radio.Error(ply, data.message)

	ent.isloading = false

	if ( data.log ) then
		Radio.Error(ply, Radio.GetLanguage("Logs") .. " : " .. data.log)
	end
end

local function connectWebsite(ply, ent, url)
	ent:SetNWString( "Radio:Info", Radio.GetLanguage("Conversion on the backend (this can take some time)"))
	
	http.Fetch(baseUri .. "/get/mp3/degrade", 
		function(body)
			for _, data in pairs(util.JSONToTable(body)) do
				if ensFunctionsDegrade[data.type] then
					ensFunctionsDegrade[data.type](ply, ent, data)
				end
			end
		end,
		function(errorMessage)
			errorRadio(ply, ent, {message = string.format(Radio.GetLanguage("Can't connect to the backend or the conversion take too long. (%s)"), errorMessage) })
		end,

		{url = url}
	)
end

local function upload(ply, ent, youtubeURL, fileData, callback)
	ent:SetNWString( "Radio:Info", Radio.GetLanguage("Starting the upload of the video to the backend."))

	HTTP({
		method = "POST",
		url = baseUri .. "/upload?url=" .. youtubeURL,
		body = fileData,
		success = function(code, body)
			if ( code != 200 ) then
				errorRadio(ply, ent, {message = string.format(Radio.GetLanguage("An error occured while uploading the file. (%s)"), code) })
				return 
			end
	
			if ( callback ) then
				callback(ply, ent, youtubeURL)
			end
		end,
		failed = function(message) 
			errorRadio(ply, ent, {message = string.format(Radio.GetLanguage("An error occured while uploading the file. (%s)"), message) })
		end
	})
end

local function download(ply, ent, googleURL, youtubeURL)
	ent:SetNWString( "Radio:Info", Radio.GetLanguage("Downloading the video on the server.") )
	
	http.Fetch(googleURL,
		-- onSuccess function
		function( body, length, headers, code )
			if ( code == 403 ) then
				errorRadio(ply, ent, {message = Radio.GetLanguage("The server IP seems to be banned from the google video services. Please contact the server owner.") })
				return
			end

			if ( code != 200 ) then
				errorRadio(ply, ent, {message = string.format(Radio.GetLanguage("An error occured while downloading the file. (%s)"), code) })
				return 
			end

			local fileData = body

			if ( Radio.Settings.DegradeMode ) then
				upload(ply, ent, youtubeURL, fileData, connectWebsite)
			else
				upload(ply, ent, youtubeURL, fileData, function(ply, ent, youtubeURL)
					ent.socket:write("upload_finished")
				end)
			end
		end,

		-- onFailure function
		function( message )
			errorRadio(ply, ent, {message = string.format(Radio.GetLanguage("An error occured while downloading the file. (%s)"), message) })
		end
	)
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

local function download_url(ply, ent, data)
	download(ply, ent, data.googleURL, data.youtubeURL)
end

local function download_started(ply, ent, data)
	ent:SetNWString( "Radio:Info", Radio.GetLanguage("Starting download") )
end

local function download_progress(ply, ent, data)
	if ( data.percent ) then
		ent:SetNWString( "Radio:Info", string.format(Radio.GetLanguage("Download progress"), data.percent) )
	end
end

local function download_finished(ply, ent, data)
	ent:SetNWString( "Radio:Info", Radio.GetLanguage("Finished download") )
end

local function conversion_started(ply, ent, data)
	ent:SetNWString( "Radio:Info", Radio.GetLanguage("Starting conversion") )
end

local function conversion_progress(ply, ent, data)
	if ( data.percent ) then
		ent:SetNWString( "Radio:Info", string.format(Radio.GetLanguage("Conversion progress"), data.percent) )
	end
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

	ent:SetNWString( "Radio:Info", "")
	ent.isloading = false

	if ent.live then
		ent:SetNWString( "Radio:Mode", "3")
	end
end



local function connectWebsocket(ply, ent, url)
	ent:SetNWString( "Radio:Info", Radio.GetLanguage("Connection to the backend"))

	ent.socket = GWSockets.createWebSocket( baseUriWS .."/get/mp3" )

	function ent.socket:onMessage(txt)
		local data = util.JSONToTable(txt)

		if ensFunctions[data.type] then
			ensFunctions[data.type](ply, ent, data)
		end
	end
	
	function ent.socket:onError(txt)
		errorRadio(ply, ent, {message = txt})
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
	["download_url"] = download_url,
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
	["download_url"] = download_url,
	["finished"] = finished,
	["error"] = errorRadio,
}