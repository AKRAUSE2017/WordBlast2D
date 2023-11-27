require('classes.game.customer')
require('classes.game.order')
require('classes.game.timer')

OrderUtils = Class{}

function OrderUtils:selectRandomOrder()
    randOrder = coffeeOrders[math.random(1,#coffeeOrders)]
    currentOrder = Order(randOrder)
    randomCustomer = math.random(1,9)
    customer = Customer(-10, -5, 'assets/customers/'..randomCustomer..'/skeleton.png', 'assets/customers/'..randomCustomer..'/skeleton_open.png', 'assets/customers/'..randomCustomer..'/skeleton_happy.png')
    return customer, currentOrder
end

function OrderUtils:initOrderBufferTimer()
    self.bufferNextOrderTimer = Timer(2)
end

function OrderUtils:handleOrderComplete(customer, currentOrder, player, dt)
    currentOrder.trackingOrderTimer = false
    self.bufferNextOrderTimer:updateElapsedTime(dt)
    
    if self.bufferNextOrderTimer.elapsedTime > self.bufferNextOrderTimer.endTime then
        customer:setSpriteStatus("none")

        currentOrder.orderString = ""
        currentOrder.orderChars = {}
        currentOrder.orderTimer.elapsedTime = -1
        currentOrder.firstTimeFirstLetter = false

        currentOrder.trackFulfillment = ""

        if self.bufferNextOrderTimer.elapsedTime > 3 then
            self.bufferNextOrderTimer:resetElapsedTime()
            player:increaseScore()
            print("Points", player.score)
            customer, currentOrder = OrderUtils:selectRandomOrder()
        end
    else
        customer:setSpriteStatus("happy")
    end

    return customer, currentOrder, player
end

function OrderUtils:handleOrderCollisionUpdate(currentOrder, letter, projectiles, letters, keyProj, keyLet, dt)
    -- print("Letter needed", currentOrder.orderChars[currentOrder.currentLetterIndex].value)
    -- print("Letter grabbed", letter.value)
    -- print("New word", currentOrder.trackFulfillment .. letter.value)
    -- print("Target word", currentOrder.orderString:sub(1, currentOrder.currentLetterIndex))
    if currentOrder.orderChars[currentOrder.currentLetterIndex].value == letter.value and (currentOrder.trackFulfillment .. letter.value) == currentOrder.orderString:sub(1, currentOrder.currentLetterIndex) then
        -- print("New letter")
        currentOrder.currentLetterIndex = currentOrder.currentLetterIndex + 1 -- move to next letter
        
        currentOrder.orderLetterTimer:resetElapsedTime(dt)
        local spawnFreq = currentOrder.orderCharsSpawnFreq[currentOrder.currentLetterIndex]
        currentOrder.orderLetterTimer:newEndTime(spawnFreq)
    end

    if letter.value == CLEAR_SYMBOL then -- if the player grabbed "!"
        if #currentOrder.trackFulfillment > 0 then
            if currentOrder.trackFulfillment:sub(1, currentOrder.currentLetterIndex) == currentOrder.orderString:sub(1, currentOrder.currentLetterIndex-1) then -- if the letter that will be cleared is a valid part of the order
                -- print("reverting to", currentOrder.orderChars[currentOrder.currentLetterIndex-1].value)
                currentOrder.currentLetterIndex = currentOrder.currentLetterIndex - 1 -- revert the current currentOrder.currentLetterIndex to the previous one
            end

            currentOrder.trackFulfillment = currentOrder.trackFulfillment:sub(1, #currentOrder.trackFulfillment-1) -- clear the last letter
        end
    else
        currentOrder.trackFulfillment = currentOrder.trackFulfillment .. letter.value -- the player didn't grab a "!" then add the letter they grabbed to the current word
    end
    table.remove(projectiles, keyProj) -- remove projectile that collided
    table.remove(letters, keyLet) -- remove letter that was hit

    return currentOrder, projectiles, letters
end

function OrderUtils:debugMockCollectLetter(letter, currentOrder)
    isNecessaryLetter = currentOrder.orderChars[currentOrder.currentLetterIndex].value == letter.value

    -- mock projectile (testing)
    if letter.y > (VIRTUAL_HEIGHT - 20 - LETTER_HEIGHT) and letter.y < (VIRTUAL_HEIGHT - 40 - LETTER_HEIGHT) and isNecessaryLetter then
        currentOrder.currentLetterIndex = currentOrder.currentLetterIndex + 1
        print("letter "..letter.value.." got to bottom at "..tostring(currentOrder.orderTimer.elapsedTime))

        currentOrder.orderLetterTimer:resetElapsedTime(dt)
        local spawnFreq = currentOrder.orderCharsSpawnFreq[currentOrder.currentLetterIndex]
        currentOrder.orderLetterTimer:newEndTime(spawnFreq)
    end
    return currentOrder
end