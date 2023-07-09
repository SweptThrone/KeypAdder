AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
 
ENT.PrintName= "Keypad Cracker Battery"
ENT.Author= "SweptThrone"
ENT.Contact= "https://sweptthr.one/contact"
ENT.Purpose= ""
ENT.Instructions= ""
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.Category = "KeypAdder"

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end

end

if SERVER then
    function ENT:Initialize()
    
        self:SetModel( "models/Items/battery.mdl" )
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )
    
        local phys = self:GetPhysicsObject()
        if (phys:IsValid()) then phys:Wake() end
        self:SetUseType(SIMPLE_USE)

    end
    
    function ENT:Use( act, ply )
        ply:GiveAmmo( 20, "Keypad Cracker Charge" )
        self:Remove()
    end

end