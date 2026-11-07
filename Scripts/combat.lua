local Combat = {}

--Multipliers (still subject to change)
local CritMultiplier = 1.75
local Weak = 1.75
local Neutral = 1
local Strong = 0.75

--enemy type weakness table 
-- Combat.chart[damageType][enemyType] = multiplier
Combat.chart = {
    slash = {
        slime = Weak,
        balloon = Neutral,
        skeleton = Strong,
    },
    pierce = {
        slime = Strong, 
        balloon = Weak,
        skeleton = Neutral,
    },
    blunt = {
        slime = Neutral,
        balloon = Strong,
        skeleton = Weak,
    },
}

--this returns multiplier based on damage type and enemy type. Used in Combat.playerAttack()
--
function Combat.getMultiplier(damageType, enemyType)
    local row = Combat.chart[damageType] or {}
    return row [enemyType] or Neutral
end

--Players attack turn. affects enemy health value
--basically returns only the damage dealt and wether it was a crit or not. 
function Combat.playerAttack(player, enemy)
    local multiplier = Combat.getMultiplier(player.weapon.damageType, enemy.type)
    local damage = player.weapon.damage * multiplier
    

    --love.math.random() returns a float between 0 and 1. If the random number is less than the crit chance, then it is a crit.
    local isCrit = love.math.random() < player.critChance
    if isCrit then
        damage = damage * CritMultiplier
    end
    
    damage = math.floor(damage)
    enemy.health = enemy.health - damage
    if enemy.health < 0 then
        enemy.health = 0
    end
    return damage, isCrit
end

--enemy attack turn. affects player health value
function Combat.enemyAttack(enemy, player)
    local damage = enemy.damage
    player.health = player.health - damage
    if player.health < 0 then
        player.health = 0
    end
    return damage
end

--Runs a full turn of combat, returning a message string to display to the player.
--player attacks first, then enemy attacks if still alive. If player dies, the message will say so.
function Combat.CycleTurn(player, enemy)
    local damage, isCrit = Combat.playerAttack(player, enemy)
    local message = "You hit " .. enemy.name .. " for " .. damage .. "!"
    if isCrit then
        message = message .. " CRIT "
    end

    if enemy.health > 0 then
        local enemyDamage = Combat.enemyAttack(enemy, player)
        message = message .. "\n" .. enemy.name .. " deals " .. enemyDamage .. " damage!"
    else
        message = message .. "\n" .. enemy.name .. " has been killed."
    end

    if player.health <= 0 then
        message = message .. "\n" .. "You died bruh"
    end
    return message
end

return Combat