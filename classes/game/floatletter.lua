FloatLetter = Class {}

function FloatLetter:init(x, y, value, direction)
    self.x = x
    self.y = y

    self.value = value

    self.direction = direction
    self.speed = 5
end

function FloatLetter:render()
    love.graphics.print(self.value, self.x, self.y)
end

function FloatLetter:update(dt)
    -- if self.y >= 16 or self.y <= 12 then
    --     self.direction = self.direction * -1
    -- end

    -- self.dy = self.direction * self.speed
    self.y = self.y -- + self.dy * dt
end