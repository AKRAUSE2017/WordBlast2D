Projectile = Class{}

PROJECTILE_SPEED = -100

function Projectile:init(x, y, w, h)
    self.width = w
    self.height = h

    self.x = x
    self.y = y

    self.dy = 0
end

function Projectile:render()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Projectile:update(dt)
    self.dy = PROJECTILE_SPEED
    self.y = self.y + self.dy * dt
end