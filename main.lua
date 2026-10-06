local sti = require("Libraries/sti")
local Knight = require 'knight'
local Campfire = require 'campfire'
local Bunny = require 'bunny'
local Enemy = require 'enemy'
local Treasure = require 'treasure'
local GUI = require 'gui'
local ParticleSystem = require 'particles'
local Menu = require 'menu'
local AudioManager = require 'audio'

GAME_STATE = {
    MENU = 1,
    PLAYING = 2,
    INSTRUCTIONS = 3,
    GAME_OVER = 4,
    VICTORY = 5
}

function love.load()
    camera = require("Libraries/camera")
    cam = camera()

    gameState = GAME_STATE.MENU
    menu = Menu.new()
    instructionTime = 0
    audio = AudioManager.new()
    
    initGame()
end

function initGame()
    map = sti("Maps/castle.lua")
    
    collisionLayer = map.layers["walls"]
    
    x = 810
    y = 110

    knight = Knight.new(x, y)
    
    campfires = {}
    local campfireLayer = map.layers["Objects"]

    if campfireLayer and campfireLayer.objects then
        for _, obj in ipairs(campfireLayer.objects) do
            if obj.type == "Campfire" then
                local adjustedX = obj.x + 8
                local adjustedY = obj.y + 6
                table.insert(campfires, Campfire.new(adjustedX, adjustedY))
            end
        end
    end
    
    bunnies = {}
    local objLayer = map.layers["Objects"]

    if objLayer and objLayer.objects then
        for _, obj in ipairs(objLayer.objects) do
            if obj.type == "Bunny" then
                local adjustedX = obj.x + 8
                local adjustedY = obj.y + 3
                table.insert(bunnies, Bunny.new(adjustedX, adjustedY))
            end
        end
    end
    
    enemies = {}
    local enemySpawns = {
        {40, 600}, -- III
        {822, 550}, -- I
        {587, 202} -- II
    }
    for _, spawn in ipairs(enemySpawns) do
        table.insert(enemies, Enemy.new(spawn[1], spawn[2]))
    end
    
    treasures = {}
    local treasureSpawns = {{203, 24}, {455, 23}, {88, 616}}
    for _, spawn in ipairs(treasureSpawns) do
        table.insert(treasures, Treasure.new(spawn[1], spawn[2]))
    end
    
    gui = GUI.new()
    particles = ParticleSystem.new()
    
    cam:zoom(2.5)
end

function isSolidTile(layer, x, y)
    if not layer or not layer.data then return false end

    local tileX = math.floor(x / map.tilewidth) + 1
    local tileY = math.floor(y / map.tileheight) + 1

    if tileX < 1 or tileX > layer.width or tileY < 1 or tileY > layer.height then
        return false
    end

    return layer.data[tileY] and layer.data[tileY][tileX] and layer.data[tileY][tileX].gid ~= 0
end

function love.update(dt)
    if gameState == GAME_STATE.MENU then
        menu:update(dt)
    elseif gameState == GAME_STATE.INSTRUCTIONS then
        instructionTime = instructionTime + dt
        if instructionTime > 15 then
            gameState = GAME_STATE.MENU
        end
    elseif gameState == GAME_STATE.PLAYING then
        knight:update(dt, map, collisionLayer)

        for _, campfire in ipairs(campfires) do
            campfire:update(dt)
        end

        for _, bunny in ipairs(bunnies) do
            bunny:update(dt, collisionLayer, map)
        end
        
        for _, enemy in ipairs(enemies) do
            enemy:update(dt, knight, collisionLayer, map)
            
            if not knight:isInvulnerable() and enemy:isCollidingWith(knight.pos_x, knight.pos_y, 7) then
                gui:takeDamage(15)
                knight:takeDamage()
                particles:emitBlood(knight.pos_x, knight.pos_y, 8)
                audio:playDamageSound()
            end
        end
        
        for _, treasure in ipairs(treasures) do
            treasure:update(dt)
            
            if treasure:isCollidingWith(knight.pos_x, knight.pos_y, 7) then
                treasure:collect()
                gui:addTreasure()
                particles:emitSparks(treasure.pos_x, treasure.pos_y, 12)
                audio:playCollectSound()
            end
        end
        
        gui:update(dt)
        particles:update(dt)
        
        if gui:hasWon() then
            gameState = GAME_STATE.VICTORY
            audio:playVictorySound()
        end
        
        -- losing condition
        if gui.health <= 0 then
            gameState = GAME_STATE.GAME_OVER
        end

        cam:lookAt(knight.pos_x, knight.pos_y)
    elseif gameState == GAME_STATE.VICTORY or gameState == GAME_STATE.GAME_OVER then
        if love.keyboard.isDown('return') then
            gameState = GAME_STATE.MENU
            initGame()
        end
    end
end

