local Enemy = require("scripts.enemy")
local Player = require("scripts.player")
local Combat = require("scripts.combat")
local Dungeon = require("scripts.dungeon")
local DungeonRoom = require("scripts.dungeonroom")

local tempMessage = "" --temporary message displayed to player
local player   -- player table
local currentEnemy -- self explanatory, the current enemy

--game state. Theres "map" which is outside of battle, and "combat" which is inside battle
local state = "map"
local combatphase = "action"

local tileSize = 6
local gridOffsetX = 200
local gridOffsetY = -50

local roomOffsetX = 0
local roomOffsetY = 80

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

local playerPos = { x = 11, y = 11 }
local function startCombat(enemyType)
    currentEnemy = Enemy.new(enemyType)
    tempMessage = "Here's a real high-class bout!" 
    state = "combat"
    combatphase = "message"
end

--this loads at boot (also for restarting)
function love.load()
    math.randomseed(os.time())
    Dungeon.generate(20)

    local startingRoom = Dungeon.getRoom(11, 11)
    playerPos = { x = 11, y = 11 }
    
    player = Player.new()
    currentEnemy = nil
    tempMessage = ""
    state = "map"
    combatphase = "action"
    makeButtons()

    roomSprite = love.graphics.newImage("Assets/RoomSprite.png")
    doorUpperLeft = love.graphics.newImage("Assets/Door_UpperLeft.png")
    doorUpperRight = love.graphics.newImage("Assets/Door_UpperRight.png")
    doorLowerLeft = love.graphics.newImage("Assets/Door_LowerLeft.png")
    doorLowerRight = love.graphics.newImage("Assets/Door_LowerRight.png")

    love.graphics.setDefaultFilter("nearest", "nearest", 1)
end

--this is for any animations or timers later on
function love.update(dt)
end

function love.draw()
    --love.graphics.setColor(1, 1, 1)
    love.graphics.print("Doodle Dungeon", 1, 1)
    love.graphics.print("Player HP: " .. player.health, 20, 20)
    love.graphics.print("Weapon: " .. player.weapon.name, 20, 40)
    love.graphics.print("Potions: ".. player.potions, 20, 60)
    love.graphics.setColor(0, 150, 0)

    love.graphics.draw(roomSprite, roomOffsetX, roomOffsetY, 0, 1.5, 1.5)

    local roomUpperLeft = Dungeon.getRoom(playerPos.x - 1, playerPos.y)
    local roomUpperRight = Dungeon.getRoom(playerPos.x, playerPos.y - 1)
    local roomLowerLeft = Dungeon.getRoom(playerPos.x, playerPos.y + 1)
    local roomLowerRight = Dungeon.getRoom(playerPos.x + 1, playerPos.y)

    if roomUpperLeft then
        love.graphics.draw(doorUpperLeft, roomOffsetX, roomOffsetY, 0, 1.5, 1.5)
    end
    
    if roomUpperRight then
        love.graphics.draw(doorUpperRight, roomOffsetX, roomOffsetY, 0, 1.5, 1.5)
    end
    
    if roomLowerLeft then
        love.graphics.draw(doorLowerLeft, roomOffsetX, roomOffsetY, 0, 1.5, 1.5)
    end
    
    if roomLowerRight then
        love.graphics.draw(doorLowerRight, roomOffsetX, roomOffsetY, 0, 1.5, 1.5)
    end

    if state == "map" then
        --for drawing map screen eventually
        love.graphics.print("Map test. Click to combat", 20, 80)
        
        love.graphics.push()
        love.graphics.translate(gridOffsetX, gridOffsetY)
        love.graphics.scale(1.0, 0.5)
        love.graphics.rotate(math.pi / 4)

        love.graphics.setColor(0.2, 0.6, 0.1)
        love.graphics.rectangle("line", gridOffsetX, gridOffsetY, Dungeon.size * tileSize, Dungeon.size *tileSize)
        
        for x = 1, Dungeon.size do
            for y = 1, Dungeon.size do
                local room = Dungeon.getRoom(x, y)

                if room then
                    local rx = gridOffsetX + (x - 1) * tileSize
                    local ry = gridOffsetY + (y - 1) * tileSize

                    local r, g, b = room:getColor()
                    love.graphics.setColor(r, g, b)

                    love.graphics.rectangle("fill", rx, ry, tileSize, tileSize)

                    if playerPos.x == x and playerPos.y == y then
                        love.graphics.setColor(0.2, 0.6, 0.1)
                        love.graphics.rectangle("line", rx - 1, ry - 1, tileSize, tileSize)
                    end
                end
            end
        end
        
        love.graphics.pop()
    elseif state == "combat" then
        love.graphics.print(currentEnemy.name .. " HP: " .. currentEnemy.health, 20,80)
        local action = combatphase == "action"
        drawButton(attackbutton, action)
        drawButton(healbutton, action and player.potions > 0)

        if combatphase == "message" then
            love.graphics.print("Click to continue", 340, attackbutton.y + 18)
        end

    elseif state == "gameover" then
        love.graphics.print (tempMessage, 20, 120)
    end

    love.graphics.setColor(0.2, 0.6, 0.1)
    love.graphics.print (tempMessage, 20, 120)
end

function love.keypressed(key)
    local newX, newY = playerPos.x, playerPos.y

    if state == "map" then
        if key == "up" then 
            newY = newY - 1
        elseif key == "down" then 
            newY = newY + 1
        elseif key == "left" then 
            newX = newX - 1
        elseif key == "right" then 
            newX = newX + 1
        end
    
        local targetRoom = Dungeon.getRoom(newX, newY)
        if targetRoom then
            playerPos.x, playerPos.y = newX, newY
        end
    end
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