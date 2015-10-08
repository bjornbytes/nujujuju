local button = setmetatable({}, {__index = lib.gooey.component})

getmetatable(button).__call = function()
  return setmetatable({}, {__index = button})
end

function button:activate()
  self.hoverActive = false
  self.hoverFactor = 0
  self.prevHoverFactor = 0
  self.prevHoverFade = 0
  self.hoverX = nil
  self.hoverY = nil
  self.hoverDistance = 0
  self.hoverFade = 0
  self.disabled = false
end

function button:update()
  self.prevHoverFactor = self.hoverFactor
  self.prevHoverFade = self.hoverFade
  if self.hoverActive then
    self.hoverFactor = math.lerp(self.hoverFactor, 1, math.min(8 * lib.tick.rate, 1))
    if self.hoverFactor > .9 then
      self.hoverFade = math.min(self.hoverFade + lib.tick.rate, 1)
    end
  else
    self.hoverFactor = 0
    self.hoverFade = 0
  end
end

function button:mousepressed(mx, my, b)
  if b == 'l' and self:contains(mx, my) and not self.disabled then
    self.gooey.hot = self
  end
end

function button:mousereleased(mx, my, b)
  if b == 'l' and self.gooey.hot == self and self:contains(mx, my) and not self.disabled then
    --self:emit('click')
  end
end

function button:render()
  local x, y, w, h = self.geometry()
  local text = self.text
  local mx, my = self:getMousePosition()
  local hover = self:contains(mx, my)
  local active = hover and love.mouse.isDown('l') and self.gooey.hot == self

  -- button
  g.setColor(255, 255, 255, 40)
  g.rectangle('fill', x, y, w, h)

  local fade = math.lerp(self.prevHoverFade, self.hoverFade, lib.tick.accum / lib.tick.rate)
  g.setColor(0, 0, 0, 200)
  g.setLineWidth(2)
  local xx, yy = x, y
  w, h = math.floor(w), math.floor(h)
  g.line(xx, yy + h, xx + w, yy + h)
  g.line(xx + w, yy, xx + w, yy + h)
  g.setLineWidth(1)

  if hover then
    if not self.hoverActive then
      self.hoverX = mx
      self.hoverY = my
      local d = math.distance
      self.hoverDistance = math.max(d(mx, my, x, y), d(mx, my, x + w, y), d(mx, my, x, y + h), d(mx, my, x + w, y + h))
    end

    g.setColor(255, 255, 255)
    g.setStencil(function()
      g.rectangle('fill', x, y, w, h)
    end)

    local factor = math.lerp(self.prevHoverFactor, self.hoverFactor, lib.tick.accum / lib.tick.rate)
    g.setColor(255, 255, 255, 40 * (1 - fade))
    g.setBlendMode('alpha')
    g.circle('fill', self.hoverX, self.hoverY, factor * self.hoverDistance)
    g.setBlendMode('alpha')

    g.setStencil()

    self.hoverActive = true
  else
    self.hoverActive = false
  end

  -- Text
  if active then y = y + 1 end
  g.setFont(self.gooey.font)
  local textWidth = g.getFont():getWidth(text)
  local textHeight = g.getFont():getHeight()
  g.setColor(0, 0, 0, 100)
  g.print(text, x + w / 2 + 1 - textWidth / 2, y + h / 2 + 1 - textHeight / 2)
  g.setColor(255, 255, 255)
  g.print(text, x + w / 2 - textWidth / 2, y + h / 2 - textHeight / 2)
end

function button:contains(x, y)
  return math.inside(x, y, self.geometry()) and not self.disabled
end

return button
