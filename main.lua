
game_state = 0

score = 0
level = 1
frame = 0

pacman = { }
ghosts = { }
ghost  = { }

function next_sprite(o)
	if o.current_sprite <= count(o.sprites) then
		o.current_sprite += 1
	else
		o.current_sprite = 0
	end
end

function pacman:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.x = x
	self.y = y
	self.vx = 0
	self.vy = 0
	self.width = 11
	self.height = 11
	self.sprites = {0, 2, 4, 2}
	self.current_sprite = 1
	self.lives = lives or 3
	self.next_sprite = next_sprite
	self.facex = false
	self.facey = false
	return o
end

function ghost:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.x = x
	self.y = y
	self.vx = 0
	self.vy = 0
	self.width = 11
	self.height = 3
	self.sprite = sprite or 2
	self.mvx = 2
	return o
end

function collision(a, b)
	-- classic collision algo
	if (a.x) <= (b.x + b.width) and (a.x + a.width) >= b.x and (a.y) <= (b.y + b.height) and (a.y + a.height) >= b.y then
		return true
	else
		return false
	end
end

function collision_next_frame(a, b)
	-- classic collision algo
	if (a.x + a.vx) <= (b.x + b.width + b.vx) and (a.x + a.width + a.vx) >= (b.x  + b.vx) and (a.y + a.vy) <= (b.y + b.height + b.vy) and (a.y + a.height + a.vy) >= (b.y + b.vy) then
		return true
	else
		return false
	end
end

function bounce()
end

function _init()
	pacman = pacman:new{x = 64, y = 64, lives = 3}

	game_state = 0
end

function _update()
	if frame % 3 == 0 then
		pacman:next_sprite()
		if frame > 60 then frame = 1 end
	end
	
	
	-- player inputs
	if btn(0) then 
		pacman.vx = -1
		pacman.facex = true
	end
	if btn(1) then 
		pacman.vx = 1
		pacman.facex = false
	end
	if btn(2) then 
		pacman.vy = -1
	end
	if btn(3) then 
		pacman.vy = 1
	end
	
	pacman.x += pacman.vx
	pacman.y += pacman.vy
	pacman.vx = 0
	pacman.vy = 0
	
	frame += 1	
end

function _draw()
	-- clear screen
	cls(0)
	
	if game_state == 0 or game_state == 1 then
		print("level:"..level, 0, 0)
		print("score:"..score, 45, 0)
		print("lives:"..pacman.lives, 90, 0)
		
		map( 0, 0, 0, 6, 128, 32)
		
		spr(pacman.sprites[pacman.current_sprite], pacman.x, pacman.y, 2, 2, pacman.facex)
		
	elseif game_state == 3 then
		print("game over", 45, 45)
		print("final level:"..level)
		print("final score:"..score)
	elseif game_state == 4 then
		print("level cleared!", 45, 45)
		print("final level:"..level)
		print("final score:"..score)
		print("press x to continue to next level")
	end
end
