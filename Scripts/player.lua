local Player = {}

-- Weapon data table. 
Player.weapons = {
    sword = { name = "Sword", damage = 7, damageType = "slash" },
    spear = { name = "Spear", damage = 6, damageType = "pierce" },
    mace = { name = "Mace", damage = 6, damageType = "blunt" },
}

--makes player. Call once at start of run
function Player.new()
    return {
        health = 50,
        weapon = Player.weapons.spear, --current weapon. (Just as spear for damage testing)
        critChance = 0.07,
    }
end

--grabs a random weapon type name string from the Player.weapons table
function Player.RandomWeapon()
    local names = {}
    for name, _ in pairs(Player.weapons) do
        table.insert(names, name)
    end
    return names[love.math.random(#names)]
end

return Player