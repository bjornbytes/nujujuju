local slider = setmetatable({}, {__index = lib.component})

getmetatable(slider).__call = function()
  return setmetatable({}, {__index = slider})
end

function slider:activate()
  self.value = lib.rx.Subject.create(self.value or 0)
  self.min = self.min or 0
  self.max = self.max or 100
  self.round = self.round or 10
  self.scale = 1
  self.prevScale = self.scale
  self.factor = self.value
  self.prevFactor = self.factor
  self.hoverFactor = 0
  self.prevHoverFactor = self.hoverFactor
  self.hoverDirty = false
end

function slider:update()
  local mx, my = love.mouse.getPosition()
  local ox, oy = self:getOffset()
  local value = self.value:getValue()
  mx, my = mx + ox, my + oy

  if self.gooey.hot == self then
    local x, y, w, r = self:getsliderGeometry()
    local percent = math.clamp((mx - x) / w, 0, 1)
    self:setValue(self.min + (self.max - self.min) * percent)
  end

  self.prevFactor = self.factor
  self.factor = math.lerp(self.factor, (value - self.min) / (self.max - self.min), math.min(16 * ls.tickrate, 1))

  self.prevScale = self.scale
  self.scale = math.lerp(self.scale, self.gooey.hot == self and 1.15 or 1, math.min(16 * ls.tickrate, 1))

  self.prevHoverFactor = self.hoverFactor
  local hover = (not self.gooey.hot and self:containsBar(mx, my)) or self.gooey.hot == self
  self.hoverFactor = math.lerp(self.prevHoverFactor, hover and 1 or 0, math.min(16 * ls.tickrate, 1))

  if hover then
    if not self.hoverDirty then
      ctx.sound:play('juju1', function(sound) sound:setPitch(.75) end)
      self.hoverDirty = true
    end
  else
    self.hoverDirty = false
  end
end

function slider:render()
  local u, v = ctx.u, ctx.v
  local x, y, w, r = unpack(self.geometry())

  local factor = math.lerp(self.prevFactor, self.factor, ls.accum / ls.tickrate)
  local hoverFactor = math.lerp(self.prevHoverFactor, self.hoverFactor, ls.accum / ls.tickrate)
  local scale = math.lerp(self.prevScale, self.scale, ls.accum / ls.tickrate)
  local radius = scale * r

  g.setFont('mesmerize', r * 1.4)
  g.setColor(255, 255, 255, 180 + 75 * hoverFactor)
  g.print(self.label, x - r, y - g.getFont():getHeight() / 2)

  x = x + math.max(u * .08, g.getFont():getWidth(self.label))

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
  local x, y, w, r = self:getsliderGeometry()
  local value = self.value:getValue()
  local factor = (value - self.min) / (self.max - self.min)
  return math.insideCircle(mx, my, x + w * factor, y, r)
end

function slider:containsBar(mx, my)
  local x, y, w, r = self:getsliderGeometry()
  r = r * 1.5
  return math.inside(mx, my, x - r, y - r, w + 2 * r, 2 * r)
end

function slider:setValue(value)
  local current = self.value:getValue()
  local old = currentValue
  local new = math.round(value, self.round)
  if new ~= current then
    self.value:onNext(new)
  end
end

function slider:getSliderGeometry()
  local u, v = ctx.u, ctx.v
  local x, y, w, r = unpack(self.geometry())
  local font = g.setFont('mesmerize', r * 1.4)
  g.print(self.label, x, y - font:getHeight() / 2)
  x = x + math.max(u * .08, font:getWidth(self.label))
  return x, y, w, r
end
