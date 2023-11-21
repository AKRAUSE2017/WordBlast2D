DrawUtils = Class{}

function DrawUtils:renderOrderStatus(currentOrder)
    -- love.graphics.setColor(0, 255/255, 0, 255/255)
    for _, floatLetter in pairs(currentOrder.orderChars) do
        floatLetter:render()
    end

    local fulFillX = 35
    for i = 1, #currentOrder.trackFulfillment do
        local char = string.sub(currentOrder.trackFulfillment, i, i)
        love.graphics.print(char, fulFillX, 35)
        fulFillX = fulFillX + 10
    end
    
    -- print(currentOrder.orderTimer.endTime)
    if currentOrder.orderTimer.elapsedTime > currentOrder.orderTimer.endTime and currentOrder.orderTimer.endTime ~= 0 then
        love.graphics.setColor(255/255, 255/255, 0/255)
    end
    if currentOrder.orderTimer.elapsedTime ~= -1 then
        love.graphics.print(string.format("%.2f", currentOrder.orderTimer.elapsedTime), VIRTUAL_WIDTH - 45, 15)
    end
    love.graphics.setColor(255/255, 255/255, 255/255)
end

function DrawUtils:renderMenu()
    love.graphics.setColor(24/255, 70/255, 50/255)
    love.graphics.rectangle("fill",VIRTUAL_WIDTH/7,VIRTUAL_HEIGHT/7, VIRTUAL_WIDTH-(VIRTUAL_WIDTH/7)*2, VIRTUAL_HEIGHT-(VIRTUAL_HEIGHT/7)*2)
    love.graphics.setColor(1/255, 50/255, 32/255)
    love.graphics.rectangle("fill",VIRTUAL_WIDTH/6,VIRTUAL_HEIGHT/6,VIRTUAL_WIDTH-(VIRTUAL_WIDTH/6)*2,VIRTUAL_HEIGHT-(VIRTUAL_HEIGHT/6)*2)
    love.graphics.setColor(255/255, 255/255, 255/255)
    local center = VIRTUAL_WIDTH/2 - 3*#"Barista Blast!"
    love.graphics.print("Barista Blast!", center, VIRTUAL_HEIGHT/6 + 10)

    love.graphics.setColor(24/255, 70/255, 50/255)
    love.graphics.rectangle("fill",center, VIRTUAL_HEIGHT/6 + 50, 80, 20)
end