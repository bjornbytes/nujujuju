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
  g.setColor(255, 255, 255, 180 + (75 * hoverFactor))
  g.print(self.label, x, y)

  g.setColor(100, 200, 50)
  g.print(self.value, x + w - g.getFont():getWidth(self.value), y)

  if errorFactor > 0 then
    g.setColor(255, 100, 100, math.min(errorFactor, 1) * 255)
    local y = y + g.getFont():getHeight() + .5
    g.line(x, y, x + w, y)
  elseif focusFactor * w > 1 then
    g.setColor(255, 255, 255, 200)
    local y = y + g.getFont():getHeight() + .5
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
      end

      if not pcall(try) then
        self.errorFactor = 8
        self.value = old
        self.valueSubject:onNext(old)
      end
    end
    self.gooey:unfocus()
    love.keyboard:setKeyRepeat(false)
  elseif key == 'backspace' and self:focused() then
    self.value = self.value:sub(1, -2)
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

return editor
