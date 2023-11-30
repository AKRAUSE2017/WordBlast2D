require('classes.game.projectile')
Player = Class{}

DISTANCE_BOTTOM = 5

function Player:init(w, h)
    self.width = w
    self.height = h

    self.x = (VIRTUAL_WIDTH / 2) + (self.width / 2)
    self.y = VIRTUAL_HEIGHT - self.height - DISTANCE_BOTTOM

    self.dx = 0

    self.score = 0

    self.state = "LR_move"
    self.aimAngle = 90

    self.startAimX = 0
    self.startAimY = 0

    self.aimMarker = -1
    self.aimLines = {}
end

function Player:render()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Player:renderScore()
    love.graphics.print("Score: "..self.score, VIRTUAL_WIDTH - 90, 15)
end

function Player:increaseScore()
    self.score = self.score + 1
end

function Player:update(dt)
    if self.state == "LR_move" then
        self:updatePosition(dt)
    elseif self.state == "static_aim" then
        self:updateAimLines(dt)
    end
end


-- UTILS
function Player:renderAimLines()
    if #self.aimLines == 150 then
        for i = 1, 150, 1 do
            self.aimLines[i]:render()
        end
    end
end    

function Player:updatePosition(dt)
    if love.keyboard.isDown('d') or love.keyboard.isDown('right') then
        self.dx = PLAYER_SPEED
    elseif love.keyboard.isDown('a') or love.keyboard.isDown('left')  then
        self.dx = -PLAYER_SPEED
    else
        self.dx = 0
    end

    newPosition = self.x + self.dx * dt
    if self.dx > 0 then
        self.x = math.min(VIRTUAL_WIDTH - self.width, newPosition)
    else
        self.x = math.max(0, newPosition)
    end
end

function Player:shoot(projectiles)
    if self.state == "LR_move" then
        initX = self.x + (self.width/2) - (PROJECTILE_WIDTH/2)
        initY = self.y - 5

        local p = Projectile(initX, initY, PROJECTILE_WIDTH, PROJECTILE_HEIGHT, "LR_move", 90)
        table.insert(projectiles, p)
        love.audio.play(p.shoot_sound)
    
    elseif self.state == "static_aim" then
        initX = self:getAimX()
        initY = self:getAimY()

        local p = Projectile(initX, initY, PROJECTILE_WIDTH+5, PROJECTILE_HEIGHT+5, "static_aim", self.aimAngle)
        table.insert(projectiles, p)
        love.audio.play(p.shoot_sound)
    end

    return projectiles
end

function Player:setupAimMode()
    self.startAimX = self.x + (self.width/2) - (PROJECTILE_WIDTH/2)
    self.startAimY = self.y - 10

    self.aimMarker = Projectile(self.startAimX, self.startAimY, PROJECTILE_WIDTH, PROJECTILE_HEIGHT)
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

function Player:updateAimLines(dt)
    self.dx = 0

    if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
        self.aimAngle = math.min(self.aimAngle + 100 * dt, 180)
    elseif love.keyboard.isDown('d') or love.keyboard.isDown('right')  then
        self.aimAngle = math.max(self.aimAngle - 100 * dt, 0)
    end

    self.aimMarker.x = self:getAimX()
    self.aimMarker.y = self:getAimY()
    
    guideX = self.aimMarker.x
    guideY = self.aimMarker.y

    deltaX = 10 * (90-self.aimAngle)/90
    deltaY = -(10 - math.abs(deltaX))

    if #self.aimLines == 0 then
        for i = 1, 150, 1 do
            guideX = guideX + deltaX
            guideY = guideY + deltaY
            
            table.insert(self.aimLines, AimLine(guideX, guideY, PROJECTILE_WIDTH, PROJECTILE_HEIGHT))
        end
    else
        for i = 1, 150, 1 do
            guideX = guideX + deltaX
            guideY = guideY + deltaY
            
            self.aimLines[i]:update(guideX, guideY)
        end
    end
end