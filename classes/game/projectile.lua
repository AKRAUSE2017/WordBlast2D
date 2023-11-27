Projectile = Class{}

PROJECTILE_SPEED = 150

function Projectile:init(x, y, w, h, mode, angle)
    self.shoot_sound = love.audio.newSource("assets/sounds/shoot.wav", "static")
    self.shoot_sound:setVolume(0.1)
    
    self.width = w
    self.height = h

    self.x = x
    self.y = y

    self.dy = 0
    self.dx = 0

    self.mode = mode
    self.angle = angle

    self.speed = PROJECTILE_SPEED

    if self.mode == "static_aim" then self.speed = 500 end
end

function Projectile:render()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Projectile:update(dt)
    if self.mode == "LR_move" then
        self.dy = -self.speed
        self.y = self.y + self.dy * dt
    
    elseif self.mode == "static_aim" then
        self.dx = self.speed * (90-self.angle)/90
        self.x = self.x + self.dx * dt
        
        self.dy = -(self.speed - math.abs(self.dx))
        self.y = self.y + self.dy * dt
    end
end