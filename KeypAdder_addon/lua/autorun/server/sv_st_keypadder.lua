util.AddNetworkString( "KeypAddDoor" )
util.AddNetworkString( "KeypAddUse" )

net.Receive( "KeypAddDoor", function( len, ply )

    local opcode = net.ReadUInt( 2 ) -- 00 01 10 11
    local password = net.ReadUInt( 20 )
    local candidateDoor = net.ReadEntity()

    local tr = ply:GetEyeTrace()
    local door = tr.Entity

    if door ~= candidateDoor then return end
    if not IsValid( door ) then return end
    if door:GetClass() ~= "prop_door_rotating" then return end
    if door:GetModel() ~= "models/props_c17/door01_left.mdl" then return end

    if opcode == 0 then -- opcode 0 = install keypad
        -- todo:  need more checks:
        if tr.StartPos:DistToSqr( tr.HitPos ) <= 84*84 then
            sound.Play( "npc/dog/dog_servo12.wav", door:GetBonePosition( 1 ), 80, 100, 1 )
            timer.Simple( 0.4, function()
                local pos = door:GetBonePosition( 1 )
                local ed = EffectData()
                ed:SetOrigin( pos )
                ed:SetNormal( Vector( 0, 0, 1 ) )
                util.Effect( "ManhackSparks", ed )

                sound.Play( "physics/metal/metal_computer_impact_bullet1.wav", door:GetBonePosition( 1 ), 80, 100, 1 )
                -- the doors work without the bodygroup, but a little visuals looks nice.
                -- on models without bodygroup 1.3, it just doesn't change anything.
                door:SetBodygroup( 1, 3 )
                -- this is a purely cosmetic netvar for when the bodygroup does not exist
                door:SetNWBool( "KeypAdded_Fallback", true )
            end )

            -- store password on server only.
            -- this happens immediately so you don't have to wait for the visual to play.
            door.KeypAddPassword = password
            door:SetNWBool( "KeypAdded", true )
            door:Fire( "Lock" )
        end
    elseif opcode == 1 then -- opcode 1 = use keypad
        -- todo:  need more checks:
        if ply:GetUseEntity() == candidateDoor then
            if password == door.KeypAddPassword then
                sound.Play( "buttons/button3.wav", door:GetBonePosition( 1 ), 80, 100, 1 )
                timer.Simple( 0.333, function() sound.Play( "doors/door_latch3.wav", door:GetBonePosition( 1 ), 80, 100, 1 ) end )
                if door.IsLocked then
                    door:Fire( "Unlock" )
                else
                    door:Fire( "Lock" )
                end
            else
                sound.Play( "buttons/button2.wav", door:GetBonePosition( 1 ), 80, 100, 1 )
            end
        end
    elseif opcode == 2 then -- opcode 2 = crack keypad
        -- todo:  need more checks:
        if IsValid( ply:GetActiveWeapon().Cracking ) and door == ply:GetActiveWeapon().Cracking and ply:GetActiveWeapon():GetClass() == "weapon_st_keypadcracker" then
            password = string.Split( password, "" )

            if ply:GetAmmoCount( ply:GetActiveWeapon():GetPrimaryAmmoType() ) < 5 * #password then
                return
            end

            ply:SetAmmo( ply:GetAmmoCount( ply:GetActiveWeapon():GetPrimaryAmmoType() ) - 5 * #password, ply:GetActiveWeapon():GetPrimaryAmmoType() )
            sound.Play( "buttons/combine_button7.wav", door:GetBonePosition( 1 ), 80, 100, 1 )
            -- to play wordle:
            local function foundIndex( haystack, needle )
                for k, v in pairs( haystack ) do
                    if v == needle then
                        return k
                    end
                end
                return nil
            end

            -- this is such a gross hack:
            local outputStr = { "1", "1", "1", "1", "1", "1" }
            local passwordTab, doorPassTab = { "0", "0", "0", "0", "0", "0" }, { "0", "0", "0", "0", "0", "0" }
            password = table.Merge( passwordTab, password )
            doorPass = string.Split( door.KeypAddPassword, "" )
            doorPass = table.Merge( doorPassTab, doorPass )

            for i = 1, #password do
                if doorPass[ i ] == password[ i ] then
                    outputStr[ i ] = "3"

                    if outputStr[ i ] == "2" or outputStr[ i ] == "3" then
                        doorPass[ foundIndex( doorPass, password[ i ] ) ] = "0"
                    end
                end
            end
            for i = 1, #password do
                if foundIndex( doorPass, password[ i ] ) and outputStr[ i ] == "1" then
                    outputStr[ i ] = "2"
                    
                    if outputStr[ i ] == "2" or outputStr[ i ] == "3" then
                        doorPass[ foundIndex( doorPass, password[ i ] ) ] = "0"
                    end
                end
            end
            -- holy fuck
            outputStr = tonumber( table.concat( outputStr, "" ) )
            timer.Simple( 3, function()
                net.Start( "KeypAddDoor" )
                    net.WriteUInt( 1, 1 )
                    net.WriteUInt( outputStr, 20 )
                net.Send( ply )
            end )
        end
    elseif opcode == 3 then -- opcode 3 = remove keypad
        -- todo:  need more checks, mainly to make sure the player is allowed to remove a keypad
        if tr.StartPos:DistToSqr( tr.HitPos ) <= 84*84 then
            local pos = door:GetBonePosition( 1 )
            local ed = EffectData()
            ed:SetOrigin( pos )
            ed:SetNormal( Vector( 0, 0, 1 ) )
            util.Effect( "ManhackSparks", ed )

            sound.Play( "physics/metal/metal_solid_impact_bullet" .. math.random( 1 ,4 ) .. ".wav", door:GetBonePosition( 1 ), 80, 100, 1 )
            door:SetBodygroup( 1, 1 )
            door:SetNWBool( "KeypAdded_Fallback", false )

            door.KeypAddPassword = nil
            door:SetNWBool( "KeypAdded", false )
            door:Fire( "Unlock" )
        end
    end

end )

net.Receive( "KeypAddUse", function( len, ply )

    local candidate = net.ReadEntity()

    local door = ply:GetUseEntity()

    if door ~= candidate then return end

    -- todo:  need more checks
    if IsValid( door ) and door:GetClass() == "prop_door_rotating" and door:GetModel() == "models/props_c17/door01_left.mdl" and door:GetNWBool( "KeypAdded", false ) then
        -- use this so it's compatible with Stealthy Door Opening
        door:Fire( "Use", "", 0, ply, ply )
    end

end )

-- this hook is to store the locked state of the door.
-- i guess there's no way to tell this on the entity itself?
-- certain things can unlock doors and the keypad would still see it as locked otherwise,
-- so you'd try to lock an unlocked door but would end up unlocking it
hook.Add( "AcceptInput", "UnlockAndLockKeypAddedDoors", function( ent, inp, act, cal, val )
    if IsValid( ent ) and ent:GetClass() == "prop_door_rotating" and ent:GetModel() == "models/props_c17/door01_left.mdl" and ent:GetNWBool( "KeypAdded", false ) then
        if string.lower( inp ) == "unlock" then
            ent.IsLocked = false
        end
        if string.lower( inp ) == "lock" then
            ent.IsLocked = true
        end
    end
end )

-- this hook prevents using a keypadded door so that we can show a menu instead
-- this happens on the client instantly
hook.Add( "PlayerUse", "DoorKeypAdds", function( ply, ent )

    if ent:GetNWBool( "KeypAdded", false ) then return false end

end )