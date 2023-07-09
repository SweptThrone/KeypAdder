hook.Add( "Initialize", "KeypAdderCrackerAmmoType", function()
    game.AddAmmoType( {
        name = "Keypad Cracker Charge",
        dmgtype = DMG_SHOCK, -- who cares
        maxcarry = 100
    } )

    if CLIENT then
        language.Add( "Keypad Cracker Charge_ammo", "Keypad Cracker Charge" )
    end
end )