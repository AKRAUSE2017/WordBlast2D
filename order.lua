require('timer')
require('letter')

Order = Class{}

MIN_SPAWN_TIME = 1.5
MAX_SPAWN_TIME = 3

MIN_LETTER_SPEED = 50
MAX_LETTER_SPEED = 100

function Order:init(order, dt)
    ORDER_TIMER_BOUNDARY = VIRTUAL_HEIGHT - 20

    self.orderChars = {}
    self.orderString = order

    self.orderCharsSpawnFreq = {}
    -- self.orderCharsInitY = {}
    self.orderCharsSpeed = {}

    self.speedThreshold = 0 
    self.willSpawnLetterLine = false

    self.letterLineSpawnIndex = -1

    randomNum = 1--math.random(0,1)
    if randomNum == 1 then
        self.willSpawnLetterLine = true
        self.letterLineSpawnIndex = math.random(2,#order-1)
        print("WILL SPAWN LETTER LINE AT "..self.orderString:sub(self.letterLineSpawnIndex, self.letterLineSpawnIndex))
    end

    for i = 1, #self.orderString do
        local char = self.orderString:sub(i, i) -- Extract the character at position 'i'
        table.insert(self.orderChars, char)

        local spawnFreq = math.random(MIN_SPAWN_TIME, MAX_SPAWN_TIME)
        table.insert(self.orderCharsSpawnFreq, spawnFreq)

        local speed
        if self.willSpawnLetterLine and i == self.letterLineSpawnIndex then
            speed = 35
        else
            speed = math.random(MIN_LETTER_SPEED, MAX_LETTER_SPEED)
        end
        table.insert(self.orderCharsSpeed, speed)

        local distance = ORDER_TIMER_BOUNDARY + math.abs(INIT_Y) - LETTER_HEIGHT
        local estimatedTimeToBottom = distance / speed

        if i == 1 then
            speedTime =  estimatedTimeToBottom
        else
            speedTime = estimatedTimeToBottom + spawnFreq -- timer doesn't start until first char is visible so we don't count spawn time
        end

        -- print("letter "..char.." will take "..self.speedThreshold + speedTime.." to reach bottom ".." with speed "..tostring(speed))
        self.speedThreshold = self.speedThreshold + speedTime
    end

    self.currentLetterIndex = 1
    self.firstTimeFirstLetter = true
    
    self.trackingOrderTimer = false
    self.orderLetterTimer = Timer(self.orderCharsSpawnFreq[1])   

    self.orderTimer = Timer(self.speedThreshold)
end


