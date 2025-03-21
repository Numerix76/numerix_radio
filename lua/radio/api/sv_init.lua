--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]
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
			ply:RadioChatInfo(Radio.GetLanguage("The module GWSocket is not present on the server"), Radio.Chat.ERROR)
		end)
	end
end)

local function infos_music(socket, data, successCallback, failedCallback, dataCallback, progressCallback)
	if data.duration > Radio.Settings.MaxDuration then
		if socket then
			socket:close()
		end

		if ( isfunction(failedCallback) ) then
			failedCallback({message = string.format(Radio.GetLanguage("The duration of the sound is too big. Max : %s"), Radio.SecondsToClock(Radio.Settings.MaxDuration))})
		end

		return
	end

	if ( isfunction(dataCallback) ) then
		dataCallback(data)
	end
end

local function download_started(socket, data, successCallback, failedCallback, dataCallback, progressCallback)
	if ( !isfunction(progressCallback) ) then return end

	progressCallback(Radio.GetLanguage("Starting download"))
end

local function download_progress(socket, data, successCallback, failedCallback, dataCallback, progressCallback)
	if ( !isfunction(progressCallback) ) then return end
	if ( !data.percent ) then return end

	progressCallback(string.format(Radio.GetLanguage("Download progress"), data.percent))
end

local function download_finished(socket, data, successCallback, failedCallback, dataCallback, progressCallback)
	if ( !isfunction(progressCallback) ) then return end

	progressCallback(Radio.GetLanguage("Finished download"))
end

local function conversion_started(socket, data, successCallback, failedCallback, dataCallback, progressCallback)
	if ( !isfunction(progressCallback) ) then return end

	progressCallback(Radio.GetLanguage("Starting conversion"))
end

local function conversion_progress(socket, data, successCallback, failedCallback, dataCallback, progressCallback)
	if ( !isfunction(progressCallback) ) then return end
	if ( !data.percent ) then return end

	progressCallback(string.format(Radio.GetLanguage("Conversion progress"), data.percent))
end

local function conversion_finished(socket, data, successCallback, failedCallback, dataCallback, progressCallback)
	if ( !isfunction(progressCallback) ) then return end

	progressCallback(Radio.GetLanguage("Finished conversion"))
end

local function finished(socket, data, successCallback, failedCallback, dataCallback, progressCallback)
	if socket then
		socket:close()
	end

	if ( isfunction(successCallback) ) then
		successCallback(data.url)
	end
end

local function error(socket, data, successCallback, failedCallback, dataCallback, progressCallback)
	if socket then
		socket:close()
	end

	if ( isfunction(failedCallback) ) then
		failedCallback(data)
	end
end

local function conversion_finished(socket, data, successCallback, failedCallback, dataCallback, progressCallback)
	if ( !isfunction(progressCallback) ) then return end

	progressCallback(Radio.GetLanguage("Finished conversion"))
end

local function connectWebsite(url, ply, successCallback, failedCallback, dataCallback, progressCallback)
	if ( isfunction(progressCallback) ) then
		progressCallback(Radio.GetLanguage("Conversion on the backend (this can take some time)"));
	end
	
	http.Fetch("http://" .. Radio.Settings.BackEnd .. "/get/mp3/degrade", 
		function(body)
			for _, data in pairs(util.JSONToTable(body)) do
				if ensFunctionsDegrade[data.type] then
					ensFunctionsDegrade[data.type](nil, data, successCallback, failedCallback, dataCallback, progressCallback)
				end
			end
		end,
		function(errorMessage)
			if ( isfunction(failedCallback) ) then
				failedCallback({message = string.format(Radio.GetLanguage("Can't connect to the backend or the conversion take too long. (%s)"), errorMessage)});
			end
		end,
		{url = url}
	)
end

local function connectWebsocket(url, ply, successCallback, failedCallback, dataCallback, progressCallback)
	if ( isfunction(progressCallback) ) then
		progressCallback(Radio.GetLanguage("Connection to the backend"));
	end

	local socket = GWSockets.createWebSocket( "ws://" .. Radio.Settings.BackEnd ..  .."/get/mp3" )

	function socket:onMessage(txt)
		local data = util.JSONToTable(txt)

		if ensFunctions[data.type] then
			ensFunctions[data.type](socket, data, successCallback, failedCallback, dataCallback, progressCallback)
		end
	end
	
	function socket:onError(txt)
		if ( socket ) then
			socket:Close()
		end

		if ( isfunction(failedCallback) ) then
			failedCallback({message = txt});
		end
	end
	
	function socket:onConnected()
		socket:write(url)
	end

	socket:open()
end

function Radio.GetFinalURL(url, ply, successCallback, failedCallback, dataCallback, progressCallback)
	if ( Radio.Settings.DegradeMode ) then
		connectWebsite(url, ply, successCallback, failedCallback, dataCallback, progressCallback)
	else
		connectWebsocket(url, ply, successCallback, failedCallback, dataCallback, progressCallback)
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
	["error"] = error,
}

ensFunctionsDegrade = {
	["infos_music"] = infos_music,
	["download_url"] = download_url,
	["finished"] = finished,
	["error"] = error,
}