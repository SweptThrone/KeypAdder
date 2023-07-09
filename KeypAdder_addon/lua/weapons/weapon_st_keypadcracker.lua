
AddCSLuaFile()

SWEP.PrintName = "Keypad Cracker"
SWEP.Category = "KeypAdder"

SWEP.Slot = 5
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.ViewModel = "models/weapons/cstrike/c_c4.mdl"
SWEP.WorldModel = "models/weapons/w_c4.mdl"
SWEP.ViewModelFOV = 70
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Ammo = "Keypad Cracker Charge"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

SWEP.Primary.Automatic = false
SWEP.Secondary.Automatic = false
SWEP.Primary.Delay = 2
SWEP.Secondary.Delay = 2

if CLIENT then SWEP.WepSelectIcon = surface.GetTextureID( "keypadder/cracker_select.vmt" ) end

SWEP.DrawAmmo = true

SWEP.m_WeaponDeploySpeed = 1

SWEP.Cracking = NULL

SWEP.Author = "SweptThrone"
SWEP.Contact = "sweptthr.one/contact"
SWEP.Purpose = "Crack keypads on doors"
SWEP.Instructions = "Left click to crack keypad"

local targetIcon = Material( "sprites/hud/v_crosshair1" )

local dots = {
	[ 0 ] = "",
	".",
	"..",
	"..."
}

SWEP.VElements = {
	["screen"] = { type = "Quad", bone = "v_weapon.c4", rel = "", pos = Vector(-3.396, -3.62, 0.704), angle = Angle(180, 0, -90), size = 0.025, draw_func = function( this )
		local tr = this:GetOwner():GetEyeTrace()
		local ent = tr.Entity
		if IsValid( ent ) and ent:GetClass() == "prop_door_rotating" and ent:GetModel() == "models/props_c17/door01_left.mdl" and tr.StartPos:DistToSqr( tr.HitPos ) <= 84*84 and ent:GetNWBool( "KeypAdded", false ) then
			draw.RoundedBox( 4, -40, -40, 160, 80, Color( 97, 252, 3 ) )
			draw.DrawText( "READY!", "KeypadDisplay", 7, -10, Color( 64, 64, 64 ), TEXT_ALIGN_LEFT )
		else
			draw.RoundedBox( 4, -40, -40, 160, 80, Color( 255, 57, 0 ) )
			draw.DrawText( "SEARCHING" .. dots[ math.floor( CurTime() % 4 ) ], "KeypadDisplay", -18, -10, Color( 64, 64, 64 ), TEXT_ALIGN_LEFT )
		end
	end }
}

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
	
	if CLIENT and IsValid(self:GetOwner()) then
		local vm = self:GetOwner():GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end

