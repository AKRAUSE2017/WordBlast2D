Letter = Class{}

MIN_LETTER_SPEED = 50
MAX_LETTER_SPEED = 100

function Letter:init(value, x, y, w, h)
    self.width = w
    self.height = h

    self.value = value

    self.x = x
    self.y = y

    self.dy = 0
end

function Letter:render()
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.print(self.value, self.x + 2, self.y - 1)
end

function Letter:update(dt)
    self.dy = math.random(MIN_LETTER_SPEED, MAX_LETTER_SPEED)
    self.y = self.y + self.dy * dt
end