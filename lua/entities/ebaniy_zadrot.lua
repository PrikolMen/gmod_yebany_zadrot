AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.PrintName = "Ёбаный Задрот"
ENT.Category = "Fun + Games"

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.AutomaticFrameAdvance = true

if SERVER then
	util.AddNetworkString("enpc_meme_sound")
else
	net.Receive("enpc_meme_sound", function()
		local npc = net.ReadEntity()
		if IsValid(npc) then
			if IsValid(npc.Station) then
				npc.Station:Stop()
				npc.Station = nil
			end

			sound.PlayFile("sound/pmemes/yea_480p.ogg", "3d", function( station )
				station:SetPos( npc:GetPos() + Vector(0,0,65) )
				station:Play()

				npc.SoundEndTime = CurTime() + 30
				npc.FFT = {}
				npc.Station = station
			end)
		end
	end)
end

function ENT:Use(ply)
	if IsValid(ply) and (ply.P_NPC_Meme or 0) < CurTime() then
		net.Start("enpc_meme_sound")
			net.WriteEntity(self)
		net.Send(ply)

		ply.P_NPC_Meme = CurTime() + 5
	end
end

function ENT:Initialize()
	self:SetModel("models/deusex/playermodels/bobpage.mdl")
	self:PhysicsInitBox(Vector(-16, -16, 0), Vector(16,16,70))
	self:SetMoveType(0)

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end
end

function ENT:Think()
	if IsValid(self.Station) then
		local station = self.Station
		if CurTime() > self.SoundEndTime then
			station:Stop()
		end

		station:SetPos(self:GetPos()+Vector(0,0,65))
		station:FFT(self.FFT, 5)

		timer.Simple(1, function()
			if !IsValid(self) and IsValid(station) then
				station:Stop()
			end
		end)

		local bass = 0
		for i = 1, 250 do
			if self.FFT[i] then bass = math.max(bass, self.FFT[i]*170 or 0.01) or 0 end
		end

		local flexes = {
			self:GetFlexIDByName( "jaw_drop" ),
			self:GetFlexIDByName( "left_part" ),
			self:GetFlexIDByName( "right_part" ),
			self:GetFlexIDByName( "left_mouth_drop" ),
			self:GetFlexIDByName( "right_mouth_drop" )
		}
	
		local weight = math.Round(bass)/50
	
		for k, v in pairs( flexes ) do
			self:SetFlexWeight( v, weight )
		end
	end

    self:SetSequence(17)
	self:NextThink(CurTime() + self:SequenceDuration(17))

	return true
end
