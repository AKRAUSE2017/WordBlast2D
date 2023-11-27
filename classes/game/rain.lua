Rain = Class{}

function Rain:init(x, y, image)
    self.x = x
    self.y = y
    self.reset_y = y -- -55

    self.dy = 175

    self.sprite = love.graphics.newImage(image)
    self.sprite_threshold = 61
end

function Rain:render()
    love.graphics.draw(self.sprite, self.x, self.y)
end

function Rain:update(dt)
    self.y = (self.y + self.dy * dt)
    if self.y > self.sprite_threshold then
        self.y = self.reset_y
    end
end