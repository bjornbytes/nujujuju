-- RxLove
-- https://github.com/bjornbytes/RxLove
-- MIT License

local events = {
  'draw',
  'focus',
  'keypressed',
  'keyreleased',
  'mousefocus',
  'mousemoved',
  'mousepressed',
  'mousereleased',
  'quit',
  'resize',
  'textinput',
  'threaderror',
  'update',
  'visible'
}

for _, event in pairs(events) do
  love[event] = lib.rx.Subject.create()
end

getmetatable(love.draw).__call = function(self, ...)
  self.value = {...}

  for i = 1, #self.observers do
    self.observers[i].depth = self.observers[i]:onNext(...) or 0
  end

  table.sort(self.observers, function(a, b)
    return (a.depth or 0) > (b.depth or 0)
  end)
end
