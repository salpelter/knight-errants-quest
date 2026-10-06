Particle = {}
Particle.__index = Particle

function Particle.new(x, y, vx, vy, lifetime, color, size)
    local self = {}
    setmetatable(self, Particle)
    
    self.x = x
    self.y = y
    self.vx = vx or 0
    self.vy = vy or 0
    self.lifetime = lifetime or 1
    self.age = 0
    self.color = color or {1, 1, 1}
    self.size = size or 5
    self.alpha = 1
    
    return self
end

function Particle:update(dt)
    self.age = self.age + dt
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    self.alpha = math.max(0, 1 - (self.age / self.lifetime))
end

function Particle:draw()
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.alpha)
    love.graphics.circle("fill", self.x, self.y, self.size * self.alpha)
end

function Particle:isAlive()
    return self.age < self.lifetime
end

ParticleSystem = {}
ParticleSystem.__index = ParticleSystem

function ParticleSystem.new()
    local self = {}
    setmetatable(self, ParticleSystem)
    
    self.particles = {}
    
    return self
end

function ParticleSystem:emit(x, y, count, vx, vy, lifetime, color, size)
    for i = 1, count do
        local angle = (i / count) * math.pi * 2
        local speed = 100
        local particleVx = (vx or 0) + math.cos(angle) * speed
        local particleVy = (vy or 0) + math.sin(angle) * speed
        
        table.insert(self.particles, Particle.new(x, y, particleVx, particleVy, lifetime, color, size))
    end
end

function ParticleSystem:emitSparks(x, y, count)
    self:emit(x, y, count, 0, 0, 0.5, {1, 0.8, 0}, 4)
end

function ParticleSystem:emitSmoke(x, y, count)
    self:emit(x, y, count, 0, 0, 1, {0.7, 0.7, 0.7}, 8)
end

function ParticleSystem:emitBlood(x, y, count)
    self:emit(x, y, count, 0, 0, 0.8, {1, 0, 0}, 5)
end

function ParticleSystem:update(dt)
    for i = #self.particles, 1, -1 do
        self.particles[i]:update(dt)
        if not self.particles[i]:isAlive() then
            table.remove(self.particles, i)
        end
    end
end

function ParticleSystem:draw()
    for _, particle in ipairs(self.particles) do
        particle:draw()
    end
    love.graphics.setColor(1, 1, 1)
end

return ParticleSystem
