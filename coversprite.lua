CoverSprite = Class{}

function CoverSprite:init(x, y, image)
    self.x = x
    self.y = y

    self.sprite = love.graphics.newImage(image)
end

function CoverSprite:render()
    love.graphics.draw(self.sprite, self.x, self.y)
end