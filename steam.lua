require('stack')
require('timer')
require('utils')

Steam = Class{}

function Steam:init(x, y, image_table)
    self.sprites = {}
    self.spriteStack = Stack()
    
    for _, image in pairs(image_table) do
        local sprite = love.graphics.newImage(image)
        
        table.insert(self.sprites, sprite)
        self.spriteStack:push(sprite)
    end

    self.x = x
    self.y = y

    self.timer = Timer(2)
end

function Steam:render()
    love.graphics.draw(self.spriteStack:top(), self.x, self.y)
end

function Steam:update(dt)
    self.timer:updateElapsedTime(dt)

    if self.timer.elapsedTime >= 0.40 then
        self.timer:resetElapsedTime()
        self.spriteStack:pop()
        
        if self.spriteStack:empty() then    
            randOrder = Utils:shuffleTable(self.sprites)
            self.spriteStack:push(randOrder[1])
            self.spriteStack:push(randOrder[2])
            self.spriteStack:push(randOrder[3])
        end
    end
end