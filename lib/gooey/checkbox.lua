local checkbox = setmetatable({}, {__index = lib.gooey.component})

getmetatable(checkbox).__call = function()
  return setmetatable({}, {__index = checkbox})
end

function checkbox:activate()
  self.value = self.value == nil and false or self.value
  self.scale = 1
  self.prevScale = self.scale
  self.factor = 0
  self.prevFactor = self.factor
  self.hoverDirty = false
end

function checkbox:update()
  self.prevScale = self.scale
  self.prevFactor = self.factor

  local mx, my = love.mouse.getPosition()
  local ox, oy = self:getOffset()
  mx, my = mx + ox, my + oy

  local hover = self:contains(mx, my)
  self.scale = math.lerp(self.scale, hover and 1.15 or 1, math.min(16 * lib.tick.rate, 1))

  self.factor = math.lerp(self.factor, self.value and 1 or 0, math.min(16 * lib.tick.rate, 1))

  if self:contains(mx, my) then
    if not self.hoverDirty and not self.gooey.focused then
      self.hoverDirty = true
    end
  else
    self.hoverDirty = false
  end
end

function checkbox:render()
  local x, y, r = self.geometry()

  local factor = math.lerp(self.prevFactor, self.factor, lib.tick.accum / lib.tick.rate)
  local scale = math.lerp(self.prevScale, self.scale, lib.tick.accum / lib.tick.rate)
  local radius = scale * r

  if self.value then g.setColor(0, 0, 0, 200)
  else g.setColor(0, 0, 0, 100) end
  g.circle('fill', x, y, radius, 20)

  g.white(80 + (self.value and 170 or 0))
  if self.value then g.setColor(100, 200, 50) end
  g.setLineWidth(2) -- vary this based on size or antialias it
  g.circle('line', x, y, radius, 40)
  g.setLineWidth(1)

  g.setFont(self.gooey.font)
  g.white(180 + (75 * factor))
  g.print(self.label, x + r + self.padding, y - g.getFont():getHeight() / 2)
end

function checkbox:mousereleased(mx, my, b)
  local ox, oy = self:getOffset()
  mx, my = mx + ox, my + oy
  if b == 'l' and self:contains(mx, my) and not self.gooey.focused then
    self:toggle()
  end
end

function checkbox:toggle()
  self.value = not self.value
  self.scale = self.value and 1.4 or .9
  --self:emit('change', {component = self})
end

function checkbox:contains(mx, my)
  local x, y, r = self.geometry()
  local font = self.gooey.font
  local x1 = x - r
  local y1 = y - r
  local str = self.label
  return math.inside(mx, my, x1, y1, r + r + 1.4 * r + font:getWidth(str), math.max(font:getHeight(), 2 * r))
end

return checkbox
