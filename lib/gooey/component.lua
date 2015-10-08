local component = {}

function component:draw()
  self.gooey:draw(self)
end

function component:focused()
  return self.gooey.focused == self
end

function component:getOffset(x, y)
  return 0, 0
end

function component:getMousePosition()
  return love.mouse.getPosition()
end

return component
