local Enemy = {}

--Enemy Data
--If ever add new enemy, add to table below and to Combat.chart in combat.lua
--stored as string for rooms
Enemy.types = {
    slime   = {name = "Slime", health = 25, damage = 3 },
    balloon = {name = "Balloon", health = 15, damage = 7 },
    skeleton = {name = "Skeleton", health = 20, damage = 5 },
}

--makes a new enemy from a type name. This lets each enemy have its own health and damage values, instead of sharing the same values from the Enemy.types table
function Enemy.new(typeName)
    local stats = Enemy.types[typeName]
    return {
        type = typeName,
        name = stats.name,
        health = stats.health,
        damage = stats.damage,
    }
end

--Grabs a random enemy type
function Enemy.RandomEnemy()
    local names = {}
    for name, _ in pairs(Enemy.types) do
        table. insert(names, name)
    end
    return names [love.math.random(#names)]
end



return Enemy