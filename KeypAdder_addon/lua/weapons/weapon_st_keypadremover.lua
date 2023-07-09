
AddCSLuaFile()

SWEP.PrintName = "Keypad Remover"
SWEP.Category = "KeypAdder"

SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/weapons/c_crowbar.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_crowbar.mdl" )
SWEP.ViewModelFOV = 70
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

SWEP.Primary.Automatic = false
SWEP.Secondary.Automatic = false
SWEP.Primary.Delay = 2
SWEP.Secondary.Delay = 2

if CLIENT then SWEP.WepSelectIcon = surface.GetTextureID( "keypadder/remover_select.vmt" ) end

SWEP.DrawAmmo = false

SWEP.m_WeaponDeploySpeed = 1

SWEP.Author = "SweptThrone"
SWEP.Contact = "sweptthr.one/contact"
SWEP.Purpose = "Remove keypad from doors"
SWEP.Instructions = "Left click to remove your keypad from door"

local targetIcon = Material( "sprites/hud/v_crosshair1" )

function SWEP:DoDrawCrosshair( x, y )
	local ply = LocalPlayer()
	local tr = ply:GetEyeTrace()
	local ent = tr.Entity
	if IsValid( ent ) and ent:GetClass() == "prop_door_rotating" and ent:GetModel() == "models/props_c17/door01_left.mdl" and tr.StartPos:DistToSqr( tr.HitPos ) <= 84*84 and ent:GetNWBool( "KeypAdded", false ) then return true end
	surface.SetDrawColor( 192, 192, 192, 255 )
	surface.SetMaterial( targetIcon )
	surface.DrawTexturedRect( x - 32, y - 32, 64, 64 )
	return true
end

function SWEP:DrawHUD()
	local ply = LocalPlayer()
	local tr = ply:GetEyeTrace()
	local ent = tr.Entity
	if IsValid( ent ) and ent:GetClass() == "prop_door_rotating" and ent:GetModel() == "models/props_c17/door01_left.mdl" and tr.StartPos:DistToSqr( tr.HitPos ) <= 84*84 and ent:GetNWBool( "KeypAdded", false ) then
		surface.SetDrawColor( 97, 252, 3, 255 )
		surface.SetMaterial( targetIcon )
		local tab = ent:GetBonePosition( 1 ):ToScreen()
		local x, y = tab.x, tab.y
		local pos = TimedSin( 0.5, 64, 72, 0 )
		surface.DrawTexturedRect( x - pos/2, y - pos/2, pos, pos )
	end
end

function SWEP:Holster()	
	return true
end

function SWEP:PrimaryAttack()

	local tr = self:GetOwner():GetEyeTrace()
	local door = tr.Entity

	if CLIENT and IsFirstTimePredicted() then
		if IsValid( door ) and door:GetClass() == "prop_door_rotating" and door:GetModel() == "models/props_c17/door01_left.mdl" and tr.StartPos:DistToSqr( tr.HitPos ) <= 84*84 and self.Password ~= "" and door:GetNWBool( "KeypAdded", false ) then

			local this = self

			local KeypadWindow = vgui.Create( "DFrame" )
			KeypadWindow:SetPos( 0, 0 )
			KeypadWindow:SetSize( 300, 100 )
			KeypadWindow:SetTitle( "KeypAdder" )
			KeypadWindow:SetVisible( true )
			KeypadWindow:SetDraggable( true )
			KeypadWindow:ShowCloseButton( true )
			KeypadWindow:MakePopup()
			KeypadWindow:Center()
			function KeypadWindow:Think()
				if not LocalPlayer():Alive() then self:Close() return end
			end

			local ConfLabel = vgui.Create( "DLabel", KeypadWindow )
			ConfLabel:SetText( "Are you sure you to remove this keypad?" )
			ConfLabel:SizeToContents()
			ConfLabel:SetPos( 0, 35 )
			ConfLabel:CenterHorizontal( 0.5 )

			--[[
			if DarkRP then
				local DRPConfLabel = vgui.Create( "DLabel", KeypadWindow )
				DRPConfLabel:SetText( "You will no longer be able to use keys on this door." )
				DRPConfLabel:SizeToContents()
				DRPConfLabel:SetPos( 0, 50 )
				DRPConfLabel:CenterHorizontal( 0.5 )
			end
			]]--

			local YesButton = vgui.Create( "DButton", KeypadWindow )
			YesButton:SetText( "Yes" )
			YesButton:SetTextColor( Color( 0, 128, 0 ) )
			YesButton:SetPos( 20, 70 )
			YesButton:SetSize( 100, 20 )
			function YesButton:DoClick()
				surface.PlaySound( "buttons/button14.wav" )
				net.Start( "KeypAddDoor" )
					net.WriteUInt( 3, 2 )
					net.WriteUInt( 0, 20 )
					net.WriteEntity( door )
				net.SendToServer()
				KeypadWindow:Close()
			end

			local NoButton = vgui.Create( "DButton", KeypadWindow )
			NoButton:SetText( "No" )
			NoButton:SetTextColor( Color( 128, 0, 0 ) )
			NoButton:SetPos( 180, 70 )
			NoButton:SetSize( 100, 20 )
			function NoButton:DoClick()
				surface.PlaySound( "ui/buttonclick.wav" )
				KeypadWindow:Close()
			end

		else
			surface.PlaySound( "player/suit_denydevice.wav" )
		end

	end
end

function SWEP:SecondaryAttack()
	return
end

function SWEP:Initialize()

	self:SetHoldType( "pistol" )

end

function SWEP:Deploy()
	return true

end
