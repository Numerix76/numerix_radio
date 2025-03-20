--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]

function Radio.Play(url, ent)
	url = string.Replace(url, " ", "")
	if url == "" then return end

	if string.len(url) > 512 then
		LocalPlayer():RadioChatInfo(Radio.GetLanguage("URL too long (max: 512 characters)."), Radio.Chat.ERROR)
		return
	end

	net.Start("Radio:SetMusic")
	net.WriteEntity(ent)
	net.WriteString(url)
	net.SendToServer()
end