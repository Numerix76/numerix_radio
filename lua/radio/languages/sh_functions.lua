--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]

function Radio.GetLanguage(sentence)
	if Radio.Language[Radio.Settings.Language] and Radio.Language[Radio.Settings.Language][sentence] then
		return Radio.Language[Radio.Settings.Language][sentence]
	else
		return Radio.Language["default"][sentence]
	end
end