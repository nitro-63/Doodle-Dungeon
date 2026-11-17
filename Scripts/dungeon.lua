local DungeonRoom = require("scripts.dungeonroom")

local Dungeon = {}
Dungeon.size = 21
Dungeon.grid = {}

function Dungeon.init()
	Dungeon.grid = {}
	for x = 1, Dungeon.size do
		Dungeon.grid[x] = {}
		for y = 1, Dungeon.size do
			Dungeon.grid[x][y] = nil
		end
	end
end

function Dungeon.getRoom(x,y)
	if x >= 1 and x <= Dungeon.size and y >= 1 and y <= Dungeon.size then
		return Dungeon.grid[x][y]
	end
	return nil
end

function Dungeon.generate(energy)
	energy = energy or 20
	Dungeon.init()

	local startX, startY = 11, 11
	Dungeon.grid[startX][startY] = DungeonRoom.new(startX, startY)

	local currentPassRooms = { {x = startX, y = startY} }

	local directions = {
		{x = 0, y = -1},
		{x = 0, y = 1},
		{x = -1, y = 0},
		{x = 1, y = 0}
	}

	-- Room generation algorithm made with the assistance of Gemini for fine-tuning
	-- Todo: replace with an original algorithm
	for i = 1, energy do
        local nextPassRooms = {}
        for roomIndex, roomPos in ipairs(currentPassRooms) do
            local validNeighbors = {}
            for directionIndex, dir in ipairs(directions) do
                local nx, ny = roomPos.x + dir.x, roomPos.y + dir.y

                if nx >= 1 and nx <= Dungeon.size and ny >= 1 and ny <= Dungeon.size then
                    if Dungeon.grid[nx][ny] == nil then
                        table.insert(validNeighbors, {x = nx, y = ny})
                    end
                end
            end

            if #validNeighbors > 0 then
                local randomIndex = math.random(#validNeighbors)
                local chosen = table.remove(validNeighbors, randomIndex)
            
                Dungeon.grid[chosen.x][chosen.y] = DungeonRoom.new(chosen.x, chosen.y)
                table.insert(nextPassRooms, {x = chosen.x, y = chosen.y})
            end
        end

        if #nextPassRooms == 0 then break end
        currentPassRooms = nextPassRooms
    end
end

return Dungeon