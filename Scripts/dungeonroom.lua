local DungeonRoom = {}
DungeonRoom.__index = DungeonRoom

function DungeonRoom.new(x,y)
	local self = setmetatable({}, DungeonRoom)
	self.x = x
	self.y = y
	return self
end

function DungeonRoom:getColor()
	return 0.2, 0.2, 0.2
end

return DungeonRoom