
AddCSLuaFile()

SWEP.PrintName = "KeypAdder"
SWEP.Category = "KeypAdder"

SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/weapons/cstrike/c_knife_t.mdl" )
SWEP.WorldModel = Model( "models/props_lab/keypad.mdl" )
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

if CLIENT then SWEP.WepSelectIcon = surface.GetTextureID( "keypadder/keypadder_select.vmt" ) end

SWEP.DrawAmmo = false

SWEP.m_WeaponDeploySpeed = 1

SWEP.Author = "SweptThrone"
SWEP.Contact = "sweptthr.one/contact"
SWEP.Purpose = "Add keypad to doors"
SWEP.Instructions = "Right click to set password\nLeft click to install on door"

SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_L_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(0, -7.64, 0.58), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Finger1"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 27.458, 0) },
	["v_weapon.Knife_Handle"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Finger01"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -28.414, 0) },
	["ValveBiped.Bip01_R_Finger12"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 35.806, 0) },
	["ValveBiped.Bip01_R_Finger11"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 63.333, 0) },
	["ValveBiped.Bip01_R_Finger0"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -21.761, 0) }
}

SWEP.VElements = {
	["keypad"] = { type = "Model", model = "models/props_lab/keypad.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.349, 3.111, -3.191), angle = Angle(-41.126, 131.869, 106), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["keypadscreen"] = { type = "Quad", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(6.375, 1.045, -4.377), angle = Angle(133.348, -71.109, 15.581), size = 0.05, draw_func = function( this )
		local tr = this:GetOwner():GetEyeTrace()
		local ent = tr.Entity
		if IsValid( ent ) and ent:GetClass() == "prop_door_rotating" and ent:GetModel() == "models/props_c17/door01_left.mdl" and tr.StartPos:DistToSqr( tr.HitPos ) <= 84*84 and not ent:GetNWBool( "KeypAdded", false ) then
			draw.RoundedBox( 4, -40, -20, 75, 40, Color( 97, 252, 3 ) )
		else
			draw.RoundedBox( 4, -40, -20, 75, 40, Color( 255, 57, 0 ) )
		end
		draw.DrawText( this.Password, "KeypadDisplay", -28, -10, Color( 64, 64, 64 ), TEXT_ALIGN_LEFT )
	end },
}

