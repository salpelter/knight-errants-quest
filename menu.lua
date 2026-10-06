Menu = {}
Menu.__index = Menu

function Menu.new()
    local self = {}
    setmetatable(self, Menu)

    self.selectedOption = 1
    self.options = {"Start Game", "Instructions", "Quit"}
    self.buttonHeight = 60
    self.buttonWidth = 200
    
    return self
end

function Menu:update(dt)
    -- menu doesn't need to update anything for now
end

function Menu:draw(windowWidth, windowHeight)
    -- background
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)
    
    -- title
    love.graphics.setColor(1, 0.84, 0)
    love.graphics.setFont(love.graphics.newFont(48))
    love.graphics.printf("KNIGHT-ERRANT'S QUEST", 0, 50, windowWidth, "center")
    
    -- buttons
    love.graphics.setFont(love.graphics.newFont(32))
    local startY = windowHeight / 2 - (#self.options * self.buttonHeight) / 2
    
    for i, option in ipairs(self.options) do
        local y = startY + (i - 1) * self.buttonHeight
        
        if i == self.selectedOption then
            love.graphics.setColor(1, 0.84, 0)
            love.graphics.rectangle("fill", 
                windowWidth / 2 - self.buttonWidth / 2, y,
                self.buttonWidth, self.buttonHeight - 10)
            love.graphics.setColor(0.1, 0.1, 0.15)
        else
            love.graphics.setColor(0.3, 0.3, 0.4)
            love.graphics.rectangle("line", 
                windowWidth / 2 - self.buttonWidth / 2, y,
                self.buttonWidth, self.buttonHeight - 10)
            love.graphics.setColor(1, 1, 1)
        end
        
        love.graphics.printf(option, 
            windowWidth / 2 - self.buttonWidth / 2, y + 10,
            self.buttonWidth, "center")
    end
    
    -- menu quick instructions at the bottom
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("UP/DOWN to select  |  ENTER to confirm", 
        0, windowHeight - 40, windowWidth, "center")
end

function Menu:getSelection()
    return self.options[self.selectedOption]
end

return Menu
