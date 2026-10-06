Knight = {}
Knight.__index = Knight

function Knight.new(x, y)
    local self = {}
    setmetatable(self, Knight)

    self.pos_x = x
    self.pos_y = y
    
    -- made it smaller so that the knight fits into narrow places easily
    self.width = 14
    self.height = 14

    self.knight_png = love.graphics.newImage('Sprites/Knight_Run.png')
    self.currentFrame = 1
    self.knight_animation = {}
    
    self.isMoving = false
    self.direction = 1 -- facing direction, 1 for right, -1 for left

    -- Invulnerability frames after taking damage
    self.invulnerableTime = 0
    self.invulnerableDuration = 1.5

    local width, height = self.knight_png:getDimensions()

    for y = 0, height - 84, 84 do
        for x = 0, width - 96, 96 do
            table.insert(self.knight_animation, love.graphics.newQuad(x, y, 96, 84, width, height))
        end
    end
    
    return self
end

function Knight:update(dt, map, collisionLayer)
    -- Update invulnerability timer
    if self.invulnerableTime > 0 then
        self.invulnerableTime = self.invulnerableTime - dt
    end

    local move_h = 0
    local move_v = 0

    if love.keyboard.isDown('w') then move_v = -1 end
    if love.keyboard.isDown('s') then move_v = 1 end
    if love.keyboard.isDown('a') then move_h = -1 end
    if love.keyboard.isDown('d') then move_h = 1 end

    -- update direction based on horizontal movement
    if move_h < 0 then
        self.direction = -1
    elseif move_h > 0 then
        self.direction = 1
    end
    
    self.isMoving = (move_v ~= 0 or move_h ~= 0)

    local dir = math.atan2(move_v, move_h)
    local move_speed = 100

    if self.isMoving then
        local new_x = self.pos_x + math.cos(dir) * move_speed * dt
        local new_y = self.pos_y + math.sin(dir) * move_speed * dt
        
        local halfW = self.width / 2
        local halfH = self.height / 2
        
        local canMoveX = not (
            -- corners
            isSolidTile(collisionLayer, new_x - halfW, self.pos_y - halfH) or
            isSolidTile(collisionLayer, new_x + halfW, self.pos_y - halfH) or
            isSolidTile(collisionLayer, new_x - halfW, self.pos_y + halfH) or
            isSolidTile(collisionLayer, new_x + halfW, self.pos_y + halfH) or

            -- midpoints on left and right edges
            isSolidTile(collisionLayer, new_x - halfW, self.pos_y) or
            isSolidTile(collisionLayer, new_x + halfW, self.pos_y)
        )
        
        local canMoveY = not (
            -- corners
            isSolidTile(collisionLayer, self.pos_x - halfW, new_y - halfH) or
            isSolidTile(collisionLayer, self.pos_x + halfW, new_y - halfH) or
            isSolidTile(collisionLayer, self.pos_x - halfW, new_y + halfH) or
            isSolidTile(collisionLayer, self.pos_x + halfW, new_y + halfH) or

            -- midpoints on top and bottom edges
            isSolidTile(collisionLayer, self.pos_x, new_y - halfH) or
            isSolidTile(collisionLayer, self.pos_x, new_y + halfH)
        )
        
        if canMoveX then
            self.pos_x = new_x
        end
        if canMoveY then
            self.pos_y = new_y
        end
        
        local anim_speed = 10
        self.currentFrame = self.currentFrame + anim_speed * dt

        if self.currentFrame > #self.knight_animation then 
            self.currentFrame = 1 
        end
    else
        self.currentFrame = 2
    end
end

function Knight:isInvulnerable()
    return self.invulnerableTime > 0
end

function Knight:takeDamage()
    self.invulnerableTime = self.invulnerableDuration
end

function Knight:draw()
    -- Flash when invulnerable
    if self.invulnerableTime > 0 then
        -- Flash effect: transparent when invulnerable
        local alpha = (math.sin(love.timer.getTime() * 8) + 1) / 2
        love.graphics.setColor(1, 1, 1, alpha * 0.7 + 0.3)
    else
        love.graphics.setColor(1, 1, 1)
    end

    local quad = self.knight_animation[math.floor(self.currentFrame)]
    if quad then
        love.graphics.draw(
            self.knight_png, 
            quad, 
            self.pos_x, 
            self.pos_y, 
            0, 
            0.5 * self.direction, -- flip horizontally based on facing direction
            0.5, 
            96/2, 
            84/2
        )
    end
end

return Knight