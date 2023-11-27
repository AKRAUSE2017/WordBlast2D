require('classes.game.timer')
SpawnUtils = Class{}

function SpawnUtils:initLetterTimers()
    -- functional timers
    self.randLetterTimer = Timer(3)
    self.letterLineTimer = Timer(20)
    self.clearLetterTimer = Timer(5)
end


function SpawnUtils:spawnRandomLetter(letters, dt)
    self.randLetterTimer:updateElapsedTime(dt)
    if self.randLetterTimer.elapsedTime > self.randLetterTimer.endTime then
        self.randLetterTimer:resetElapsedTime(dt)
        self.randLetterTimer:newEndTime(math.random(1,3))
        
        local initX = math.random(0, VIRTUAL_WIDTH - LETTER_WIDTH)
        local initY = math.random(-50, 0)
        local alphaValue = alphabet[math.random(1, 26)]
        table.insert(letters, Letter(alphaValue, initX, initY, LETTER_WIDTH, LETTER_HEIGHT))
    end
    return letters
end

function SpawnUtils:spawnLetterToFulfillOrder(letters, dt)
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
                local initY = LETTER_INIT_Y -- currentOrder.orderCharsInitY[currentOrder.currentLetterIndex]
                
                if currentOrder.willSpawnLetterLine and currentOrder.currentLetterIndex == currentOrder.letterLineSpawnIndex then
                    letters = self:spawnLetterLine(letters)
                    currentOrder.willSpawnLetterLine = false
                else                     
                    local coffeeChar = currentOrder.orderChars[currentOrder.currentLetterIndex].value
                    -- print("spawning letter to fulfill order", coffeeChar)
                    local letter = Letter(coffeeChar, initX, initY, LETTER_WIDTH, LETTER_HEIGHT)
                    letter:setSpeed(currentOrder.orderCharsSpeed[currentOrder.currentLetterIndex])
                    
                    table.insert(letters, letter)
                end
            end
        end
    end
    return letters
end

function SpawnUtils:spawnClearLetter(letters, dt)
    bufferSpaceLetterLine = 10

    self.clearLetterTimer:updateElapsedTime(dt)
    if self.clearLetterTimer.elapsedTime > self.clearLetterTimer.endTime then
        self.clearLetterTimer:resetElapsedTime(dt)
        self.clearLetterTimer:newEndTime(math.random(1,5))

        local initX = math.random(0, VIRTUAL_WIDTH - LETTER_WIDTH)
        local initY = math.random(-50, 0)
        local clearValue = CLEAR_SYMBOL
        table.insert(letters, Letter(clearValue, initX, initY, LETTER_WIDTH, LETTER_HEIGHT))   
    end
    return letters
end

function SpawnUtils:spawnLetterLine(letters)
    frozenCurrentLetterIndex = currentOrder.currentLetterIndex -- we only want to make comparisons with respect to what the current letter was at the time
    self.randLetterTimer:newEndTime(10)
    -- self.clearLetterTimer:newEndTime(10)

    local numLetters = (VIRTUAL_WIDTH / (LETTER_WIDTH + bufferSpaceLetterLine)) + 5
    
    randomIndicies = {}
    for i = 1,3 do
        randomIndex = math.random(1, numLetters)
        while Utils:isInTable(randomIndex, randomIndicies) do
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
        local initY = LETTER_INIT_Y
        
        if not Utils:isInTable(i, randomIndicies) then
            alphaValue = alphabet[math.random(1, 26)]
        else
            if (frozenCurrentLetterIndex + (countGuranteedLetters - 1)) <= #currentOrder.orderString then
                alphaValue = currentOrder.orderChars[frozenCurrentLetterIndex + (countGuranteedLetters - 1)].value
            else
                alphaValue = currentOrder.orderChars[#currentOrder.orderString].value
            end
            
            countGuranteedLetters = countGuranteedLetters + 1
        end

        local letter = Letter(alphaValue, currentInitX, initY, LETTER_WIDTH, LETTER_HEIGHT)
        letter:setSpeed(35)
        table.insert(letters, letter)

        currentInitX = currentInitX + LETTER_WIDTH
    end 
    return letters
end