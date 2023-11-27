Stack = Class{}

function Stack:init()
    self.stack = {}
    self.order = 1
end

function Stack:push(item)
    table.insert(self.stack, item)
end

function Stack:pop()
    if #self.stack > 0 then 
        table.remove(self.stack, #self.stack)
    end
end

function Stack:top()
    return self.stack[#self.stack]
end

function Stack:empty()
    return #self.stack == 0
end