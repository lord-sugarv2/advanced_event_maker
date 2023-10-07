ENT.Base = "base_brush"
ENT.Type = "brush"

if SERVER then
    function ENT:Initialize()
        self:SetSolid(SOLID_BBOX)
        self:SetCollisionBoundsWS(self.cornerOne, self.cornerTwo)
    end

    function ENT:StartTouch(ply)
        if not ply:IsPlayer() then return end
        if not ply:Alive() then return end
        if not AEvent:IsInEvent(ply) then return end
        self.boxFunction(ply)
    end
end