local AISTATE = require("AISTATE")

Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y)
    local self = {}
    setmetatable(self, Enemy)

    self.pos_x = x
    self.pos_y = y
    self.width = 18
    self.height = 18
    
    self.color = {1, 0.2, 0.2} -- red
    self.radius = 9

    self.state = AISTATE.PATROL
    self.stateTimer = 3
    self.currTimer = 0
    self.direction = math.random() * math.pi * 2
    self.speed = 60
    self.visionRange = 150
    
    self.targetX = nil
    self.targetY = nil
    
    return self
end

function Enemy:update(dt, knight, collisionLayer, map)
    self.currTimer = self.currTimer - dt
    
    -- distance to knight
    local dx = knight.pos_x - self.pos_x
    local dy = knight.pos_y - self.pos_y
    local distToKnight = math.sqrt(dx * dx + dy * dy)
    
    -- AI
    if distToKnight < self.visionRange then
        -- in vision range - chase
        self.state = AISTATE.CHASE
        self.targetX = knight.pos_x
        self.targetY = knight.pos_y
        self.currTimer = 10
        
        -- move toward knight
        local dirToKnight = math.atan2(dy, dx)
        local new_x = self.pos_x + math.cos(dirToKnight) * self.speed * dt
        local new_y = self.pos_y + math.sin(dirToKnight) * self.speed * dt
        
        if collisionLayer and map then
            local halfW = self.width / 2
            local halfH = self.height / 2
            
            local canMoveX = not (
                isSolidTile(collisionLayer, new_x - halfW, self.pos_y - halfH) or
                isSolidTile(collisionLayer, new_x + halfW, self.pos_y - halfH) or
                isSolidTile(collisionLayer, new_x - halfW, self.pos_y + halfH) or
                isSolidTile(collisionLayer, new_x + halfW, self.pos_y + halfH)
            )
            
            local canMoveY = not (
                isSolidTile(collisionLayer, self.pos_x - halfW, new_y - halfH) or
                isSolidTile(collisionLayer, self.pos_x + halfW, new_y - halfH) or
                isSolidTile(collisionLayer, self.pos_x - halfW, new_y + halfH) or
                isSolidTile(collisionLayer, self.pos_x + halfW, new_y + halfH)
            )
            
            if canMoveX then self.pos_x = new_x end
            if canMoveY then self.pos_y = new_y end
        else
            self.pos_x = new_x
            self.pos_y = new_y
        end
        
    elseif self.state == AISTATE.CHASE and self.currTimer > 0 then
        -- still chasing but knight left vision
        if self.targetX and self.targetY then
            local dx2 = self.targetX - self.pos_x
            local dy2 = self.targetY - self.pos_y
            local dirToTarget = math.atan2(dy2, dx2)
            
            local new_x = self.pos_x + math.cos(dirToTarget) * self.speed * dt
            local new_y = self.pos_y + math.sin(dirToTarget) * self.speed * dt
            
            if collisionLayer and map then
                local halfW = self.width / 2
                local halfH = self.height / 2
                
                local canMoveX = not (
                    isSolidTile(collisionLayer, new_x - halfW, self.pos_y - halfH) or
                    isSolidTile(collisionLayer, new_x + halfW, self.pos_y - halfH) or
                    isSolidTile(collisionLayer, new_x - halfW, self.pos_y + halfH) or
                    isSolidTile(collisionLayer, new_x + halfW, self.pos_y + halfH)
                )
                
                local canMoveY = not (
                    isSolidTile(collisionLayer, self.pos_x - halfW, new_y - halfH) or
                    isSolidTile(collisionLayer, self.pos_x + halfW, new_y - halfH) or
                    isSolidTile(collisionLayer, self.pos_x - halfW, new_y + halfH) or
                    isSolidTile(collisionLayer, self.pos_x + halfW, new_y + halfH)
                )
                
                if canMoveX then self.pos_x = new_x end
                if canMoveY then self.pos_y = new_y end
            else
                self.pos_x = new_x
                self.pos_y = new_y
            end
        end
    else
        self.state = AISTATE.PATROL
        
        if self.currTimer < 0 then
            self.direction = math.random() * math.pi * 2
            self.currTimer = 2
        end
        
        local new_x = self.pos_x + math.cos(self.direction) * (self.speed * 0.5) * dt
        local new_y = self.pos_y + math.sin(self.direction) * (self.speed * 0.5) * dt
        
        if collisionLayer and map then
            local halfW = self.width / 2
            local halfH = self.height / 2
            
            local canMoveX = not (
                isSolidTile(collisionLayer, new_x - halfW, self.pos_y - halfH) or
                isSolidTile(collisionLayer, new_x + halfW, self.pos_y - halfH) or
                isSolidTile(collisionLayer, new_x - halfW, self.pos_y + halfH) or
                isSolidTile(collisionLayer, new_x + halfW, self.pos_y + halfH)
            )
            
            local canMoveY = not (
                isSolidTile(collisionLayer, self.pos_x - halfW, new_y - halfH) or
                isSolidTile(collisionLayer, self.pos_x + halfW, new_y - halfH) or
                isSolidTile(collisionLayer, self.pos_x - halfW, new_y + halfH) or
                isSolidTile(collisionLayer, self.pos_x + halfW, new_y + halfH)
            )
            
            if canMoveX then self.pos_x = new_x end
            if canMoveY then self.pos_y = new_y end
        else
            self.pos_x = new_x
            self.pos_y = new_y
        end
    end
end

function Enemy:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.pos_x, self.pos_y, self.radius)
    
    -- draw vision range when chasing
    if self.state == AISTATE.CHASE then
        love.graphics.setColor(1, 0.2, 0.2, 0.1)
        love.graphics.circle("line", self.pos_x, self.pos_y, self.visionRange)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function Enemy:isCollidingWith(x, y, radius)
    local dx = self.pos_x - x
    local dy = self.pos_y - y
    local dist = math.sqrt(dx * dx + dy * dy)
    return dist < (self.radius + radius)
end

return Enemy
