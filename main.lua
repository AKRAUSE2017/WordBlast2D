push = require('push')
Class = require('class')

require('player')
require('projectile')
require('letter')
require('customer')
require('order')
require('timer')
require('aimline')
require('fish')
require('rain')
require('coversprite')
require('steam')
require('utils')
require('spawnutils')
require('orderutils')
require('drawutils')

WINDOW_WIDTH = 1024
WINDOW_HEIGHT = 576

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

PLAYER_SPEED = 200

PROJECTILE_WIDTH = 3
PROJECTILE_HEIGHT = 3

LETTER_WIDTH = 15
LETTER_HEIGHT = 15

CLEAR_SYMBOL = "!"

LETTER_INIT_Y = -30

alphabet = {}
coffeeOrders = {"ESPRESSO", "CAPPUCCINO", "LATTE", "AMERICANO", "MOCHA", "MACCHIATO", "RISTRETTO", "CORTADO", "AFFOGATO", "DECAF", "TURKISH", "IRISH", "FLATWHITE", "FRAPPE", "REDEYE", "BREVE", "PICCOLO", "CUBANO", "LUNGO", "MAZAGRAN"}

local player = Player(10, 10)

local projectiles = {}
local letters = {}
local aimLines = {}
local coverSprites = {}

math.randomseed(os.time())

function love.resize(w,h)
    push:resize(w,h)
end

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest') -- no bluriness no interpolation on pixels when scaled
    love.window.setTitle("Word Blast")

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })
    
    game_state = "start"

    -- MUSIC SETUP
    background_music = love.audio.newSource("assets/sounds/WordBlast2D_V1.mp3", "stream")
    background_music:setVolume(0.15) 
    background_music:setPitch(1.05)
    
    -- GENERAL VISUALS
    smallFont = love.graphics.newFont('assets/fonts/font.ttf', 15)
    background = love.graphics.newImage("assets/background.png")

    -- COVER SPRITES
    table.insert(coverSprites, CoverSprite(0, 0, "assets/covers/light.png"))
    table.insert(coverSprites, CoverSprite(0, VIRTUAL_HEIGHT-114, "assets/covers/plant.png"))
    table.insert(coverSprites, CoverSprite(7, VIRTUAL_HEIGHT-114-9, "assets/covers/plant_leaf.png"))
    table.insert(coverSprites, CoverSprite(0, VIRTUAL_HEIGHT-164, "assets/covers/window_bar.png"))
    table.insert(coverSprites, CoverSprite(167, VIRTUAL_HEIGHT-121, "assets/covers/cup.png"))
    
    -- OBJECTS
    fish_blue = Fish(VIRTUAL_WIDTH-50, 105, "assets/animate/fish_blue.png", 7, 1)
    fish_red = Fish(VIRTUAL_WIDTH-20, 109, "assets/animate/fish_red.png", -7, -1)
    rain = Rain(0, -55, "assets/animate/rain.png")
    steam = Steam(173, 160, {"assets/animate/steam_1.png", "assets/animate/steam_2.png", "assets/animate/steam_3.png"})

    -- ALPHABET TABLE
    for charCode = 65, 90 do -- ASCII codes for 'A' to 'Z'
        local letter = string.char(charCode)
        table.insert(alphabet, letter)
    end

    -- GAMEPLAY SETUP
    customer, currentOrder = OrderUtils:selectRandomOrder()
    SpawnUtils:initLetterTimers()
    OrderUtils:initOrderBufferTimer()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "k" then
        currentOrder.trackFulfillment = currentOrder.orderString
    elseif key == "1" then
        player.state = "LR_move"
    elseif key == "2" then
        player.state = "static_aim"
        player:setupAimMode()
    end
    
    if key == "space" then
        projectiles = player:shoot(projectiles) -- returns updated projectiles table to include new objects
    end
end

function love.draw()
    push:start()   

    love.graphics.setFont(smallFont)
    love.graphics.draw(background, 0, 0, 0, 1, 1)

    if game_state == "start" then
        DrawUtils:renderMenu()
    end    

    if game_state == "play" then    
        -- RENDER BEHIND COVER SPRITES
        steam:render()
        rain:render()

        -- COVER SPRITES
        for _, coverSprite in pairs(coverSprites) do
            coverSprite:render()
        end

        for key, projectile in pairs(projectiles) do -- iterate through each projectile
            projectile:render() -- update the position
        end

        for key, letter in pairs(letters) do -- iterate through each letter
            letter:render() -- update the position
        end

        if player.state == "static_aim" then
            player.aimMarker:render()
            player:renderAimLines()
        end

        DrawUtils:renderOrderStatus(currentOrder)

        -- RENDER IN FRONT OF COVER SPRITES
        player:render()
        customer:render()
        fish_blue:render()
        fish_red:render()

        -- love.graphics.rectangle("fill", 0, VIRTUAL_HEIGHT - 20, 600, 2) -- TESTING
    end
    
    push:finish()
end


function love.mousereleased(x, y, button)
    if button == 1 and game_state == "start" then
        game_state = "play"
    end
 end

function love.update(dt)
    -- if not background_music:isPlaying() then
	-- 	love.audio.play(background_music)
	-- end

    if game_state == "play" then
        -- ANIMATION UPDATES
        rain:update(dt)
        fish_blue:update(dt)
        fish_red:update(dt)
        steam:update(dt)
        customer:update(dt)
        
        -- PLAYER UPDATE
        player:update(dt)

        -- UPDATE LETTERS TABLE
        letters = SpawnUtils:spawnRandomLetter(letters, dt)
        letters = SpawnUtils:spawnLetterToFulfillOrder(letters, dt)
        letters = SpawnUtils:spawnClearLetter(letters, dt)

        -- UPDATE CURRENT ORDER
        for _, floatLetter in pairs(currentOrder.orderChars) do
            floatLetter:update(dt)
        end
        currentOrder:checkAndUpdateSpeedTimer(dt)

        -- Handle collisions
        for keyp, projectile in pairs(projectiles) do 
            for keyl, letter in pairs(letters) do 
                if Utils:collision(projectile, letter) then
                    love.audio.play(letter.collect_sound)
                    currentOrder, projectiles, letters = OrderUtils:handleOrderCollisionUpdate(currentOrder, letter, projectiles, letters, keyp, keyl)
                end
            end
        end

        -- Handle order completion and next order
        if currentOrder.trackFulfillment == currentOrder.orderString or customer.spriteStatus == "happy" then
            customer, currentOrder = OrderUtils:handleOrderComplete(customer, currentOrder, dt)
        end

        -- Update projectiles
        for key, projectile in pairs(projectiles) do
            projectile:update(dt) -- update position

            if projectile.y < 0 - projectile.height then
                table.remove(projectiles, key) -- remove if it went off screen
            end
        end

        -- Update falling letters
        for key, letter in pairs(letters) do
            letter:update(dt) -- update position
            currentOrder:checkAndStartSpeedTimer(customer, letter)
            -- currentOrder = OrderUtils:debugMockCollectLetter(letter, currentOrder)

            if letter.y > VIRTUAL_HEIGHT then
                table.remove(letters, key) -- remove if it went off screen
            end
        end
    end
end