function SWEP:Think()
	if self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() ) > 100 then
		self:GetOwner():SetAmmo( 100, self:GetPrimaryAmmoType() )
	end

	if CLIENT and self.NextGuess and CurTime() >= self.NextGuess then
		self.NextGuess = nil
		self.Guess = nil
		self.Waiting = false
		self.Reset = true
	end
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:PrimaryAttack()

	local tr = self:GetOwner():GetEyeTrace()
	local door = tr.Entity

	--buttons/combine_button5.wav
	if SERVER then 
		if IsValid( door ) and door:GetClass() == "prop_door_rotating" and door:GetModel() == "models/props_c17/door01_left.mdl" and tr.StartPos:DistToSqr( tr.HitPos ) <= 84*84 and door:GetNWBool( "KeypAdded", false ) then
			self.Cracking = door
            sound.Play( "buttons/combine_button5.wav", door:GetBonePosition( 1 ), 80, 100, 1 )
		end
	end

	if CLIENT and IsFirstTimePredicted() then
		if IsValid( door ) and door:GetClass() == "prop_door_rotating" and door:GetModel() == "models/props_c17/door01_left.mdl" and tr.StartPos:DistToSqr( tr.HitPos ) <= 84*84 and door:GetNWBool( "KeypAdded", false ) and IsFirstTimePredicted() then

			local this = self
			--models/props_lab/keypad_sheet
			--local keypadMat = Material( "models/props_lab/keypad_sheet" )
			--local screenMat = Material( "../data/sweptthrone/cracker_sheet_unlit" )
			local enterPassword = ""
			local chance = 1
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

			inputExtras = {
				[ KEY_PAD_ENTER ] = 0,
				[ KEY_ENTER ] = 0
			}

			local KeypadWindow = vgui.Create( "DFrame" )
			KeypadWindow:SetPos( 0, 0 )
			KeypadWindow:SetSize( 520, 400 )
			KeypadWindow:SetTitle( "" )
			KeypadWindow:SetVisible( true )
			KeypadWindow:SetDraggable( false )
			KeypadWindow:ShowCloseButton( false )
			KeypadWindow:MakePopup()
			KeypadWindow:Center()
			function KeypadWindow:Think()
				if not LocalPlayer():Alive() then self:Close() return end

				if this.Reset and enterPassword ~= "" then
					enterPassword = ""
					this.Reset = nil
				end

				for k,v in pairs( inputExtras ) do
					if v and not input.IsKeyDown( k ) then
						inputExtras[ k ] = 0
					end
					if v and input.IsKeyDown( k ) then
						inputExtras[ k ] = 1
					end
					if v == 0 and input.IsKeyDown( k ) then
						inputExtras[ k ] = 2
					end

					if v == 2 and not this.Waiting and ( not this.NextGuess or CurTime() >= this.NextGuess ) then
						if LocalPlayer():GetAmmoCount( this:GetPrimaryAmmoType() ) < #enterPassword * 5 or enterPassword == "" then
							surface.PlaySound( "player/suit_denydevice.wav" )
						else
							net.Start( "KeypAddDoor" )
								net.WriteUInt( 2, 2 )
								net.WriteUInt( tonumber( enterPassword ), 20 )
								net.WriteEntity( door )
							net.SendToServer()
							this.Waiting = true
						end
					end
				end
				if input.IsKeyDown( KEY_ESCAPE ) then
					this.Guess = nil
					this.Waiting = false
					this.Reset = nil
					this.NextGuess = nil
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

					if v == 2 and not this.Waiting and ( not this.NextGuess or CurTime() >= this.NextGuess ) then
						local num
						if k > 37 then
							num = k - 37
						elseif k > 1 then
							num = k - 1
						end
						if #enterPassword < 6 then
							enterPassword = enterPassword .. num
							surface.PlaySound( "buttons/combine_button1.wav" )
						else
							surface.PlaySound( "npc/roller/mine/rmine_blip3.wav" )
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
				surface.SetMaterial( KeypAdderMats.crackerMat )
				surface.DrawTexturedRect( 0, 0, 500, 400 )

				draw.RoundedBox( 42, 63, 36, 376, 177, Color( 0, 0, 0, 255 ) )
				surface.SetFont( "ChatFont" )
				surface.SetTextPos( 360, 40 )
				surface.SetTextColor( 255, 255, 255, 255 )
				surface.DrawText( this:GetOwner():GetAmmoCount( this:GetPrimaryAmmoType() ) .. "%" )

				if this.Waiting then
					surface.SetTextPos( 90, 80 )
					surface.SetFont( "CrackerDisplay" )
					surface.SetTextColor( 255, 255, 255, TimedSin( 0.5, 192, 319, 0 ) )
					surface.DrawText( "CHKING" )
				else
					if not this.Guess then
						surface.SetTextPos( 90, 80 )
						surface.SetFont( "CrackerDisplay" )
						surface.SetTextColor( 255, 255, 255 )
						surface.DrawText( enterPassword )
					else
						local colorLUT = {
							Color( 128, 128, 128, 255 ),
							Color( 192, 192, 0, 255 ),
							Color( 0, 192, 0, 255 )
						}
						local tab = {}
						for i = 1, 6 do
							tab[ i ] = math.floor( this.Guess / math.pow( 10, 6 - i ) ) % 10
							local c = colorLUT[ tab[ i ] ]
							surface.SetTextPos( 90 + 54 * ( i - 1 ), 80 )
							surface.SetFont( "CrackerDisplay" )
							surface.SetTextColor( c.r, c.g, c.b, ( math.floor( 0.5 * math.sin( 5 * CurTime() ) + 0.4 ) + 1 ) * 255 )
							surface.DrawText( string.sub( enterPassword, i, i ) )
						end
					end
				end
			end

			local num = 1
			for i = 0, 1 do
				for j = 0, 4 do
					local NumButton = vgui.Create( "DButton", KeypadWindow )
					NumButton:SetPos( 76 + 72 * j, 262 + 72 * i )
					NumButton:SetSize( 65, 65 )
					NumButton:SetTextColor( Color( 32, 32, 32 ) )
					NumButton:SetFont( "KeypadNumbers" )
					NumButton:SetText( ( num == 10 and ">" or num ) )
					NumButton.Number = num
					NumButton:SetContentAlignment( 5 )
					function NumButton:Paint( w, h )
						surface.SetDrawColor( 255, 222, 173 )
						if self:IsHovered() then
							surface.SetDrawColor( 255, 255, 224 )
						end
						if self:IsDown() or inputState[ self.Number + 1 ] == 2 or inputState[ self.Number + 37 ] == 2 then
							surface.SetDrawColor( 153, 135, 107 )
						end
						draw.NoTexture()
						surface.DrawRect( 0, 0, w, h )
					end
					function NumButton:DoClick()
						if this.Waiting or ( this.NextGuess and CurTime() < this.NextGuess ) then return end
						if self.Number == 10 then
							if LocalPlayer():GetAmmoCount( this:GetPrimaryAmmoType() ) < #enterPassword * 5 or enterPassword == "" then
								surface.PlaySound( "player/suit_denydevice.wav" )
								return 
							end
							net.Start( "KeypAddDoor" )
								net.WriteUInt( 2, 2 )
								net.WriteUInt( tonumber( enterPassword ), 20 )
								net.WriteEntity( door )
							net.SendToServer()
							this.Waiting = true
						else
							if #enterPassword < 6 then
								enterPassword = enterPassword .. self.Number
								surface.PlaySound( "buttons/combine_button1.wav" )
							else
								surface.PlaySound( "npc/roller/mine/rmine_blip3.wav" )
							end
						end
					end
					num = num + 1
				end
			end

			local CloseButton = vgui.Create( "DButton", KeypadWindow )
			CloseButton:SetPos( 500, 0 )
			CloseButton:SetSize( 20, 40 )
			CloseButton:SetText( "X" )
			CloseButton:SetTextColor(Color(255,255,255))
			CloseButton.DoClick = function( self )
				this.Guess = nil
				this.Waiting = false
				this.Reset = nil
				this.NextGuess = nil
				KeypadWindow:Close()
				surface.PlaySound( "buttons/combine_button2.wav" )
			end
			CloseButton.Paint = function( self, w, h )
				if CloseButton:IsHovered() then
					draw.RoundedBox( 0, 0, 0, w, h, Color( 128, 0, 0, 255 ) )
				else
					draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0, 255 ) )
				end
				surface.SetDrawColor( color_black )
			end
		else
			surface.PlaySound( "player/suit_denydevice.wav" )
		end
	end
end

function SWEP:Initialize()

	self:SetHoldType( "slam" )
	
	if CLIENT then

		self.Guess = nil

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

function SWEP:Deploy()
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
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
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
