Fish = Class{}

function Fish:init(x, y, image, start_speed, flip)
    self.x = x
    self.y = y

    self.sprite = love.graphics.newImage(image)

    TANK_MIN_X = VIRTUAL_WIDTH - 55
    TANK_MAX_X = VIRTUAL_WIDTH - 25

    self.speed = start_speed

    self.flip = flip
end

function Fish:render()
    love.graphics.draw(self.sprite, self.x, self.y, 0, self.flip, 1)
end

function Fish:update(dt)
    self.x = self.x + self.speed * dt

    if self.x > TANK_MAX_X and self.flip == 1 then
        self.speed = self.speed * -1 
        self.flip = self.flip * -1
        self.x = TANK_MAX_X - self.speed
    elseif self.x < TANK_MIN_X and self.flip == -1 then 
        self.speed = self.speed * -1 
        self.flip = self.flip * -1
        self.x = TANK_MIN_X - self.speed
    end
end