local context = {}

function context:switch(new, ...)
  if not new then return end

  f.try(self.active and self.active.unload, self.active, new)
  self.active = new

  love.update = new.update
  love.draw = new.draw
  love.quit = new.quit
  setmetatable(love.handlers, {__index = new})

  f.try(new.load, new, ...)
end

return context
