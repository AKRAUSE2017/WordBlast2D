Letter = Class{}

MIN_LETTER_SPEED = 50
MAX_LETTER_SPEED = 100

function Letter:init(value, x, y, w, h, defined_speed)
    self.width = w
    self.height = h

    self.value = value

    self.x = x
    self.y = y

    self.dy = 0

    if defined_speed then
        self.min_speed = defined_speed
        self.max_speed = defined_speed
    else
        self.min_speed = MIN_LETTER_SPEED
        self.max_speed = MAX_LETTER_SPEED
    end
end

function Letter:render()
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.print(self.value, self.x + 2, self.y - 1)
end

function Letter:update(dt)
    self.dy = math.random(self.min_speed, self.max_speed)
    self.y = self.y + self.dy * dt
end