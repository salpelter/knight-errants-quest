local AISTATE = require("AISTATE")

Bunny = {}
Bunny.__index = Bunny

function Bunny.new(x, y)
    local self = {}
    setmetatable(self, Bunny)

    self.pos_x = x
    self.pos_y = y
    self.width = 20
    self.height = 20

    self.bunny_png = love.graphics.newImage('Sprites/Bunny.png')
    self.currentFrame = 1
    self.bunny_animation = {}

    local width, height = self.bunny_png:getDimensions()
    local frameWidth = 32
    local frameHeight = 32

    for x = 0, width - frameWidth, frameWidth do
        table.insert(self.bunny_animation, love.graphics.newQuad(x, 0, frameWidth, frameHeight, width, height))
    end

    self.state = AISTATE.IDLE
    self.stateTimer = 2
    self.currTimer = 0
    self.direction = 0
    self.speed = 40

    return self
end

function Bunny:update(dt, collisionLayer, map)
    self.currTimer = self.currTimer - dt

    if self.state == AISTATE.IDLE then
        if self.currTimer < 0 then
            self.state = AISTATE.WANDER
            self.currTimer = self.stateTimer
            self.direction = math.random() * math.pi * 2
        end
    elseif self.state == AISTATE.WANDER then
        -- move in random direction
        local new_x = self.pos_x + math.cos(self.direction) * self.speed * dt
        local new_y = self.pos_y + math.sin(self.direction) * self.speed * dt
        
        -- simple collision check
        if collisionLayer and map then
            local halfW = self.width / 2
            local halfH = self.height / 2
            
            local canMove = not (
                isSolidTile(collisionLayer, new_x - halfW, new_y - halfH) or
                isSolidTile(collisionLayer, new_x + halfW, new_y - halfH) or
                isSolidTile(collisionLayer, new_x - halfW, new_y + halfH) or
                isSolidTile(collisionLayer, new_x + halfW, new_y + halfH)
            )
            
            if canMove then
                self.pos_x = new_x
                self.pos_y = new_y
            else
                -- hit wall, go back to idle
                self.state = AISTATE.IDLE
                self.currTimer = self.stateTimer
            end
        else
            self.pos_x = new_x
            self.pos_y = new_y
        end

        if self.currTimer < 0 then
            self.state = AISTATE.IDLE
            self.currTimer = self.stateTimer
        end
    end

    local anim_speed = 6
    self.currentFrame = self.currentFrame + anim_speed * dt

    if self.currentFrame > #self.bunny_animation then
        self.currentFrame = 1
    end
end

function Bunny:draw()
    local quad = self.bunny_animation[math.floor(self.currentFrame)]

    if quad then
        love.graphics.draw(self.bunny_png, quad, self.pos_x, self.pos_y, 0, 0.5, 0.5, 16, 16)
    end
end

return Bunny