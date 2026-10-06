Treasure = {}
Treasure.__index = Treasure

function Treasure.new(x, y)
    local self = {}
    setmetatable(self, Treasure)

    self.pos_x = x
    self.pos_y = y
    self.radius = 8
    self.collected = false
    
    self.rotation = 0
    self.bobOffset = 0
    self.bobSpeed = 3
    self.rotateSpeed = 2

    return self
end

function Treasure:update(dt)
    if not self.collected then
        self.rotation = self.rotation + self.rotateSpeed * dt
        self.bobOffset = math.sin(love.timer.getTime() * self.bobSpeed) * 5
    end
end

function Treasure:draw()
    if not self.collected then
        love.graphics.setColor(1, 0.84, 0) -- gold color
        
        love.graphics.push()
        love.graphics.translate(self.pos_x, self.pos_y + self.bobOffset)
        love.graphics.rotate(self.rotation)
        
        love.graphics.rectangle("fill", -8, -6, 16, 12)
        
        love.graphics.setColor(0.8, 0.65, 0)
        love.graphics.rectangle("fill", -8, -8, 16, 3)
        
        love.graphics.pop()
        
        -- sparkle
        love.graphics.setColor(1, 1, 0.5, 0.8)
        local sparkleOffset = (love.timer.getTime() * 4) % (math.pi * 2)
        love.graphics.circle("fill", self.pos_x + math.cos(sparkleOffset) * 12, 
                             self.pos_y + self.bobOffset + math.sin(sparkleOffset) * 12, 3)
        
        love.graphics.setColor(1, 1, 1)
    end
end

function Treasure:isCollidingWith(x, y, radius)
    local dx = self.pos_x - x
    local dy = self.pos_y - y
    local dist = math.sqrt(dx * dx + dy * dy)
    return not self.collected and dist < (self.radius + radius)
end

function Treasure:collect()
    self.collected = true
end

return Treasure