function love.draw()
    local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
    
    if gameState == GAME_STATE.MENU then
        menu:draw(windowWidth, windowHeight)
    elseif gameState == GAME_STATE.INSTRUCTIONS then
        love.graphics.setColor(0.1, 0.1, 0.15)
        love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)
        
        love.graphics.setColor(1, 0.84, 0)
        love.graphics.setFont(love.graphics.newFont(36))
        love.graphics.printf("HOW TO PLAY", 0, 30, windowWidth, "center")
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(16))
        local instructions = {
            "CONTROLS:",
            "WASD to move",
            "",
            "OBJECTIVE:",
            "Collect three gold treasures (rotating boxes)",
            "",
            "DANGER:",
            "Red enemies patrol and chase you when spotted",
            "You can't fight them - only avoid and outrun",
            "Each hit = -15 HP. Reach 0 HP = Game Over",
            "",
            "WIN:",
            "Collect all three treasures with HP > 0",
            "",
            "TIPS:",
            "- Enemies can't reach you in the castle passages",
            "- Bunnies have no purpose but are cute",
            "",
            "Press ENTER to go back to menu"
        }
        
        local y = 90
        for _, line in ipairs(instructions) do
            love.graphics.printf(line, 50, y, windowWidth - 100, "left")
            y = y + 28
        end
    elseif gameState == GAME_STATE.PLAYING then
        cam:attach()
            map:drawLayer(map.layers["grass"])
            map:drawLayer(map.layers["floor"])
            map:drawLayer(map.layers["carpet"])
            
            for _, bunny in ipairs(bunnies) do
                bunny:draw()
            end
            for _, campfire in ipairs(campfires) do
                campfire:draw()
            end
            for _, treasure in ipairs(treasures) do
                treasure:draw()
            end
            for _, enemy in ipairs(enemies) do
                enemy:draw()
            end
            
            map:drawLayer(map.layers["walls"])
            map:drawLayer(map.layers["decor"])
            
            knight:draw()
            
            particles:draw()
        cam:detach()
        
        gui:draw(windowWidth, windowHeight)
    elseif gameState == GAME_STATE.VICTORY then
        love.graphics.setColor(0.1, 0.1, 0.15)
        love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)
        
        love.graphics.setColor(1, 0.84, 0)
        love.graphics.setFont(love.graphics.newFont(56))
        love.graphics.printf("VICTORY!", 0, windowHeight / 2 - 100, windowWidth, "center")
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(24))
        love.graphics.printf("You collected all treasures!", 0, windowHeight / 2 - 20, windowWidth, "center")
        love.graphics.printf("Time: " .. string.format("%02d:%02d", 
            math.floor(gui.gameTime / 60), math.floor(gui.gameTime % 60)), 
            0, windowHeight / 2 + 20, windowWidth, "center")
        
        love.graphics.setFont(love.graphics.newFont(18))
        love.graphics.printf("Press ENTER to return to menu", 0, windowHeight / 2 + 100, windowWidth, "center")
    elseif gameState == GAME_STATE.GAME_OVER then
        love.graphics.setColor(0.1, 0.1, 0.15)
        love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)
        
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.setFont(love.graphics.newFont(56))
        love.graphics.printf("GAME OVER", 0, windowHeight / 2 - 100, windowWidth, "center")
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(24))
        love.graphics.printf("You were defeated!", 0, windowHeight / 2 - 20, windowWidth, "center")
        love.graphics.printf("Treasures collected: " .. gui.treasureCollected .. "/" .. gui.treasureGoal, 
            0, windowHeight / 2 + 20, windowWidth, "center")
        
        love.graphics.setFont(love.graphics.newFont(18))
        love.graphics.printf("Press ENTER to return to menu", 0, windowHeight / 2 + 100, windowWidth, "center")
    end
end

function love.keypressed(key)
    if gameState == GAME_STATE.MENU then
        if key == "up" then
            menu.selectedOption = menu.selectedOption - 1
            if menu.selectedOption < 1 then
                menu.selectedOption = #menu.options
            end
        elseif key == "down" then
            menu.selectedOption = menu.selectedOption + 1
            if menu.selectedOption > #menu.options then
                menu.selectedOption = 1
            end
        elseif key == "return" then
            local selection = menu:getSelection()
            if selection == "Start Game" then
                gameState = GAME_STATE.PLAYING
            elseif selection == "Instructions" then
                gameState = GAME_STATE.INSTRUCTIONS
                instructionTime = 0
            elseif selection == "Quit" then
                love.event.quit()
            end
            audio:playMenuSelect()
        end
    elseif gameState == GAME_STATE.INSTRUCTIONS then
        if key == "return" then
            gameState = GAME_STATE.MENU
        end
    elseif gameState == GAME_STATE.VICTORY or gameState == GAME_STATE.GAME_OVER then
        if key == "return" then
            gameState = GAME_STATE.MENU
            initGame()
        end
    end
end