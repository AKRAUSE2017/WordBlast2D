Customer = Class{}

function Customer:init(x, y, resting_image, open_image, happy_image)
    self.x = x
    self.y = y

    self.spriteStatus = "resting"

    self.sprites = {}

    self.sprites["resting"] = love.graphics.newImage(resting_image)
    self.sprites["open"] = love.graphics.newImage(open_image)
    self.sprites["happy"] = love.graphics.newImage(happy_image)

    self.talkTimer = 0
    self.timeSwitchAnimation = 0.15
end

function Customer:setSpriteStatus(status)
    self.spriteStatus = status
end

function Customer:render()
    if self.spriteStatus == "open" then
        love.graphics.draw(self.sprites["open"], self.x, self.y)
    elseif self.spriteStatus == "happy" then 
        love.graphics.draw(self.sprites["happy"], self.x, self.y)
    elseif self.spriteStatus == "resting" then
        love.graphics.draw(self.sprites["resting"], self.x, self.y)
    end
end

function Customer:update(dt)
    self.talkTimer = self.talkTimer + dt
    if self.talkTimer < 1 then
        if self.talkTimer > self.timeSwitchAnimation then 
            if self.spriteStatus == "resting" then customer:setSpriteStatus("open") 
            else customer:setSpriteStatus("resting") end
            self.timeSwitchAnimation = self.timeSwitchAnimation + 0.15
        end
    else
        self.spriteStatus = "resting"
    end
end