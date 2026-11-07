local Enemy = require("scripts.enemy")
local Player = require("scripts.player")
local Combat = require("scripts.combat")

local tempMessage = "" --temporary message displayed to player
local player   -- player table
local currentEnemy -- self explanatory, the current enemy

--game state. Theres "map" which is outside of battle, and "combat" which is inside battle
local state = "map"

local function startCombat(enemyType)
    currentEnemy = Enemy.new(enemyType)
    tempMessage = "Here's a real high-class bout!" 
    state = "combat"
end

--this loads at boot (also for restarting)
function love.load()
    player = Player.new()
    currentEnemy = nil
    tempMessage = ""
    state = "map"
end

--this is for any animations or timers later on
function love.update(dt)
end

function love.draw()
    love.graphics.print("Doodle Dungeon", 1, 1)
    love.graphics.print("Player HP: " .. player.health, 20, 20)
    love.graphics.print("Weapon: " .. player.weapon.name, 20, 40)
    
    if state == "map" then
        --for drawing map screen eventually
        love.graphics.print("Map test. Click to combat", 20, 80)
    elseif state == "combat" then
        love.graphics.print(currentEnemy.name .. " HP: " .. currentEnemy.health, 20,80)
    elseif state == "gameover" then
        love.graphics.print (tempMessage, 20, 120)
    end

    love.graphics.print (tempMessage, 20, 120)
end

function love.mousepressed(x, y, button)
    if button ~= 1 then return end
    if state == "map" then
        --this is for clicking rooms, need to do. use "startCombat(room.enemy)" when entering room with enemy.
        startCombat(Enemy.RandomEnemy())--this is just a test fight, should get replaced eventually

    elseif state == "combat" then
        tempMessage = Combat.CycleTurn(player, currentEnemy)
        if player.health <=0 then
            state = "gameover"
        elseif currentEnemy.health <= 0 then
            state = "map" --sets state to gameover when player dies, goes back to map when enemy dies.
        end

    elseif state == "gameover" then
        love.load()--this basically restarts when ded
    end
end
