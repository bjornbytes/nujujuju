local slider = setmetatable({}, {__index = lib.gooey.component})

getmetatable(slider).__call = function()
  return setmetatable({}, {__index = slider})
end

function slider:activate()
  self.valueSubject = lib.rx.Subject.create(self.value or 0)
  self.min = self.min or 0
  self.max = self.max or 100
  local decimals = tostring(self.value or 0):match('%.([0-9]+)')
  decimals = decimals and #decimals or 0
  self.round = 10 ^ (decimals)
  self.scale = 1
  self.prevScale = self.scale
  self.factor = self.value or 0
  self.prevFactor = self.factor
  self.hoverFactor = 0
  self.prevHoverFactor = self.hoverFactor
  self.hoverDirty = false
end

function slider:update()
  local mx, my = love.mouse.getPosition()
  local ox, oy = self:getOffset()
  local value = self.valueSubject:getValue()
  mx, my = mx + ox, my + oy

  local hover = (not self.gooey.hot and self:containsBar(mx, my)) or self.gooey.hot == self

  if self.gooey.hot == self then
    local x, y, w, r = self:geometry()
    local percent = math.clamp((mx - x) / w, 0, 1)
    self:setValue(self.min + (self.max - self.min) * percent)
  end

  self.prevFactor = self.factor
  self.factor = math.lerp(self.factor, (value - self.min) / (self.max - self.min), math.min(16 * lib.tick.rate, 1))

  self.prevScale = self.scale
  self.scale = math.lerp(self.scale, (hover or self.gooey.hot == self) and 1.15 or 1, math.min(16 * lib.tick.rate, 1))

  self.prevHoverFactor = self.hoverFactor
  self.hoverFactor = math.lerp(self.hoverFactor, hover and 1 or 0, math.min(16 * lib.tick.rate, 1))

  if hover then
    if not self.hoverDirty then
      self.hoverDirty = true
    end
  else
    self.hoverDirty = false
  end
end

function slider:render()
  local x, y, w, r = self.geometry()

  local factor = math.lerp(self.prevFactor, self.factor, lib.tick.accum / lib.tick.rate)
  local hoverFactor = math.lerp(self.prevHoverFactor, self.hoverFactor, lib.tick.accum / lib.tick.rate)
  local scale = math.lerp(self.prevScale, self.scale, lib.tick.accum / lib.tick.rate)
  local radius = scale * r

  g.setColor(255, 255, 255)
  g.setFont(self.gooey.font)
  g.print(self.label, x, y - self.gooey.font:getHeight())
  g.print(self.valueSubject:getValue(), x + w - self.gooey.font:getWidth(self.valueSubject:getValue()), y - self.gooey.font:getHeight())

  g.setColor(255, 255, 255, 40 + 80 * hoverFactor)
  g.setLineWidth(2)
  g.line(math.round(x) + .5, math.round(y) + .5, x + w, y)
  g.setLineWidth(1)

  g.setColor(30, 30, 30)
  g.circle('fill', x + w * factor, y, radius, 20)
  g.setColor(100, 200, 50, 180 + (75 * hoverFactor))
  g.setLineWidth(2)
  g.circle('line', x + w * factor, y, radius, 20)
  g.setLineWidth(1)
end

function slider:mousepressed(mx, my, b)
  local ox, oy = self:getOffset()
  mx, my = mx + ox, my + oy
  if b == 'l' and self:containsBar(mx, my) then
    self.gooey.hot = self
  end
end

function slider:mousereleased(mx, my, b)
  --
end

function slider:contains(mx, my)
  local x, y, w, r = self:geometry()
  local value = self.valueSubject:getValue()
  local factor = (value - self.min) / (self.max - self.min)
  return math.insideCircle(mx, my, x + w * factor, y, r + 2)
end

function slider:containsBar(mx, my)
  local x, y, w, r = self:geometry()
  r = r * 1.5
  return math.inside(mx, my, x - r, y - r, w + 2 * r, 2 * r)
end

function slider:setValue(value)
  local current = self.valueSubject:getValue()
  local old = currentValue
  local new = math.round(value, self.round)
  if new ~= current then
    self.valueSubject:onNext(new)
  end
end

return slider
