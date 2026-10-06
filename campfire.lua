Campfire = {}
Campfire.__index = Campfire

function Campfire.new(x, y)
    local self = {}
    setmetatable(self, Campfire)

    self.pos_x = x
    self.pos_y = y

    self.campfire_png = love.graphics.newImage('Sprites/campfire.png')
    self.currentFrame = 1
    self.campfire_animation = {}

    local width, height = self.campfire_png:getDimensions()
    local frameWidth = 32
    local frameHeight = 32

    for y = 0, height - frameHeight, frameHeight do
        for x = 0, width - frameWidth, frameWidth do
            table.insert(self.campfire_animation, love.graphics.newQuad(x, y, frameWidth, frameHeight, width, height))
        end
    end
    
    return self
end

function Campfire:update(dt)
    local anim_speed = 5
    self.currentFrame = self.currentFrame + anim_speed * dt

    if self.currentFrame > #self.campfire_animation then 
        self.currentFrame = 1 
    end
end

function Campfire:draw()
    local quad = self.campfire_animation[math.floor(self.currentFrame)]
    
    if quad then
        love.graphics.draw(self.campfire_png, quad, self.pos_x, self.pos_y, 0, 0.5, 0.5, 16, 16)
    end
end

return Campfire