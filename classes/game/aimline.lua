AimLine = Class {}

function AimLine:init(x, y, w, h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
end

function AimLine:render()
    love.graphics.setColor(255, 255, 255, 20)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
end

function AimLine:update(new_x, new_y)
    self.x = new_x
    self.y = new_y
end