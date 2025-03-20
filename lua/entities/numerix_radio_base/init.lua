--[[ Radio --------------------------------------------------------------------------------------

Radio made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

function ENT:Initialize()
	local radio = ents.Create("numerix_radio_component")
	radio:SetParent(self)
	radio:SetMaxDistanceSound( self:GetDefaultDistanceSound() )
	radio:SetServer(self.IsServer)
	radio:Spawn()
	
	self:SetHealth(self.StartHealth)
	self:SetModel(self.Model or "models/sligwolf/grocel/radio/ghettoblaster.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )  
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
 
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	if isnumber(self.SID) and FPP then
		self:CPPISetOwner(Player(self.SID))
	end
end

function ENT:GetDefaultDistanceSound()
	return Radio.Settings.DistanceSoundRadio^2
end

function ENT:OnTakeDamage( dmgInfo )	
	self.Entity:TakePhysicsDamage(dmgInfo)
	self:SetHealth(self:Health() - dmgInfo:GetDamage())

	if self:Health() <= 0 then self:Explode() end
end
	
function ENT:Explode()
	if !Radio.Settings.ExplodeDamage then return end

	local effectdata = EffectData()
	effectdata:SetOrigin(self.Entity:GetPos())
	util.Effect("ThumperDust", effectdata, true, true)
	util.Effect("Explosion", effectdata, true, true)
	self:Remove()
end

function ENT:AcceptInput(Name, Activator, Caller)	
	if Name == "Use" and Activator:IsPlayer() and Radio.CanEdit(Activator, self) then
		if self.Admin and !Activator:IsAdmin() then
			Activator:RadioChatInfo( Radio.GetLanguage("You are not an admin, you can't use that radio."), Radio.Chat.ERROR )

			return
		end

		net.Start("Radio:OpenStreamMenu")
		net.WriteEntity(self)
		net.Send(Activator)
	end	
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end