-- create some fonts we'll user later
surface.CreateFont( "KeypadNumbers", {
    font = "Arial",
    size = 48,
    weight = 2000
} )

surface.CreateFont( "KeypadDisplay", {
    font = "Arial",
    size = 20,
    weight = 5000,
    antialias = false
} )

surface.CreateFont( "CrackerDisplay", {
    font = "Courier New",
    size = 100,
    weight = 5000,
    antialias = false,
    scanlines = 4,
    blursize = 2
} )

-- change the shader of some materials
-- this is some genius shit
-- hopefully this always runs properly and on-time, there's no reason it shouldn't...right?
file.CreateDir( "sweptthrone" )

if not file.Exists( "data/sweptthrone/cracker_sheet_unlit.vmt", "GAME" ) then
    file.Write( "sweptthrone/cracker_sheet_unlit.vmt", string.Replace( file.Read( "materials/models/weapons/v_models/c4/c4_light.vmt", "GAME" ), "VertexLitGeneric", "UnlitGeneric" ) )
end

if not file.Exists( "data/sweptthrone/keypad_sheet_unlit.vmt", "GAME" ) then
    file.Write( "sweptthrone/keypad_sheet_unlit.vmt", string.Replace( file.Read( "materials/models/props_lab/keypad_sheet.vmt", "GAME" ), "VertexLitGeneric", "UnlitGeneric" ) )
end

KeypAdderMats = KeypAdderMats or {}
KeypAdderMats.keypadMat = Material( "../data/sweptthrone/keypad_sheet_unlit" )
KeypAdderMats.crackerMat = Material( "../data/sweptthrone/cracker_sheet_unlit" )

-- create some materials we'll use later
local keypadIcon = Material( "keypadder/keypad_icon.png" )
local doorknobIcon = Material( "keypadder/doorknob_icon.png" )

-- arc drawing code (not mine)
-- SRC: https://gist.github.com/theawesomecoder61/d2c3a3d42bbce809ca446a85b4dda754
function draw.Arc(cx,cy,radius,thickness,startang,endang,roughness,color)
	surface.SetDrawColor(color)
	surface.DrawArc(surface.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness))
end

function surface.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness)
	local triarc = {}
	-- local deg2rad = math.pi / 180
	
	-- Define step
	local roughness = math.max(roughness or 1, 1)
	local step = roughness
	
	-- Correct start/end ang
	local startang,endang = startang or 0, endang or 0
	
	if startang > endang then
		step = math.abs(step) * -1
	end
	
	-- Create the inner circle's points.
	local inner = {}
	local r = radius - thickness
	for deg=startang, endang, step do
		local rad = math.rad(deg)
		-- local rad = deg2rad * deg
		local ox, oy = cx+(math.cos(rad)*r), cy+(-math.sin(rad)*r)
		table.insert(inner, {
			x=ox,
			y=oy,
			u=(ox-cx)/radius + .5,
			v=(oy-cy)/radius + .5,
		})
	end	
	
	-- Create the outer circle's points.
	local outer = {}
	for deg=startang, endang, step do
		local rad = math.rad(deg)
		-- local rad = deg2rad * deg
		local ox, oy = cx+(math.cos(rad)*radius), cy+(-math.sin(rad)*radius)
		table.insert(outer, {
			x=ox,
			y=oy,
			u=(ox-cx)/radius + .5,
			v=(oy-cy)/radius + .5,
		})
	end	
	
	-- Triangulize the points.
	for tri=1,#inner*2 do -- twice as many triangles as there are degrees.
		local p1,p2,p3
		p1 = outer[math.floor(tri/2)+1]
		p3 = inner[math.floor((tri+1)/2)+1]
		if tri%2 == 0 then --if the number is even use outer.
			p2 = outer[math.floor((tri+1)/2)]
		else
			p2 = inner[math.floor((tri+1)/2)]
		end
	
		table.insert(triarc, {p1,p2,p3})
	end
	
	-- Return a table of triangles to draw.
	return triarc
end

function surface.DrawArc(arc) --Draw a premade arc.
	for k,v in ipairs(arc) do
		surface.DrawPoly(v)
	end
end
-- end stolen code

