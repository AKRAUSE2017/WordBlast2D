push = require('push')
Class = require('class')

require('player')
require('projectile')
require('letter')


WINDOW_WIDTH = 1024
WINDOW_HEIGHT = 576

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

PLAYER_SPEED = 200

PROJECTILE_WIDTH = 3
PROJECTILE_HEIGHT = 3

LETTER_WIDTH = 15
LETTER_HEIGHT = 15

local player = Player(10, 10)
local projectiles = {}
local letters = {}

local alphabet = {}
local timerSpawnRandLetter = 0
local nextSpawnRandLetter = 3

local coffeeOrders = {"ESPRESSO", "CAPPUCCINO", "LATTE", "AMERICANO", "MOCHA", "MACCHIATO", "RISTRETTO", "CORTADO", "AFFOGATO", "DECAF", "TURKISH", "IRISH", "FLATWHITE", "FRAPPE", "REDEYE", "BREVE", "PICCOLO", "CUBANO", "LUNGO", "MAZAGRAN"}
local timerSpawnCoffeeLetter = 0
local nextSpawnCoffeeLetter = 2

local bufferSpaceLetterLine = 10
local timerSpawnLetterLine = 0
local nextSpawnLetterLine = 20

local timerSpawnClearLetter = 0
local nextSpawnClearLetter = 5

local currentOrder = {}
local currentOrderString = ""

local bufferNextOrder = 0

local clearSymbol = "!"

math.randomseed(os.time())

function selectRandomOrder()
    currentOrder = {}
    currentOrderString = coffeeOrders[math.random(1,20)]
    for i = 1, #currentOrderString do
        local char = currentOrderString:sub(i, i) -- Extract the character at position 'i'
        table.insert(currentOrder, char)
    end
    orderLetter = 1
end

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest') -- no bluriness no interpolation on pixels when scaled
    love.window.setTitle("Word Blast")
    smallFont = love.graphics.newFont('assets/font.ttf', 15)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    for charCode = 65, 90 do -- ASCII codes for 'A' to 'Z'
        local letter = string.char(charCode)
        table.insert(alphabet, letter)
    end

    selectRandomOrder()
end

function love.resize(w,h)
    push:resize(w,h)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "space" then
        local initX = player.x + (player.width/2) - (PROJECTILE_WIDTH/2)
        local initY = player.y - 5
        table.insert(projectiles, Projectile(initX, initY, PROJECTILE_WIDTH, PROJECTILE_HEIGHT))
    end
end

function love.draw(dt)
    push:start()    
    displayWords()

    player:render()

    for _, projectile in pairs(projectiles) do -- iterate through each projectile
        projectile:render() -- render the projectile
    end

    for _, letter in pairs(letters) do -- iterate through each letter
        letter:render() -- render the projectile
    end

    push:finish()
end

function spawnRandomLetter(dt)
    timerSpawnRandLetter = timerSpawnRandLetter + dt
    if timerSpawnRandLetter > nextSpawnRandLetter then
        timerSpawnRandLetter = 0
        nextSpawnRandLetter = math.random(1,3)
        
        local initX = math.random(0, VIRTUAL_WIDTH - LETTER_WIDTH)
        local initY = math.random(-50, 0)
        local alphaValue = alphabet[math.random(1, 26)]
        table.insert(letters, Letter(alphaValue, initX, initY, LETTER_WIDTH, LETTER_HEIGHT))
    end
end

function spawnLetterToFulfillOrder(dt)
    timerSpawnCoffeeLetter = timerSpawnCoffeeLetter + dt
    if timerSpawnCoffeeLetter > nextSpawnCoffeeLetter then
        timerSpawnCoffeeLetter = 0
        nextSpawnCoffeeLetter = math.random(1,5)
        
        local initX = math.random(0, VIRTUAL_WIDTH - LETTER_WIDTH)
        local initY = math.random(-50, 0)

        if orderLetter <= #currentOrder then
            local coffeeLetter = currentOrder[orderLetter]
            table.insert(letters, Letter(coffeeLetter, initX, initY, LETTER_WIDTH, LETTER_HEIGHT))
        end
    end