SWEP.WElements = {
	["keypad"] = { type = "Model", model = "models/props_lab/keypad.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5.756, 3.17, -4.038), angle = Angle(-160.09, 3.714, -12.084), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.ShowWorldModel = false

local targetIcon = Material( "sprites/hud/v_crosshair1" )

function SWEP:DoDrawCrosshair( x, y )
	local ply = LocalPlayer()
	local tr = ply:GetEyeTrace()
	local ent = tr.Entity
	if IsValid( ent ) and ent:GetClass() == "prop_door_rotating" and ent:GetModel() == "models/props_c17/door01_left.mdl" and tr.StartPos:DistToSqr( tr.HitPos ) <= 84*84 and not ent:GetNWBool( "KeypAdded", false ) then return true end
	surface.SetDrawColor( 192, 192, 192, 255 )
	surface.SetMaterial( targetIcon )
	surface.DrawTexturedRect( x - 32, y - 32, 64, 64 )
	return true
end

function SWEP:DrawHUD()
	local ply = LocalPlayer()
	local tr = ply:GetEyeTrace()
	local ent = tr.Entity
	if IsValid( ent ) and ent:GetClass() == "prop_door_rotating" and ent:GetModel() == "models/props_c17/door01_left.mdl" and tr.StartPos:DistToSqr( tr.HitPos ) <= 84*84 and not ent:GetNWBool( "KeypAdded", false ) then
		surface.SetDrawColor( 97, 252, 3, 255 )
		surface.SetMaterial( targetIcon )
		local tab = ent:GetBonePosition( 1 ):ToScreen()
		local x, y = tab.x, tab.y
		local pos = TimedSin( 0.5, 64, 72, 0 )
		surface.DrawTexturedRect( x - pos/2, y - pos/2, pos, pos )
	end
end

function SWEP:Holster()
	
	if CLIENT and IsValid(self:GetOwner()) then
		self.DrawActive = false
		local vm = self:GetOwner():GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end

function SWEP:PrimaryAttack()

	local tr = self:GetOwner():GetEyeTrace()
	local door = tr.Entity

	if CLIENT and IsFirstTimePredicted() then
		if IsValid( door ) and door:GetClass() == "prop_door_rotating" and door:GetModel() == "models/props_c17/door01_left.mdl" and tr.StartPos:DistToSqr( tr.HitPos ) <= 84*84 and self.Password ~= "" and not door:GetNWBool( "KeypAdded", false ) then

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
			ConfLabel:SetText( "Are you sure you to KeypAdd this door?" )
			ConfLabel:SizeToContents()
			ConfLabel:SetPos( 0, 35 )
			ConfLabel:CenterHorizontal( 0.5 )

			if DarkRP then
				local DRPConfLabel = vgui.Create( "DLabel", KeypadWindow )
				DRPConfLabel:SetText( "You will no longer be able to use keys on this door." )
				DRPConfLabel:SizeToContents()
				DRPConfLabel:SetPos( 0, 50 )
				DRPConfLabel:CenterHorizontal( 0.5 )
			end

			local YesButton = vgui.Create( "DButton", KeypadWindow )
			YesButton:SetText( "Yes" )
			YesButton:SetTextColor( Color( 0, 128, 0 ) )
			YesButton:SetPos( 20, 70 )
			YesButton:SetSize( 100, 20 )
			function YesButton:DoClick()
				surface.PlaySound( "buttons/button14.wav" )
				net.Start( "KeypAddDoor" )
					net.WriteUInt( 0, 2 )
					net.WriteUInt( tonumber( this.Password ), 20 )
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
	if SERVER then return end
	if CLIENT and IsFirstTimePredicted() then

		local this = self
		--models/props_lab/keypad_sheet
		--local keypadMat = Material( "models/props_lab/keypad_sheet" )
		--local keypadMat = Material( "../data/sweptthrone/keypad_sheet_unlit" )
		-- you can only use WasKeyPressed in Move hooks
		-- so this will have to do
		-- 0 = not down, 2 = pressed, 1 = down
		local inputState = {
			[ KEY_1 ] = 0,
			[ KEY_2 ] = 0,
			[ KEY_3 ] = 0,
			[ KEY_4 ] = 0,
			[ KEY_5 ] = 0,
			[ KEY_6 ] = 0,
			[ KEY_7 ] = 0,
			[ KEY_8 ] = 0,
			[ KEY_9 ] = 0,
			[ KEY_PAD_1 ] = 0,
			[ KEY_PAD_2 ] = 0,
			[ KEY_PAD_3 ] = 0,
			[ KEY_PAD_4 ] = 0,
			[ KEY_PAD_5 ] = 0,
			[ KEY_PAD_6 ] = 0,
			[ KEY_PAD_7 ] = 0,
			[ KEY_PAD_8 ] = 0,
			[ KEY_PAD_9 ] = 0,
		}

		local KeypadWindow = vgui.Create( "DFrame" )
        KeypadWindow:SetPos( 0, 0 )
        KeypadWindow:SetSize( 320, 550 )
        KeypadWindow:SetTitle( "" )
        KeypadWindow:SetVisible( true )
        KeypadWindow:SetDraggable( false )
        KeypadWindow:ShowCloseButton( false )
        KeypadWindow:MakePopup()
        KeypadWindow:Center()
		function KeypadWindow:Think()
			if not LocalPlayer():Alive() then self:Close() return end
			if input.IsKeyDown( KEY_PAD_ENTER ) or input.IsKeyDown( KEY_ENTER ) then
				self:Close()
			end
			if input.IsKeyDown( KEY_ESCAPE ) then
				self:Close()
			end
			for k,v in pairs( inputState ) do
				if v and not input.IsKeyDown( k ) then
					inputState[ k ] = 0
				end
				if v and input.IsKeyDown( k ) then
					inputState[ k ] = 1
				end
				if v == 0 and input.IsKeyDown( k ) then
					inputState[ k ] = 2
				end

				if v == 2 then
					local num
					if k > 37 then
						num = k - 37
					elseif k > 1 then
						num = k - 1
					end
					if #this.Password < 6 then
						this.Password = this.Password .. num
						surface.PlaySound( "buttons/button15.wav" )
					else
						surface.PlaySound( "buttons/button16.wav" )
					end
				end
			end
		end
		function KeypadWindow:Init()
			self.startTime = SysTime()
		end
		function KeypadWindow:Paint( w, h )
			Derma_DrawBackgroundBlur( self, self.startTime )

			surface.SetDrawColor( 255, 255, 255 )
			surface.SetMaterial( KeypAdderMats.keypadMat )
			surface.DrawTexturedRectUV( 0, 0, w-20, h, 0, 0, 300/550, 1 )

			surface.SetDrawColor( 97, 252, 3 )
			draw.NoTexture()
			surface.DrawRect( 69, 77, 162, 93 )

			surface.SetTextPos( 80, 100 )
			surface.SetFont( "KeypadNumbers" )
			surface.SetTextColor( 64, 64, 64 )
			surface.DrawText( this.Password )
        end

		--[[
			69,77  162,93

			34,264   71,71
			116
			194
		]]--

		local num = 1
		for i = 0, 2 do
			for j = 0, 2 do
				local NumButton = vgui.Create( "DButton", KeypadWindow )
				NumButton:SetPos( 34 + 80 * j, 264 + 76 * i )
				NumButton:SetSize( 70, 70 )
				NumButton:SetTextColor( Color( 32, 32, 32 ) )
				NumButton:SetFont( "KeypadNumbers" )
				NumButton:SetText( num )
				NumButton.Number = num
				NumButton:SetContentAlignment( 5 )
				function NumButton:Paint( w, h )
					surface.SetDrawColor( 162, 102, 88 )
					if self:IsHovered() then
						surface.SetDrawColor( 234, 167, 153 )
					end
					if self:IsDown() or inputState[ self.Number + 1 ] == 2 or inputState[ self.Number + 37 ] == 2  then
						surface.SetDrawColor( 115, 73, 66 )
					end
					draw.NoTexture()
					surface.DrawRect( 0, 0, w, h )
				end
				function NumButton:DoClick()
					if #this.Password < 6 then
						this.Password = this.Password .. self.Number
						surface.PlaySound( "buttons/button15.wav" )
					else
						surface.PlaySound( "buttons/button16.wav" )
					end
				end
				num = num + 1
			end
		end

		local CloseButton = vgui.Create( "DButton", KeypadWindow )
        CloseButton:SetPos( 300, 0 )
        CloseButton:SetSize( 20, 40 )
        CloseButton:SetText( "X" )
        CloseButton:SetTextColor(Color(255,255,255))
        CloseButton.DoClick = function( self )
            KeypadWindow:Close()
            surface.PlaySound("ui/buttonclick.wav")
        end
        CloseButton.Paint = function( self, w, h )
            if CloseButton:IsHovered() then
                draw.RoundedBox( 0, 0, 0, w, h, Color( 128, 0, 0, 255 ) )
            else
                draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0, 255 ) )
            end
            surface.SetDrawColor( color_black )
        end

		
		local ClearButton = vgui.Create( "DButton", KeypadWindow )
        ClearButton:SetPos( 300, 77 )
        ClearButton:SetSize( 20, 93 )
        ClearButton:SetText( "C" )
        ClearButton:SetTextColor(Color(255,255,255))
        function ClearButton:DoClick()
            this.Password = ""
            surface.PlaySound("ui/buttonclick.wav")
        end
        ClearButton.Paint = function( self, w, h )
            if ClearButton:IsHovered() then
                draw.RoundedBox( 0, 0, 0, w, h, Color( 128, 0, 0, 255 ) )
            else
                draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0, 255 ) )
            end
            surface.SetDrawColor( color_black )
        end

		local EnterButton = vgui.Create( "DButton", KeypadWindow )
		EnterButton:SetPos( 300, 264 )
		EnterButton:SetSize( 20, 230 )
		EnterButton:SetText( ">" )
		EnterButton:SetTextColor(Color(255,255,255))
		function EnterButton:DoClick()
            surface.PlaySound("ui/buttonclick.wav")
			KeypadWindow:Close()
		end
		EnterButton.Paint = function( self, w, h )
			if EnterButton:IsHovered() then
				draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 96, 0, 255 ) )
			else
				draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 192, 0, 255 ) )
			end
			surface.SetDrawColor( color_black )
		end

	end
end

function SWEP:Initialize()

	self:SetHoldType( "pistol" )
	
	if CLIENT then

		self.Password = ""

		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )
		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
	end


end

sound.Add( {
	name = "STHack_Click",
	sound = "buttons/lightswitch2.wav",
	pitch = 200,
    channel = CHAN_STATIC
} )

function SWEP:Deploy()
	timer.Simple( 0.4, function()
		if SERVER and self:GetOwner():GetActiveWeapon() == self then self:EmitSound( "STHack_Click" ) end
	end )
	return true

end

function SWEP:OnRemove()
	self:Holster()
end
if CLIENT then
	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)
		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}
			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end
		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()
			end
			
		end
		
	end
	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		if self.ShowWorldModel == nil or self.ShowWorldModel or not IsValid( self:GetOwner() ) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then
			self.wRenderOrder = {}
			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end
		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()
			end
			
		end
		
	end
	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)
			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end
	function SWEP:CreateModels( tab )
		if (!tab) then return end
		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
                    v.modelEnt:UseClientSideAnimation()
                    --[[v.modelEnt.AutomaticFrameAdvance = true
                    v.modelEnt.Think = function( this )
                        this:NextThink( CurTime() )
                        return true
                    end]]
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )
		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end