local ChoiceWindow
local KeypadWindow
function OpenDoorDecisionMenu( door )
    local candidateDoor = door
    local wh = math.min( ScrH() * 0.75, ScrW() * 0.75 )
    local startTime = UnPredictedCurTime()
    local timeToPopup = 0.1

    ChoiceWindow = vgui.Create( "DFrame" )
    ChoiceWindow:SetPos( 0, 0 )
    ChoiceWindow:SetSize( wh + 20, wh )
    ChoiceWindow:SetTitle( "" )
    ChoiceWindow:SetVisible( true )
    ChoiceWindow:SetDraggable( false )
    ChoiceWindow:ShowCloseButton( false )
    ChoiceWindow:MakePopup()
    ChoiceWindow:SetKeyboardInputEnabled( false )
    ChoiceWindow:Center()
    ChoiceWindow.leftA = 128
    ChoiceWindow.riteA = 128
    ChoiceWindow.Choice = nil
    function ChoiceWindow:Paint()
        draw.Arc( wh/2,      wh/2, math.Clamp( ( ( UnPredictedCurTime() - startTime ) / timeToPopup ) * wh/2, 0, wh/2 ), math.Clamp( ( ( UnPredictedCurTime() - startTime ) / timeToPopup ) * ( wh * 0.216 ), 0, ( wh * 0.216 ) ), 90, 270, 3, Color( 255, 255, 255, self.leftA ) )
        draw.Arc( wh/2 + 20, wh/2, math.Clamp( ( ( UnPredictedCurTime() - startTime ) / timeToPopup ) * wh/2, 0, wh/2 ), math.Clamp( ( ( UnPredictedCurTime() - startTime ) / timeToPopup ) * ( wh * 0.216 ), 0, ( wh * 0.216 ) ), -90, 90, 3, Color( 255, 255, 255, self.riteA ) )
    
        surface.SetMaterial( doorknobIcon )
        surface.SetDrawColor( 255, 255, 255, math.Clamp( ( ( UnPredictedCurTime() - startTime ) / timeToPopup ) * 255, 0, 255 ) )
        surface.DrawTexturedRect( ( wh * 0.0284 ), wh/2 - ( wh * 0.079 ), ( wh * 0.158 ), ( wh * 0.158 ) )

        surface.SetMaterial( keypadIcon )
        surface.SetDrawColor( 255, 255, 255, math.Clamp( ( ( UnPredictedCurTime() - startTime ) / timeToPopup ) * 255, 0, 255 ) )
        surface.DrawTexturedRect( wh-( wh * 0.0284 )-( wh * 0.133 ), wh/2 - ( wh * 0.079 ), ( wh * 0.158 ), ( wh * 0.158 ) )
    end
    function ChoiceWindow:Think()
        self.leftA = 128
        self.riteA = 128
        self.Choice = nil
        if gui.MouseX() <= ScrW() / 2 - 10 and math.Distance( ScrW() / 2, ScrH() / 2, gui.MouseX(), gui.MouseY() ) > math.min( ScrH() * 0.075, ScrW() * 0.075 ) then
            self.leftA = 255
            self.Choice = 1
        end
        if gui.MouseX() >= ScrW() / 2 + 10 and math.Distance( ScrW() / 2, ScrH() / 2, gui.MouseX(), gui.MouseY() ) > math.min( ScrH() * 0.075, ScrW() * 0.075 ) then
            self.riteA = 255
            self.Choice = 2
        end

        if not LocalPlayer():KeyDown( IN_USE ) then
            if self.Choice == 1 then
                net.Start( "KeypAddUse" )
                    net.WriteEntity( candidateDoor )
                net.SendToServer()
            elseif self.Choice == 2 then
                if not IsValid( KeypadWindow ) then
                local enterPassword = ""
                local keypadMat = Material( "../data/sweptthrone/keypad_sheet_unlit" )
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

                KeypadWindow = vgui.Create( "DFrame" )
                KeypadWindow:SetPos( 0, 0 )
                KeypadWindow:SetSize( 320, 550 )
                KeypadWindow:SetTitle( "" )
                KeypadWindow:SetVisible( true )
                KeypadWindow:SetDraggable( false )
                KeypadWindow:ShowCloseButton( false )
                KeypadWindow:MakePopup()
                KeypadWindow:Center()
                function KeypadWindow:Think()
                    -- recreating KeyPressed logic
                    if input.IsKeyDown( KEY_PAD_ENTER ) or input.IsKeyDown( KEY_ENTER ) then
                        if enterPassword == "" then enterPassword = "0" end
                        net.Start( "KeypAddDoor" )
                            net.WriteUInt( 1, 2 )
                            net.WriteUInt( tonumber( enterPassword ), 20 )
                            net.WriteEntity( candidateDoor )
                        net.SendToServer()
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
                            if #enterPassword < 6 then
                                enterPassword = enterPassword .. num
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
                    surface.SetMaterial( keypadMat )
                    surface.DrawTexturedRectUV( 0, 0, w-20, h, 0, 0, 300/550, 1 )

                    surface.SetDrawColor( 97, 252, 3 )
                    draw.NoTexture()
                    surface.DrawRect( 69, 77, 162, 93 )

                    surface.SetTextPos( 80, 100 )
                    surface.SetFont( "KeypadNumbers" )
                    surface.SetTextColor( 64, 64, 64 )
                    surface.DrawText( enterPassword )
                end

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
                            if self:IsDown() or inputState[ self.Number + 1 ] == 2 or inputState[ self.Number + 37 ] == 2 then
                                surface.SetDrawColor( 115, 73, 66 )
                            end
                            draw.NoTexture()
                            surface.DrawRect( 0, 0, w, h )
                        end
                        function NumButton:DoClick()
                            if #enterPassword < 6 then
                                enterPassword = enterPassword .. self.Number
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
                    enterPassword = ""
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
                    if enterPassword == "" then enterPassword = "0" end
                    net.Start( "KeypAddDoor" )
                        net.WriteUInt( 1, 2 )
                        net.WriteUInt( tonumber( enterPassword ), 20 )
                        net.WriteEntity( candidateDoor )
                    net.SendToServer()
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
            self:Close()
        end
    end