end

function spawnLetterLine(dt)
    timerSpawnLetterLine = timerSpawnLetterLine + dt
    if timerSpawnLetterLine > nextSpawnLetterLine then
        timerSpawnLetterLine = 0
        nextSpawnLetterLine = math.random(20, 100)

        nextSpawnCoffeeLetter = math.random(10, 20)
        nextSpawnRandLetter = math.random(10, 20)
        nextSpawnClearLetter = math.random(10, 20)

        local numLetters = (VIRTUAL_WIDTH / (LETTER_WIDTH + bufferSpaceLetterLine)) + 5
        local randomIndex = math.random(1, numLetters)
        local currentInitX = 0
        for i = 1, numLetters do
            local alphaValue = ''
            
            currentInitX = currentInitX + (bufferSpaceLetterLine / 2)
            local initY = -50

            if i ~= randomIndex then
                alphaValue = alphabet[math.random(1, 26)]
            else
                alphaValue = currentOrder[orderLetter]
            end

            table.insert(letters, Letter(alphaValue, currentInitX, initY, LETTER_WIDTH, LETTER_HEIGHT, 35))
            currentInitX = currentInitX + LETTER_WIDTH
        end 
    end
end

function spawnClearLetter(dt)
    timerSpawnClearLetter = timerSpawnClearLetter + dt
    if timerSpawnClearLetter > nextSpawnClearLetter then
        timerSpawnClearLetter = 0
        nextSpawnClearLetter = math.random(1,5)

        local initX = math.random(0, VIRTUAL_WIDTH - LETTER_WIDTH)
        local initY = math.random(-50, 0)
        local clearValue = clearSymbol
        table.insert(letters, Letter(clearValue, initX, initY, LETTER_WIDTH, LETTER_HEIGHT))   
    end
end

function love.update(dt)
    if love.keyboard.isDown('d') or love.keyboard.isDown('right') then
        player.dx = PLAYER_SPEED
    elseif love.keyboard.isDown('a') or love.keyboard.isDown('left')  then
        player.dx = -PLAYER_SPEED
    else
        player.dx = 0
    end

    spawnRandomLetter(dt)
    spawnLetterToFulfillOrder(dt)
    spawnLetterLine(dt)
    spawnClearLetter(dt)

    -- Handle collisions
    for keyp, projectile in pairs(projectiles) do 
        for keyl, letter in pairs(letters) do 
            if projectile.x + projectile.width > letter.x and projectile.x < (letter.x + letter.width) and projectile.y < (letter.y + letter.height) then
                
                -- if the player grabbed the necessary order letter
                if currentOrder[orderLetter] == letter.value then
                    orderLetter = orderLetter + 1 -- move to next letter
                end

                print("current order letter is", currentOrder[orderLetter])
                if letter.value == clearSymbol then
                    letter_to_clear = player.currentWord:sub(#player.currentWord, #player.currentWord) -- will be empty when currentWord is empty
                    if orderLetter-1 > 0 then
                        if currentOrder[orderLetter-1] == letter_to_clear then -- currentOrder[orderLetter-1] returns nil when it does not exist
                            orderLetter = orderLetter - 1
                        end
                    end
                    player.currentWord = player.currentWord:sub(1, #player.currentWord-1)
                    print("current order letter is", currentOrder[orderLetter])
                else
                    player.currentWord = player.currentWord .. letter.value
                end
                table.remove(projectiles, keyp)
                table.remove(letters, keyl)
            end
        end
        ::continue::
    end

    if player.currentWord == currentOrderString or currentOrderString == " :D" then
        currentOrderString = " :D"
        player.currentWord = ""

        bufferNextOrder = bufferNextOrder + dt
        if bufferNextOrder > 3 then
            bufferNextOrder = 0
            selectRandomOrder()
        end
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

        if letter.y > VIRTUAL_HEIGHT then
            table.remove(letters, key) -- remove if it went off screen
        end
    end

    player:update(dt)
end

function displayWords()
    -- simple display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print(currentOrderString, 0, 5)
    love.graphics.print(player.currentWord, 0, 50) -- concat in lua is '..'
end