push = require('push')
Class = require('class')

require('player')
require('projectile')
require('letter')
require('customer')
require('order')
require('timer')
require('aimline')

WINDOW_WIDTH = 1024
WINDOW_HEIGHT = 576

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

PLAYER_SPEED = 200

PROJECTILE_WIDTH = 3
PROJECTILE_HEIGHT = 3

LETTER_WIDTH = 15
LETTER_HEIGHT = 15
INIT_Y = -30

local player = Player(10, 10)

local projectiles = {}
local letters = {}
local alphabet = {}
local aimLines = {}

local coffeeOrders = {"ESPRESSO", "CAPPUCCINO", "LATTE", "AMERICANO", "MOCHA", "MACCHIATO", "RISTRETTO", "CORTADO", "AFFOGATO", "DECAF", "TURKISH", "IRISH", "FLATWHITE", "FRAPPE", "REDEYE", "BREVE", "PICCOLO", "CUBANO", "LUNGO", "MAZAGRAN"}

-- CONSTS
local bufferSpaceLetterLine = 10 -- space between letters when spawning a letter line
local clearSymbol = "!"

math.randomseed(os.time())

function selectRandomOrder()
    randOrder = coffeeOrders[math.random(1,#coffeeOrders)]
    currentOrder = Order(randOrder)
    randomCustomer = math.random(1,9)
    customer = Customer(-10, -5, 'assets/customers/'..randomCustomer..'/skeleton.png', 'assets/customers/'..randomCustomer..'/skeleton_open.png', 'assets/customers/'..randomCustomer..'/skeleton_happy.png')
end

function initLetterTimers()
    randLetterTimer = Timer(3)
    letterLineTimer = Timer(20)
    clearLetterTimer = Timer(5)
    bufferNextOrderTimer = Timer(2)
end

function love.load()
    background_music = love.audio.newSource("assets/music.mp3", "stream")

    background_music:setVolume(0.1) 
    background_music:setPitch(1.05)

    love.graphics.setDefaultFilter('nearest', 'nearest') -- no bluriness no interpolation on pixels when scaled
    love.window.setTitle("Word Blast")
    
    smallFont = love.graphics.newFont('assets/font.ttf', 15)
    background = love.graphics.newImage("assets/background_test.png")
    
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
    initLetterTimers()
end

function love.resize(w,h)
    push:resize(w,h)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "k" then
        player.currentWord = currentOrder.orderString
    elseif key == "1" then
        player.state = "LR_move"
    elseif key == "2" then
        player.state = "static_aim"

        player:setAimCoords()
        local initX = player.startAimX
        local initY = player.startAimY
        aimMarker = Projectile(initX, initY, PROJECTILE_WIDTH, PROJECTILE_HEIGHT)
    end

    
    if key == "space" then
        if player.state == "LR_move" then
            initX = player.x + (player.width/2) - (PROJECTILE_WIDTH/2)
            initY = player.y - 5

            local p = Projectile(initX, initY, PROJECTILE_WIDTH, PROJECTILE_HEIGHT, "LR_move", 90)
            table.insert(projectiles, p)
            love.audio.play(p.shoot_sound)
        elseif player.state == "static_aim" then
            initX = player:getAimX()
            initY = player:getAimY()

            local p = Projectile(initX, initY, PROJECTILE_WIDTH+5, PROJECTILE_HEIGHT+5, "static_aim", player.aimAngle)
            table.insert(projectiles, p)
            love.audio.play(p.shoot_sound)
        end
        
        -- print("Creating new projectile", initX, initY)
    end
end

function displayWords()
    -- simple display across all states
    love.graphics.setFont(smallFont)
    -- love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print(currentOrder.orderString, 35, 15)
    love.graphics.print(player.currentWord, 35, 35) -- concat in lua is '..'
    
    -- print(currentOrder.orderTimer.endTime)
    if currentOrder.orderTimer.elapsedTime > currentOrder.orderTimer.endTime and currentOrder.orderTimer.endTime ~= 0 then
        love.graphics.setColor(255/255, 255/255, 0/255)
    end
    if currentOrder.orderTimer.elapsedTime ~= -1 then
        love.graphics.print(string.format("%.2f", currentOrder.orderTimer.elapsedTime), VIRTUAL_WIDTH - 45, 15)
    end
    love.graphics.setColor(255/255, 255/255, 255/255)
end

function love.draw()
    push:start()   

    love.graphics.draw(background, 0, 0, 0, 1, 1)

    displayWords()
    player:render()
    if customer then customer:render() end

    for key, projectile in pairs(projectiles) do -- iterate through each projectile
        projectile:render() -- update the position
    end

    for key, letter in pairs(letters) do -- iterate through each letter
        letter:render() -- update the position
    end

    if player.state == "static_aim" then
        aimMarker:render()
        if #aimLines == 150 then
            for i = 1, 150, 1 do
                aimLines[i]:render()
            end
        end
    end

    love.graphics.rectangle("fill", 0, VIRTUAL_HEIGHT - 20, 600, 2) -- TESTING

    push:finish()
end

function spawnRandomLetter(dt)
    randLetterTimer:updateElapsedTime(dt)
    if randLetterTimer.elapsedTime > randLetterTimer.endTime then
        randLetterTimer:resetElapsedTime(dt)
        randLetterTimer:newEndTime(math.random(1,3))
        
        local initX = math.random(0, VIRTUAL_WIDTH - LETTER_WIDTH)
        local initY = math.random(-50, 0)
        local alphaValue = alphabet[math.random(1, 26)]
        table.insert(letters, Letter(alphaValue, initX, initY, LETTER_WIDTH, LETTER_HEIGHT))
    end
end

function spawnLetterToFulfillOrder(dt)
    -- print(currentOrder.orderLetterTimer.endTime)
    currentOrder.orderLetterTimer:updateElapsedTime(dt)
    if currentOrder.orderLetterTimer.endTime then
        if currentOrder.orderLetterTimer.elapsedTime > currentOrder.orderLetterTimer.endTime then
            currentOrder.orderLetterTimer:resetElapsedTime(dt)
            local spawnFreq = currentOrder.orderCharsSpawnFreq[currentOrder.currentLetterIndex]
            currentOrder.orderLetterTimer:newEndTime(spawnFreq)

            -- print("letter "..currentOrder.orderChars[currentOrder.currentLetterIndex].." spawning after "..currentOrder.orderLetterTimer.endTime.."s")

            if currentOrder.currentLetterIndex <= #currentOrder.orderChars then
                local initX = math.random(0, VIRTUAL_WIDTH - LETTER_WIDTH)
                local initY = INIT_Y -- currentOrder.orderCharsInitY[currentOrder.currentLetterIndex]
                
                if currentOrder.willSpawnLetterLine and currentOrder.currentLetterIndex == currentOrder.letterLineSpawnIndex then
                    spawnLetterLine()
                    currentOrder.willSpawnLetterLine = false
                elseif currentOrder.currentLetterIndex ~= currentOrder.letterLineSpawnIndex then
                    local coffeeChar = currentOrder.orderChars[currentOrder.currentLetterIndex]
                
                    local letter = Letter(coffeeChar, initX, initY, LETTER_WIDTH, LETTER_HEIGHT)
                    letter:setSpeed(currentOrder.orderCharsSpeed[currentOrder.currentLetterIndex])
                    
                    table.insert(letters, letter)
                end
            end
        end
    end
end

function spawnClearLetter(dt)
    clearLetterTimer:updateElapsedTime(dt)
    if clearLetterTimer.elapsedTime > clearLetterTimer.endTime then
        clearLetterTimer:resetElapsedTime(dt)
        clearLetterTimer:newEndTime(math.random(1,5))

        local initX = math.random(0, VIRTUAL_WIDTH - LETTER_WIDTH)
        local initY = math.random(-50, 0)
        local clearValue = clearSymbol
        table.insert(letters, Letter(clearValue, initX, initY, LETTER_WIDTH, LETTER_HEIGHT))   
    end
end

function isInTable(elem, table)
    local i = 1
    while i <= #table do
        if table[i] == elem then
            return true
        end
        i = i + 1
    end
    return false
end

function spawnLetterLine()
    frozenCurrentLetterIndex = currentOrder.currentLetterIndex -- we only want to make comparisons with respect to what the current letter was at the time
    randLetterTimer:newEndTime(10)
    -- clearLetterTimer:newEndTime(10)

    local numLetters = (VIRTUAL_WIDTH / (LETTER_WIDTH + bufferSpaceLetterLine)) + 5
    
    randomIndicies = {}
    for i = 1,3 do
        randomIndex = math.random(1, numLetters)
        while isInTable(randomIndex, randomIndicies) do
            randomIndex = math.random(1, numLetters)
        end
        table.insert(randomIndicies,randomIndex)
        -- print(randomIndex)
    end

    local countGuranteedLetters = 1
    local currentInitX = 0
    for i = 1, numLetters do
        local alphaValue = ''
        
        currentInitX = currentInitX + (bufferSpaceLetterLine / 2)
        local initY = INIT_Y
        
        if not isInTable(i, randomIndicies) then
            alphaValue = alphabet[math.random(1, 26)]
        else
            if (frozenCurrentLetterIndex + (countGuranteedLetters - 1)) <= #currentOrder.orderString then
                alphaValue = currentOrder.orderChars[frozenCurrentLetterIndex + (countGuranteedLetters - 1)]
            else
                alphaValue = currentOrder.orderChars[#currentOrder.orderString]
            end
            
            countGuranteedLetters = countGuranteedLetters + 1
        end

        local letter = Letter(alphaValue, currentInitX, initY, LETTER_WIDTH, LETTER_HEIGHT)
        letter:setSpeed(35)
        table.insert(letters, letter)

        currentInitX = currentInitX + LETTER_WIDTH
    end 
end

function handleSpriteAnimations(dt)
    customer.talkTimer = customer.talkTimer + dt
    if customer.talkTimer < 1 then
        if customer.talkTimer > customer.timeSwitchAnimation then 
            if customer.spriteStatus == "resting" then customer:setSpriteStatus("open") 
            else customer:setSpriteStatus("resting") end
            customer.timeSwitchAnimation = customer.timeSwitchAnimation + 0.15
        end
    else
        sprite = "resting"
    end
end

function handlePlayerMove() 
    if love.keyboard.isDown('d') or love.keyboard.isDown('right') then
        player.dx = PLAYER_SPEED
    elseif love.keyboard.isDown('a') or love.keyboard.isDown('left')  then
        player.dx = -PLAYER_SPEED
    else
        player.dx = 0
    end
end

function handlePlayerAim(dt)
    player.dx = 0

    if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
        player.aimAngle = math.min(player.aimAngle + 100 * dt, 180)
    elseif love.keyboard.isDown('d') or love.keyboard.isDown('right')  then
        player.aimAngle = math.max(player.aimAngle - 100 * dt, 0)
    end

    -- print(player.aimAngle)
    
end

function collision(proj, let)
    projectileLeftEdge = proj.x
    projectileRightEdge = proj.x + proj.width
    projectileBtmEdge = proj.y + proj.height
    projectileTopEdge = proj.y

    letterLeftEdge = let.x
    letterRightEdge = let.x + let.width
    letterTopEdge = let.y
    letterBtmEdge = let.y + let.height

    case1 = projectileRightEdge > letterLeftEdge and projectileRightEdge < letterRightEdge and projectileBtmEdge > letterTopEdge and projectileTopEdge < letterBtmEdge
    case2 = projectileLeftEdge < letterRightEdge and projectileLeftEdge > letterLeftEdge and projectileBtmEdge > letterTopEdge and projectileTopEdge < letterBtmEdge

    return case1 or case2
end

function love.update(dt)
    -- if not background_music:isPlaying( ) then
	-- 	love.audio.play(background_music)
	-- end

    if player.state == "LR_move" then
        handlePlayerMove()
    elseif player.state == "static_aim" then
        handlePlayerAim(dt)
        
        aimMarker.x = player:getAimX()
        aimMarker.y = player:getAimY()
        
        guideX = aimMarker.x
        guideY = aimMarker.y

        deltaX = 10 * (90-player.aimAngle)/90
        deltaY = -(10 - math.abs(deltaX))

        if #aimLines == 0 then
            for i = 1, 150, 1 do
                guideX = guideX + deltaX
                guideY = guideY + deltaY
                
                table.insert(aimLines, AimLine(guideX, guideY, PROJECTILE_WIDTH, PROJECTILE_HEIGHT))
            end
        else
            for i = 1, 150, 1 do
                guideX = guideX + deltaX
                guideY = guideY + deltaY
                
                aimLines[i]:update(guideX, guideY)
            end
        end
    end

    spawnRandomLetter(dt)
    spawnLetterToFulfillOrder(dt)
    spawnClearLetter(dt)

    handleSpriteAnimations(dt)

    if currentOrder.trackingOrderTimer then
        currentOrder.orderTimer:updateElapsedTime(dt)
    end

    -- Handle collisions
    for keyp, projectile in pairs(projectiles) do 
        for keyl, letter in pairs(letters) do 
            if collision(projectile, letter) then
                love.audio.play(letter.collect_sound)
                -- if the player grabbed the necessary order letter
                
                if currentOrder.orderChars[currentOrder.currentLetterIndex] == letter.value and (player.currentWord .. letter.value):sub(1, currentOrder.currentLetterIndex+1) == currentOrder.orderString:sub(1, currentOrder.currentLetterIndex) then
                    currentOrder.currentLetterIndex = currentOrder.currentLetterIndex + 1 -- move to next letter
                    
                    currentOrder.orderLetterTimer:resetElapsedTime(dt)
                    local spawnFreq = currentOrder.orderCharsSpawnFreq[currentOrder.currentLetterIndex]
                    currentOrder.orderLetterTimer:newEndTime(spawnFreq)
                end

                if letter.value == clearSymbol then -- if the player grabbed "!"
                    -- print("player word", player.currentWord:sub(1, currentOrder.currentLetterIndex))
                    -- print("target word", currentOrder.orderString:sub(1, currentOrder.currentLetterIndex-1))
                    if #player.currentWord > 0 then
                        if player.currentWord:sub(1, currentOrder.currentLetterIndex) == currentOrder.orderString:sub(1, currentOrder.currentLetterIndex-1) then -- if the letter that will be cleared is a valid part of the order
                            print("reverting to", currentOrder.orderChars[currentOrder.currentLetterIndex-1])
                            currentOrder.currentLetterIndex = currentOrder.currentLetterIndex - 1 -- revert the current currentOrder.currentLetterIndex to the previous one
                        end

                        player.currentWord = player.currentWord:sub(1, #player.currentWord-1) -- clear the last letter
                    end
                else
                    player.currentWord = player.currentWord .. letter.value -- the player didn't grab a "!" then add the letter they grabbed to the current word
                end
                table.remove(projectiles, keyp) -- remove projectile that collided
                table.remove(letters, keyl) -- remove letter that was hit
            end
        end
    end

    -- Handle order completion and next order
    if player.currentWord == currentOrder.orderString or customer.spriteStatus == "happy" then
        currentOrder.trackingOrderTimer = false
        bufferNextOrderTimer:updateElapsedTime(dt)
        
        if bufferNextOrderTimer.elapsedTime > bufferNextOrderTimer.endTime then
            customer:setSpriteStatus("none")

            currentOrder.orderString = ""
            currentOrder.orderTimer.elapsedTime = -1
            currentOrder.firstTimeFirstLetter = false

            player.currentWord = ""

            if bufferNextOrderTimer.elapsedTime > 3 then
                bufferNextOrderTimer:resetElapsedTime()
                selectRandomOrder()
            end
        else
            customer:setSpriteStatus("happy")
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

        -- handle timer
        --print(currentOrder.orderChars[currentOrder.currentLetterIndex])
        isNecessaryLetter = currentOrder.orderChars[currentOrder.currentLetterIndex] == letter.value
        
        --print(currentOrder.orderChars[currentOrder.currentLetterIndex])
        if isNecessaryLetter and currentOrder.firstTimeFirstLetter and letter.y > 0 then -- if the letter is the first necessary character and its the first time the player is seeing it
            currentOrder.firstTimeFirstLetter = false
            currentOrder.trackingOrderTimer = true

            print(currentOrder.speedThreshold)
        end

        -- mock projectile (testing)
        -- if letter.y > (VIRTUAL_HEIGHT - 20 - LETTER_HEIGHT) and letter.y < (VIRTUAL_HEIGHT - 40 - LETTER_HEIGHT) and isNecessaryLetter then
        --     currentOrder.currentLetterIndex = currentOrder.currentLetterIndex + 1
        --     print("letter "..letter.value.." got to bottom at "..tostring(currentOrder.orderTimer.elapsedTime))

        --     currentOrder.orderLetterTimer:resetElapsedTime(dt)
        --     local spawnFreq = currentOrder.orderCharsSpawnFreq[currentOrder.currentLetterIndex]
        --     currentOrder.orderLetterTimer:newEndTime(spawnFreq)
        -- end

        if letter.y > VIRTUAL_HEIGHT then
            table.remove(letters, key) -- remove if it went off screen
        end
    end

    player:update(dt)
end