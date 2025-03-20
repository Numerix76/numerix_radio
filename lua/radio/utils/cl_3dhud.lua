--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]

local ENT = FindMetaTable("Entity")

local p
local prevFrame = {}
local bar = 128
local color
function Radio.Draw3DInfo(ent, InfoTable)
	if LocalPlayer():GetPos():DistToSqr( ent:GetPos() ) > 400^2 then return end

	local bar_w = math.Round(InfoTable.InfoMaxWFFT/(bar+1))
	local radio = ent:GetRadioComponent()

	if ( !radio ) then return end

	if !ent:IsWeapon() then
		p = ent:GetPos()
		p = p + ent:GetForward() * InfoTable.InfoPos.x
		p = p + ent:GetRight() * InfoTable.InfoPos.y
		p = p + ent:GetUp() * InfoTable.InfoPos.z
		p = p + ent:GetForward() * -1

		a = ent:GetAngles()
		a:RotateAroundAxis( a:Up(), InfoTable.InfoAng.y )
		a:RotateAroundAxis( a:Right(), InfoTable.InfoAng.p)
		a:RotateAroundAxis( a:Forward(), InfoTable.InfoAng.r )
	else
		p = InfoTable.InfoPos
		a = InfoTable.InfoAng
	end

	color = radio:GetVisualColor()

	if InfoTable.InfoBlackPosX then
		cam.Start3D2D( p + ent:GetForward() * InfoTable.InfoBlackPosBack, a, InfoTable.InfoOffsetText );
			surface.SetDrawColor(color_black)
			surface.DrawRect(InfoTable.InfoBlackPosX, InfoTable.InfoBlackPosY, InfoTable.InfoBlackPosW, InfoTable.InfoBlackPosH)
		cam.End3D2D()
	end

	local station = radio:GetStation()
	--Draw FFT vizualizer
	if station and IsValid(station) then
		cam.Start3D2D( p, a, InfoTable.InfoOffsetFFT )
			if !ent.FTT then
				ent.FTT = {}
			end
			
			if( station:GetState() == GMOD_CHANNEL_PLAYING ) then
				station:FFT(ent.FTT, FFT_256)
			
				surface.SetDrawColor(color)
			
				for i = 1, bar do
					if (i-1) * (bar_w+10) + bar_w > InfoTable.InfoMaxWFFT then
						break
					end

					if not prevFrame[i] then prevFrame[i] = 0 end
					prevFrame[i] = math.Clamp(Lerp(2.5 * FrameTime(), prevFrame[i], -ent.FTT[i] * 1000 * radio:GetVolume()), -InfoTable.InfoMaxHFFT, 0 )

					if radio:IsRainbow() then
						local c = HSVToColor( i * 360 / bar, 1, 1 );
						surface.SetDrawColor( c ); --Rainbow 
					end
					surface.DrawRect((i-1) * (bar_w+10) + InfoTable.InfoPosXFFT, InfoTable.InfoPosYFFT, bar_w, prevFrame[i])
				end
			end
		cam.End3D2D()
	end

	cam.Start3D2D( p, a, InfoTable.InfoOffsetText );

		surface.SetFont( "Radio.Video.Info" )

		if radio:GetInformation() != "" then
			surface.SetTextColor( Radio.Color["text_info"] )
			surface.SetTextPos( InfoTable.InfoPosXText, InfoTable.InfoPosYTextError )
			surface.DrawText( radio:GetInformation() )	
		elseif station and IsValid(station) then
			surface.SetTextColor( Radio.Color["text"] )
			surface.SetTextPos( InfoTable.InfoPosXText, InfoTable.InfoPosYText )

			local Title = radio:GetMusicTitle()
			local w, _ = surface.GetTextSize( Title );
			if( w > InfoTable.InfoMaxWText ) then

				for i = string.len( Title ), 1, -1 do

					w, _ = surface.GetTextSize( string.sub( Title, 1, i ) );
					if( w <= InfoTable.InfoMaxWText + 20 ) then

						surface.DrawText( string.sub( Title, 1, i ) .. "..." );
						break;

					end

				end

			else
				surface.DrawText( Title );
			end

			surface.SetTextPos( InfoTable.InfoPosXText, InfoTable.InfoPosYText + 20 )

			local Author = radio:GetMusicAuthor()
			local w, _ = surface.GetTextSize( Author );
			if( w > InfoTable.InfoMaxWText ) then

				for i = string.len( Author ), 1, -1 do

					local w, _ = surface.GetTextSize( string.sub( Author, 1, i ) );
					if( w <= InfoTable.InfoMaxWText + 20 ) then

						surface.DrawText( string.sub( Author, 1, i ) .. "..." );
						break;

					end

				end

			else
				surface.DrawText( Author );
			end

			if radio:GetMusicDuration() != 0 then
				if !radio:IsLive() then
					surface.SetDrawColor(color)
					surface.DrawRect( InfoTable.InfoPosXTimeBar, InfoTable.InfoPosYTimeBar, InfoTable.InfoMaxWTimeBar*radio:GetCurrentTime(false)/radio:GetMusicDuration(), 5)
				else
					surface.SetTextColor( Radio.Color["text"] )
					surface.SetTextPos( InfoTable.InfoPosXText, InfoTable.InfoPosYTextError )
					surface.DrawText( radio:GetCurrentTimeRadio(true) )	
				end
			end
		end
	cam.End3D2D()

	if ent.IsServer then
		p = ent:GetPos()
		p = p + ent:GetForward() * InfoTable.InfoPosVoice.x
		p = p + ent:GetRight() * InfoTable.InfoPosVoice.y
		p = p + ent:GetUp() * InfoTable.InfoPosVoice.z
		p = p + ent:GetForward() * -1

		a = ent:GetAngles()
		a:RotateAroundAxis( a:Up(), InfoTable.InfoAngVoice.y )
		a:RotateAroundAxis( a:Right(), InfoTable.InfoAngVoice.p)
		a:RotateAroundAxis( a:Forward(), InfoTable.InfoAngVoice.r )

		cam.Start3D2D( p, a, InfoTable.InfoOffsetVoice );
			surface.SetFont( "Radio.Voice" )

			local _w, _h = surface.GetTextSize( string.upper( Radio.GetLanguage("Voice") ) );

			surface.SetDrawColor( Radio.Color["voice_background"] );
			surface.DrawRect(InfoTable.InfoVoiceBackX, InfoTable.InfoVoiceBackY, InfoTable.InfoVoiceBackW, InfoTable.InfoVoiceBackH)
			if( radio:IsVoiceEnabled() ) then
				if( LocalPlayer().RadioVoice and ( LocalPlayer():GetPos():DistToSqr( ent:GetPos() ) < 200^2 ) ) then
					surface.SetTextColor( Radio.Color["voice_active"] );
				else
					surface.SetTextColor( Radio.Color["voice_enable"] );
				end
			else
				surface.SetTextColor( Radio.Color["voice_disable"] );
			end

			surface.SetTextPos( InfoTable.InfoVoiceTextX, InfoTable.InfoVoiceTextY );
			surface.DrawText( string.upper( Radio.GetLanguage("Voice") ) );

		cam.End3D2D();
	end
end