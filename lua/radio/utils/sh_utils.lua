--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]

function Radio.SecondsToClock(seconds)
    local seconds = tonumber(seconds)
  
    if seconds <= 0 then
      return "00:00:00";
    else
        hours = string.format("%02.f", math.floor(seconds/3600));
        mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
        secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
        return hours..":"..mins..":"..secs
    end
end

function Radio.Error(ply, message)
	ply:RadioChatInfo(message, 3) 

	if Radio.Settings.Debug then
		ply:RadioChatInfo(Radio.GetLanguage("Check your console to have a debug trace"), 3) 
		ply:PrintMessage( 2, Radio.Trace() )
	end
end

function Radio.Trace()
	local level = 3
	local msg = ""

	msg = msg.."\nTrace:\n"

	while true do

		local info = debug.getinfo( level, "Sln" )
		if ( !info ) then break end

		if ( info.what ) == "C" then
			msg = msg..string.format( "\t%i: C function\t\"%s\"\n", level, info.name )
		else
			msg = msg..string.format( "\t%i: Line %d\t\"%s\"\t\t%s\n", level, info.currentline, info.name, info.short_src )
		end

		level = level + 1

	end

	msg = msg.."\n"

	return msg
end