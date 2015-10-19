local editor = setmetatable({}, {__index = lib.gooey.component})

getmetatable(editor).__call = function()
  return setmetatable({}, {__index = editor})
end

function editor:activate()
  self.hoverFactor = 0
  self.prevHoverFactor = self.hoverFactor
  self.valueSubject = lib.rx.Subject.create()
  self.focusFactor = 0
  self.prevFocusFactor = self.focusFactor
  self.errorFactor = 0
  self.prevErrorFactor = self.errorFactor

  if tonumber(self.value) then
    local decimals = tostring(self.value):match('%.([0-9]+)')
    decimals = decimals and #decimals or 0
    self.precision = 1 / 10 ^ (decimals)
  end
end

function editor:update()
  self.prevHoverFactor = self.hoverFactor
  self.prevFocusFactor = self.focusFactor
  self.prevErrorFactor = self.errorFactor

  local mx, my = love.mouse.getPosition()

  local hover = self:contains(mx, my)
  self.hoverFactor = math.lerp(self.hoverFactor, hover and 1 or 0, math.min(16 * lib.tick.rate, 1))
  self.focusFactor = math.lerp(self.focusFactor, self:focused() and 1 or 0, math.min(16 * lib.tick.rate, 1))
  self.errorFactor = math.lerp(self.errorFactor, 0, math.min(16 * lib.tick.rate, 1))
end

function editor:render()
  local x, y, w = self.geometry()

  local hoverFactor = math.lerp(self.prevHoverFactor, self.hoverFactor, lib.tick.accum / lib.tick.rate)
  local focusFactor = math.lerp(self.prevFocusFactor, self.focusFactor, lib.tick.accum / lib.tick.rate)
  local errorFactor = math.lerp(self.prevErrorFactor, self.errorFactor, lib.tick.accum / lib.tick.rate)

  x = x + math.round(4 * hoverFactor)

  g.setFont(self.gooey.font)
  g.white(180 + (75 * hoverFactor))
  g.print(self.label, x, y)

  g.setColor(100, 200, 50)
  g.print(self.value, x + w - g.getFont():getWidth(self.value), y)

  if self.value == '' then
    g.white(80)
    g.print(self.valueSubject:getValue(), x + w - g.getFont():getWidth(self.valueSubject:getValue()), y)
  end

  g.setLineWidth(1)
  if errorFactor > .01 then
    g.setColor(255, 100, 100, math.min(errorFactor, 1) * 255)
    local y = math.round(y + g.getFont():getHeight()) + .5
    g.line(x, y, x + w, y)
  elseif focusFactor * w > 1 then
    g.white(200)
    local y = math.round(y + g.getFont():getHeight()) + .5
    g.line(x, y, x + w * focusFactor, y)
  end
end

function editor:keypressed(key)
  if key == 'return' then
    if self:focused() then
      local old = self.valueSubject:getValue()

      local try = function()
        self.valueSubject:onNext(self.value)
        love.update()
        love.draw()
      end

      if self.value == '' or not pcall(try) then
        self.errorFactor = 8
        self.value = old
        self.valueSubject:onNext(old)
      end
    end
    self.gooey:unfocus()
    love.keyboard:setKeyRepeat(false)
  elseif key == 'backspace' and self:focused() then
    self.value = self.value:sub(1, -2)
  elseif (key == 'up' or key == 'down') and not self:focused() and self:contains(love.mouse.getPosition()) then
    self:increment(key == 'up' and 1 or -1)
  end
end

function editor:keyreleased(key)
  if not self:focused() and (key == 'up' or key == 'down') then
    love.keyboard.setKeyRepeat(false)
  end
end

function editor:textinput(char)
  if self:focused() then
    self.value = self.value .. char
  end
end

function editor:mousepressed(mx, my, b)
  if b == 'l' and self:contains(mx, my) then
    self.gooey.hot = self
    if self:focused() then return true end
  elseif (b == 'wu' or b == 'wd') and not self:focused() and self:contains(mx, my) then
    self:increment(b == 'wu' and 1 or -1)
  end
end

function editor:mousereleased(mx, my, b)
  if b == 'l' then
    if not self:focused() then
      if self.gooey.hot == self and self:contains(mx, my) then
        self.gooey:focus(self)
        love.keyboard:setKeyRepeat(true)
        self.value = ''
      end
    else
      love.keyboard:setKeyRepeat(false)
      self.gooey:unfocus()
      self.value = self.valueSubject:getValue()
    end
  end
end

function editor:contains(mx, my)
  local x, y, w = self.geometry()
  local font = self.gooey.font
  local x1 = x
  local y1 = y
  local str = self.label
  return math.inside(mx, my, x1, y1, w, font:getHeight())
end

function editor:increment(sign)
  self.value = self.value + self.precision * sign
  self.valueSubject:onNext(self.value)
  love.keyboard.setKeyRepeat(true)
end

return editor
