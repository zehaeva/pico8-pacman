
game_state = 0

lives = 3
score = 0
level = 1

bricks = { }
brick  = { }
paddle = { }
balls  = { }
ball   = { }

function brick:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.x = x
	self.y = y
	self.vx = 0
	self.vy = 0
	self.width = 7
	self.height = 3
	self.sprite = sprite or 1
	self.score = score or 100
	return o
end

function paddle:new(o)
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

function ball:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.x = x
	self.y = y
	self.vx = vx or 0
	self.vy = vy or 0
	self.width = 2
	self.height = 2
	self.sprite = sprite or 0
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

function fill_bricks()
	startx = 12
	starty = 10
	width = 8
	height = 4
	
	for i=0, 11 do
		for j=0, 10 do
			add(bricks, brick:new{x=(i * (width + 1)) + startx, y=(j * (height + 1)) + starty, sprite=1, score=100})
		end
	end
end

function _init()
	lives = 3

	fill_bricks()

	paddle = paddle:new{x = 58, y = 120, sprite = 2}

	add(balls, ball:new{x = 63, y = 117, vx = 0, vy = 1})

	game_state = 0
end

function _update()
	if count(balls) == 0 and lives > 1 and (game_state == 0 or game_state == 1) then
		lives -= 1
		add(balls, ball:new{x = paddle.x + 4, y = paddle.y - 4, vx = 0, vy = 1})
	elseif game_state == 4 and btn(4) then
		level += 1
		game_state = 0
		fill_bricks()
	elseif count(balls) == 0 then
		game_state = 3
	elseif count(bricks) <= 0 and lives >= 1 and (game_state == 0 or game_state == 1) then
		game_state = 4
	end
	
	if game_state == 0 or game_state == 1 then
		-- player inputs
		if btn(0) and paddle.x > 0 then 
			paddle.vx = paddle.mvx * -1
		end
		if btn(1) and paddle.x <= 120 then 
			paddle.vx = paddle.mvx
		end
		
		if btn(4) and game_state == 0 then
			game_state = 1
			for a in all(balls) do
				a.vy = -1
			end
		end
		
		deleteballs  = {}
		deletebricks = {}
		for i, a in pairs(balls) do
			-- check wall bounce
			if (a.x + a.vx) <= 0 or (a.x + a.vx) >= 128 then
				a.vx = a.vx * -1
			end
			if (a.y + a.vy) <= 0 then
				a.vy = a.vy * -1
			end
			
			-- remove balls that the paddle misses
			if a.y + a.vy >= 128 then
				add(deleteballs, i)
			end
			
			nfx = flr((a.x + a.vx))
			nfy = flr((a.y + a.vy))
			
			-- if the ball hits a paddle send the ball back
			if collision_next_frame(paddle, a) then
				-- invert the up down
				a.vy = (a.vy + paddle.vy) * -1
				if a.vx < 0 then
					direction = -1
				else
					direction = 1
				end
				a.vx = min(a.vx + ((rnd(10) * .1) + paddle.vx) * direction, (2 * direction))
			end
		
		-- if the ball hits a block destroy it and reflect it
			for j, b in pairs(bricks) do
				if collision_next_frame(a, b) then
					add(deletebricks, j)
					
					score += b.score
					--printh(sqrt(nfx*nfx + nfy*nfy))
					pxy = pget(nfx, nfy)
					if (pxy ~= 0) then
						printh("----------------")
						if (pget((nfx + 1), nfy) ~= 0) and 
						   (pget((nfx - 1), nfy) ~= 0) and 
						   ((pget(nfx, (nfy + 1)) ~= 0) or (pget(nfx, (nfy - 1)) ~= 0)) then
							a.vx = a.vx * -1
							--printh("reflect x axis")
						end
						if (pget(nfx, (nfy + 1)) ~= 0) and 
						   (pget(nfx, (nfy - 1)) ~= 0) and
						   ((pget((nfx + 1), nfy) ~= 0) or (pget((nfx - 1), nfy) ~= 0)) then
							a.vy = a.vy * -1
							--printh("reflect y axis")
						end
						
					else
						a.vx = a.vx * -1
						a.vy = a.vy * -1
					end
					break
				end
			end
		end
		
		for a in all(deleteballs) do
			deli(balls, a)
		end
		deleteballs = { }
		for a in all(deletebricks) do
			deli(bricks, a)
		end
		deletebricks = { }
		
		for a in all(balls) do
			-- normalize the velocity vector
			vv = sqrt(a.vx * a.vx + a.vy + a.vy)
			
			a.x += a.vx
			a.y += a.vy
		end
		
		-- move the paddle now
		paddle.x += paddle.vx
		paddle.y += paddle.vy
		paddle.vx = paddle.vx * .2
		paddle.vy = 0
	end
end

function _draw()
	-- clear screen
	cls(0)
	
	if game_state == 0 or game_state == 1 then
		print("level:"..level, 0, 0)
		print("score:"..score, 45, 0)
		print("lives:"..lives, 90, 0)
		
		spr(paddle.sprite, paddle.x, paddle.y, 2, 1)
		
		for a in all(balls) do
			spr(a.sprite, a.x, a.y)
		end  
		
		for a in all(bricks) do
			spr(a.sprite, a.x, a.y)
		end
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
