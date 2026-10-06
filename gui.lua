GUI = {}
GUI.__index = GUI

function GUI.new()
    local self = {}
    setmetatable(self, GUI)

    self.treasureCollected = 0
    self.health = 100
    self.gameTime = 0
    self.treasureGoal = 3

    return self
end

function GUI:update(dt)
    self.gameTime = self.gameTime + dt
end

function GUI:draw(windowWidth, windowHeight)
    love.graphics.setColor(1, 1, 1)
    local fontSize = 16
    love.graphics.setFont(love.graphics.newFont(fontSize))
    
    -- health bar background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 10, 10, 204, 24)
    
    -- health bar
    local healthPercent = math.max(0, self.health / 100)
    local healthColor = {1 - healthPercent, healthPercent, 0}
    love.graphics.setColor(healthColor)
    love.graphics.rectangle("fill", 12, 12, 200 * healthPercent, 20)
    
    -- health text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("HP: " .. math.floor(self.health), 15, 15)
    
    -- treasure counter
    love.graphics.setColor(1, 0.84, 0)
    love.graphics.print("Treasures: " .. self.treasureCollected .. "/" .. self.treasureGoal, 10, 50)
    
    -- timer
    love.graphics.setColor(1, 1, 1)
    local minutes = math.floor(self.gameTime / 60)
    local seconds = math.floor(self.gameTime % 60)
    love.graphics.print(string.format("Time: %02d:%02d", minutes, seconds), windowWidth - 150, 10)
end

function GUI:addTreasure()
    self.treasureCollected = self.treasureCollected + 1
end

function GUI:takeDamage(amount)
    self.health = math.max(0, self.health - amount)
end

function GUI:heal(amount)
    self.health = math.min(100, self.health + amount)
end

function GUI:hasWon()
    return self.treasureCollected >= self.treasureGoal
end

return GUI
