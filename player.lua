Player = Class{}

DISTANCE_BOTTOM = 5

function Player:init(w, h)
    self.width = w
    self.height = h

    self.x = (VIRTUAL_WIDTH / 2) + (self.width / 2)
    self.y = VIRTUAL_HEIGHT - self.height - DISTANCE_BOTTOM

    self.dx = 0
    self.currentWord = ""

    self.state = "LR_move"
    self.aimAngle = 90

    self.startAimX = 0
    self.startAimY = 0
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

function Player:setAimCoords()
    self.startAimX = self.x + (self.width/2) - (PROJECTILE_WIDTH/2)
    self.startAimY = self.y - 10
end

function Player:getAimX()
    angle = (self.aimAngle) * (math.pi/180)
    cos_angle = math.cos(angle) -- radians

    radius = (VIRTUAL_HEIGHT - DISTANCE_BOTTOM - self.height/2) - self.startAimY

    offsetX = radius * cos_angle

    return self.startAimX + offsetX
end

function Player:getAimY()
    angle = (self.aimAngle) * (math.pi/180)
    sin_angle = math.sin(angle) -- radians

    radius = (VIRTUAL_HEIGHT - DISTANCE_BOTTOM - self.height/2) - self.startAimY

    offsetY = radius * sin_angle

    return (VIRTUAL_HEIGHT - DISTANCE_BOTTOM - self.height/2) - offsetY
end