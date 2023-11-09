Timer = Class{}

function Timer:init(endTime)
    self.elapsedTime = 0
    self.endTime = endTime
end

function Timer:updateElapsedTime(dt)
    self.elapsedTime = self.elapsedTime + dt
end

function Timer:resetElapsedTime()
    self.elapsedTime = 0
end

function Timer:newEndTime(value)
    self.endTime = value
end

