Player = Class{}

function Player:init(w, h)
    self.width = w
    self.height = h

    self.x = (VIRTUAL_WIDTH / 2) + (self.width / 2)
    self.y = VIRTUAL_HEIGHT - self.height - 5

    self.dx = 0
    self.currentWord = ""
end

function Player:render()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Player:update(dt)
    newPosition = self.x + self.dx * dt
    if self.dx > 0 then
        self.x = math.min(VIRTUAL_WIDTH - self.width, newPosition)
    else
        self.x = math.max(0, newPosition)
    end
end