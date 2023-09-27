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

local wordBank = {}
local player = Player(10, 10)
local projectiles = {}
local letters = {}

local alphabet = {}
local timeSpawnRand = 0
local nextRandSpawn = 3


local coffeeOrders = {"ESPRESSO", "CAPPUCCINO", "LATTE", "AMERICANO", "MOCHA", "MACCHIATO", "RISTRETTO", "CORTADO", "AFFOGATO", "DECAF", "TURKISH", "IRISH", "FLATWHITE", "FRAPPE", "REDEYE", "BREVE", "PICCOLO", "CUBANO", "LUNGO", "MAZAGRAN"}
local timeSpawnCoffee = 0
local nextCoffeeSpawn = 2

local currentOrder = {}
local currentOrderString = ""

local bufferNextOrder = 0

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

function love.draw()
    push:start()    
    displayWords()

    player:render()

    for key, projectile in pairs(projectiles) do -- iterate through each projectile
        projectile:render(dt) -- update the position
    end

    for key, letter in pairs(letters) do -- iterate through each letter
        letter:render(dt) -- update the position
    end

    push:finish()
end

function spawnRandomLetter(dt)
    timeSpawnRand = timeSpawnRand + dt
    if timeSpawnRand > nextRandSpawn then
        timeSpawnRand = 0
        nextRandSpawn = math.random(1,3)
        
        local initX = math.random(0, VIRTUAL_WIDTH - LETTER_WIDTH)
        local initY = math.random(-50, 0)
        local alphaValue = alphabet[math.random(1, 26)]
        table.insert(letters, Letter(alphaValue, initX, initY, LETTER_WIDTH, LETTER_HEIGHT))
    end
end

function spawnOrderLetter(dt)
    timeSpawnCoffee = timeSpawnCoffee + dt
    if timeSpawnCoffee > nextCoffeeSpawn then
        timeSpawnCoffee = 0
        nextCoffeeSpawn = math.random(1,5)
        
        local initX = math.random(0, VIRTUAL_WIDTH - LETTER_WIDTH)
        local initY = math.random(-50, 0)

        -- if the player has the current letter
        if currentOrder[orderLetter] == player.currentWord:sub(#player.currentWord, #player.currentWord) then
            orderLetter = orderLetter + 1 -- move to next letter
        end

        if orderLetter <= #currentOrder then
            local coffeeLetter = currentOrder[orderLetter]
            table.insert(letters, Letter(coffeeLetter, initX, initY, LETTER_WIDTH, LETTER_HEIGHT))
        end
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
    spawnOrderLetter(dt)

    for keyp, projectile in pairs(projectiles) do 
        for keyl, letter in pairs(letters) do 
            if projectile.x + projectile.width > letter.x and projectile.x < (letter.x + letter.width) and projectile.y < (letter.y + letter.height) then
                player.currentWord = player.currentWord .. letter.value
                table.remove(projectiles, keyp)
                table.remove(letters, keyl)
            end
        end
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

    for key, projectile in pairs(projectiles) do 
        projectile:update(dt) 

        if projectile.y < 0 - projectile.height then 
            table.remove(projectiles, key)
        end
    end

    for key, letter in pairs(letters) do 
        letter:update(dt) 

        if letter.y > VIRTUAL_HEIGHT then 
            table.remove(letters, key) 
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