local Enemy = require("scripts.enemy")
local Player = require("scripts.player")
local Combat = require("scripts.combat")

local tempMessage = "" --temporary message displayed to player
local player   -- player table
local currentEnemy -- self explanatory, the current enemy

--game state. Theres "map" which is outside of battle, and "combat" which is inside battle
local state = "map"
local combatphase = "action"

local attackbutton
local healbutton

local function makeButtons()
    local h = love.graphics.getHeight()
    attackbutton = {x = 20, y = h - 70, w = 130, h = 45, label = "Attack"}
    healbutton = {x = 180, y = h - 70, w = 130, h = 45, label = "Heal"}
end

local function inButton(btn, x, y)
    return x >= btn.x and x <= btn.x + btn.w and y >= btn.y and y <= btn.y + btn.h
end

local function drawButton(btn, enabled)
    if enabled then
        love.graphics.setColor(0, 150, 0)
    else
        love.graphics.setColor(0.5, 0.5, 0.5)
    end
    love.graphics.rectangle("line", btn.x, btn.y, btn.w, btn.h)
    love.graphics.printf(btn.label, btn.x, btn.y + btn.h / 2 - 7, btn.w, "center")
    love.graphics.setColor(1, 1, 1)
end

local function startCombat(enemyType)
    currentEnemy = Enemy.new(enemyType)
    tempMessage = "Here's a real high-class bout!" 
    state = "combat"
    combatphase = "message"
end

--this loads at boot (also for restarting)
function love.load()
    player = Player.new()
    currentEnemy = nil
    tempMessage = ""
    state = "map"
    combatphase = "action"
    makeButtons()
end

--this is for any animations or timers later on
function love.update(dt)
end

function love.draw()
    love.graphics.print("Doodle Dungeon", 1, 1)
    love.graphics.print("Player HP: " .. player.health, 20, 20)
    love.graphics.print("Weapon: " .. player.weapon.name, 20, 40)
    love.graphics.print("Potions: ".. player.potions, 20, 60)
    love.graphics.setColor(0, 150, 0)
    
    if state == "map" then
        --for drawing map screen eventually
        love.graphics.print("Map test. Click to combat", 20, 80)
    elseif state == "combat" then
        love.graphics.print(currentEnemy.name .. " HP: " .. currentEnemy.health, 20,80)

        local action = combatphase == "action"
        drawButton(attackbutton, action)
        drawButton(healbutton, action and player.potions > 0)
        
        if combatphase == "message" then
            love.graphics.print("Click to continue", 340, attackbutton.y + 18)
        end
    end

    love.graphics.print (tempMessage, 20, 120)
    love.graphics.setColor(0, 150, 0)
end

function love.mousepressed(x, y, button)
    if button ~= 1 then return end
    if state == "map" then
        --this is for clicking rooms, need to do. use "startCombat(room.enemy)" when entering room with enemy.
        startCombat(Enemy.RandomEnemy())--this is just a test fight, should get replaced eventually

    elseif state == "combat" then
        if combatphase == "action" then
            if inButton(attackbutton, x, y) then
            tempMessage = Combat.CycleTurn(player, currentEnemy)
            combatphase = "message"
            elseif inButton(healbutton, x, y) and player.potions > 0 then
                tempMessage = Combat.healTurn(player, currentEnemy)
                combatphase = "message"
            end
        else
            if player.health <= 0 then
                state = "gameover"
            elseif currentEnemy.health <= 0 then
                state = "map"
                tempMessage = ""
            else
                combatphase = "action"
            end
        end
    
    elseif state == "gameover" then
        love.load()
    end
end