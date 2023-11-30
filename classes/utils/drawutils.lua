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
        love.graphics.print(string.format("%.2f", currentOrder.orderTimer.elapsedTime), VIRTUAL_WIDTH - 150, 15)
    end
    love.graphics.setColor(255/255, 255/255, 255/255)
end

function drawButton(text, dims)
    local x = dims[1]
    local y = dims[2]
    local w = dims[3]
    local h = dims[4]
    love.graphics.setColor(10/255, 60/255, 42/255)
    love.graphics.rectangle("fill", x-3, y-3, w+6, h+6)
    love.graphics.setColor(24/255, 70/255, 50/255)
    love.graphics.rectangle("fill", x, y, w, h)

    love.graphics.setColor(255/255, 255/255, 255/255)

    local btnCenter = x + 80/2
    local textSize = #text * 4
    local textX = btnCenter - textSize

    love.graphics.print(text, textX, y+2)
end

function drawMenuBg()
    love.graphics.setColor(24/255, 70/255, 50/255)
    love.graphics.rectangle("fill",VIRTUAL_WIDTH/5,VIRTUAL_HEIGHT/5, VIRTUAL_WIDTH-(VIRTUAL_WIDTH/5)*2, VIRTUAL_HEIGHT-(VIRTUAL_HEIGHT/5)*2)
    love.graphics.setColor(1/255, 50/255, 32/255)
    love.graphics.rectangle("fill",VIRTUAL_WIDTH/4,VIRTUAL_HEIGHT/4,VIRTUAL_WIDTH-(VIRTUAL_WIDTH/4)*2,VIRTUAL_HEIGHT-(VIRTUAL_HEIGHT/4)*2)
    
    love.graphics.setColor(255/255, 255/255, 255/255)
    local title = "Barista Blast!"
    local center = (VIRTUAL_WIDTH/2) - (#title)*4
    love.graphics.print(title, center, VIRTUAL_HEIGHT/4 + 10)
end    

function DrawUtils:getButtonDims(text)
    if text == "Start" then
        return {VIRTUAL_WIDTH/2 - 45, VIRTUAL_HEIGHT/4 + 40, 80, 20}
    elseif text == "Credits" then
        return {VIRTUAL_WIDTH/2 - 45, VIRTUAL_HEIGHT/4 + 70, 80, 20}
    elseif text == "Settings" then
        return {VIRTUAL_WIDTH/2 - 45, VIRTUAL_HEIGHT/4 + 100, 80, 20}
    elseif text == "-" then
        return {238, VIRTUAL_HEIGHT/4 + 57, 10, 10}
    elseif text == "+" then
        return {262, VIRTUAL_HEIGHT/4 + 57, 10, 10}
    elseif text == "Back" then
        return {VIRTUAL_WIDTH/2 - 42, VIRTUAL_HEIGHT/4 + 90, 80, 20}
    elseif text == "<" then
        return {VIRTUAL_WIDTH/4 + 10 , VIRTUAL_HEIGHT/4 + 10, 10, 10}
    end
end

function DrawUtils:renderMenu()
    drawMenuBg()

    drawButton("Start", DrawUtils:getButtonDims("Start"))
    drawButton("Credits", DrawUtils:getButtonDims("Credits"))
    drawButton("Settings", DrawUtils:getButtonDims("Settings"))
end

function DrawUtils:renderCredits()
    drawMenuBg()

    love.graphics.setColor(255/255, 255/255, 255/255)

    local bgCenter = VIRTUAL_WIDTH/4 + (VIRTUAL_WIDTH-(VIRTUAL_WIDTH/4)*2)/2
    
    local title = "Design ... Alena Krause"
    local textSize = #title * 4
    local textX = bgCenter - textSize
    love.graphics.print(title, textX, VIRTUAL_HEIGHT/4 + 35)

    title = "Programming ... Alena Krause"
    textSize = #title * 4
    textX = bgCenter - textSize
    love.graphics.print(title, textX, VIRTUAL_HEIGHT/4 + 55)

    title = "Art ... Alena Krause"
    textSize = #title * 4
    textX = bgCenter - textSize
    love.graphics.print(title, textX, VIRTUAL_HEIGHT/4 + 75)
    
    title = "Music ... Isaiah Jones"
    textSize = #title * 4
    textX = bgCenter - textSize
    love.graphics.print(title, textX, VIRTUAL_HEIGHT/4 + 95)

    title = "QA ... James Wade"
    textSize = #title * 4
    textX = bgCenter - textSize
    love.graphics.print(title, textX, VIRTUAL_HEIGHT/4 + 115)

    local btnDims = DrawUtils:getButtonDims("<")
    love.graphics.print("<", btnDims[1], btnDims[2])
end


function DrawUtils:renderSettings(currentVolume)
    drawMenuBg()
    love.graphics.setColor(255/255, 255/255, 255/255)

    local bgCenter = VIRTUAL_WIDTH/4 + (VIRTUAL_WIDTH-(VIRTUAL_WIDTH/4)*2)/2
    
    local setting = "Volume "..currentVolume
    local textSize = #setting * 4
    local textX = bgCenter - textSize
    love.graphics.print(setting, textX, VIRTUAL_HEIGHT/4 + 35)

    local setting = "-  +"
    local textSize = #setting * 4
    local textX = bgCenter - textSize
    love.graphics.print(setting, textX, VIRTUAL_HEIGHT/4 + 55)

    btnDims = DrawUtils:getButtonDims("-")
    love.graphics.rectangle("line", btnDims[1], btnDims[2], btnDims[3], btnDims[4])
    btnDims = DrawUtils:getButtonDims("+")
    love.graphics.rectangle("line", btnDims[1], btnDims[2], btnDims[3], btnDims[4])

    local btnDims = DrawUtils:getButtonDims("<")
    love.graphics.print("<", btnDims[1], btnDims[2])
end