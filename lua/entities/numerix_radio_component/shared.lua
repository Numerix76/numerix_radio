--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]

ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Radio Base Core"
ENT.Category		= "Numerix Scripts"
ENT.Author			= "Numerix"
ENT.Contact			= "https://steamcommunity.com/id/numerix/"
ENT.Purpose			= ""
ENT.Instructions	= ""					
ENT.Spawnable 		= false

function ENT:SetupDataTables()
	
end

function ENT:IsConnectedToServer()
	return self != self:GetController()
end

function ENT:GetMaxDistanceSound()
	if ( Radio.IsCar(self:GetParent()) ) then return -1 end -- In car, we don't have distance

	return self:GetNWInt("Radio:MaxDistanceSound", 800^2)
end

function ENT:GetDistanceSound()
	return (Radio.IsCar(self:GetParent()) or self:GetMaxDistanceSound() <= 0) and -1 or self:GetMaxDistanceSound()*self:GetVolume()/100
end

function ENT:GetURL()
	return self:GetController():GetNWString("Radio:URL")
end

function ENT:GetMusicAuthor()
	return self:GetController():GetNWString("Radio:Author")
end

function ENT:GetMusicTitle()
	return self:GetController():GetNWString("Radio:Title")
end

function ENT:GetMusicThumbnail()
	return self:GetController():GetNWString("Radio:Thumbnail")
end

function ENT:GetMusicThumbnailName()
	return self:GetController():GetNWString( "Radio:ThumbnailName")
end

function ENT:GetMusicDuration()
	return self:GetController():GetNWFloat( "Radio:Duration", nil)
end

function ENT:GetInformation()
	return self:GetNWString("Radio:Info")
end

function ENT:GetVisualColor()
	return string.ToColor(self:GetNWString( "Radio:Visual", "255 255 255 255" ))
end

function ENT:GetVolume()
	return self:GetNWInt("Radio:Volume", 50)
end

function ENT:GetStartTime()
	return self:GetController():GetNWFloat( "Radio:Time", SysTime() )
end

function ENT:IsRainbow()
	return self:GetNWBool("Radio:Rainbow", false)
end

function ENT:IsPrivate()
	return self:GetNWBool("Radio:Private", false)
end

function ENT:IsPrivateBuddy()
	return self:GetNWBool("Radio:PrivateBuddy", false)
end

function ENT:IsPaused()
	return self:GetController():GetNWBool("Radio:Pause", false)
end

function ENT:IsLive()
	return self:GetNWBool("Radio:Live", false)
end

function ENT:IsLoading()
	return self:GetNWBool("Radio:Loading", false);
end

function ENT:GetController()
	local controller = self:GetNWEntity("Radio:Controller", self);

	if ( !IsValid(controller) ) then return self end

	return controller;
end

function ENT:IsVoiceEnabled()
	return self:IsServer() and self:GetNWBool("Radio:Voice", false)
end

function ENT:GetServerName()
	return self:IsServer() and self:GetNWString("Radio:ServerName", "Non défini")
end

function ENT:GetListeners()
	if ( !self:IsServer() ) then return 0 end

	return self:GetController():GetNWInt("Radio:Viewer")
end

function ENT:IsServer()
	return self:GetNWBool("Radio:IsServer", false)
end

function ENT:IsLooping()
	return self:GetNWBool("Radio:Loop", false)
end

function ENT:CanHear(ply)
	if ( Radio.IsCar(self:GetParent()) ) then
		if ( !ply:InVehicle() ) then return false end
		if ( ply:GetVehicle():GetParent() != self:GetParent() and ply:GetVehicle() != self:GetParent() ) then return false end
	end

	if ( self:GetParent():IsWeapon() ) then
		if ( ply:InVehicle() ) then return end
		if ( !IsValid(self:GetParent().Owner:GetActiveWeapon()) ) then return false end
		if ( self:GetParent().Owner:GetActiveWeapon() != self:GetParent() ) then return false end
	end

	local maxDistance = self:GetDistanceSound()

	return maxDistance == -1 or self:GetParent():GetPos():DistToSqr( ply:GetPos() ) <= maxDistance
end