end

hook.Add( "KeyPress", "KeypadDecisionWindow", function( ply, key )
    if key == IN_USE then
        local tr = LocalPlayer():GetEyeTrace()
        local ent = tr.Entity
        if tr.HitPos:DistToSqr( tr.StartPos ) <= 84*84 and IsValid( ent ) and ent:GetClass() == "prop_door_rotating" and ent:GetModel() == "models/props_c17/door01_left.mdl" and ent:GetNWBool( "KeypAdded", false ) and not IsValid( ChoiceWindow ) then
            OpenDoorDecisionMenu( ent )
        end
    end
end )

net.Receive( "KeypAddDoor", function()
    local opcode = net.ReadUInt( 1 )

    if opcode == 0 then -- opcode 0 = using keypAdded door, this actually isn't used anymore
        OpenDoorDecisionMenu( net.ReadEntity() )
    elseif opcode == 1 then -- opcode 1 = receive wordle guess
        local guess = net.ReadUInt( 20 )

        if LocalPlayer():Alive() and IsValid( LocalPlayer():GetActiveWeapon() ) and LocalPlayer():GetActiveWeapon():GetClass() == "weapon_st_keypadcracker" then
            LocalPlayer():GetActiveWeapon().Guess = guess
            LocalPlayer():GetActiveWeapon().Waiting = false
            LocalPlayer():GetActiveWeapon().NextGuess = CurTime() + 5
        end
    end
end )

-- this hook creates a timer that runs ten times per second forever.
-- i tried a PostOpaqueRenderables hook and it dropped my framerate from 280 to 240! (280 times per sec).
-- i then tried a Tick hook and it dropped it from 280 to 260 (66 times per sec).
-- i settled on this and it had minimal effect on framerate (10 times per sec).
hook.Add( "InitPostEntity", "DrawKeypadFallback", function()
    timer.Create( "CheckKeypAddedDoorsFallback", 0.1, 0, function()
        -- this loop finds all clientside entities and deletes dummy keypads if they have no parent
        -- the class has a space in it!
        for k,v in pairs( ents.FindByClass( "class C_BaseFlex" ) ) do
            if v.IsKeypAdd and not IsValid( v:GetParent() ) then
                v:Remove()
            end
        end
        -- this loop finds all doors and...
        for k,v in pairs( ents.FindByClass( "prop_door_rotating" ) ) do
            -- ...if it has a keypad but not the keypad-door bodygroup, attaches two dummy keypads to replicate it
            if v:GetModel() == "models/props_c17/door01_left.mdl" and v:GetNWBool( "KeypAdded", false ) and v:GetNWBool( "KeypAdded_Fallback", false ) and v:GetBodygroupCount( 1 ) < 4 and not v.Fellback then
                v.Fellback = true
                -- if we go from a map with the keypad-door to a map without and then r_flushlod, the bodygroup will still be 2 and the door will have no handle.
                -- this puts the handle back:
                v:SetBodygroup( 1, 1 )
                v.FrontKeypad = ClientsideModel( "models/props_lab/keypad.mdl" )
                v.FrontKeypad:SetParent( v )
                v.FrontKeypad:SetPos( v:GetBonePosition( 1 ) + ( v:GetUp() * 7 ) )
                v.FrontKeypad:SetAngles( v:GetAngles() )
                v.FrontKeypad.IsKeypAdd = true
                v.BackKeypad = ClientsideModel( "models/props_lab/keypad.mdl" )
                v.BackKeypad:SetParent( v )
                v.BackKeypad:SetPos( v:GetBonePosition( 1 ) + ( v:GetUp() * 7 ) + ( v:GetForward() * -2 ) )
                v.BackKeypad:SetAngles( Angle( v:GetAngles().p, v:GetAngles().y + 180, v:GetAngles().r ) )
                v.BackKeypad.IsKeypAdd = true
                v.FrontKeypad:Spawn()
                v.BackKeypad:Spawn()
            end

            -- if we go from a map without the keypad-door to a map with and then r_flushlod, 
            -- the dummy keypads will still be there on top of the bodygroup keypad.
            -- this removes the dummy keypads and adds the keypad bodygroup
            if v.Fellback and v:GetBodygroupCount( 1 ) == 4 then
                v.Fellback = false
                v:SetBodygroup( 1, 3 )
                v.FrontKeypad:Remove()
                v.BackKeypad:Remove()
            end
        end
    end )
end )