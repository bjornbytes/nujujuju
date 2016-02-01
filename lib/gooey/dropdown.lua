local dropdown = setmetatable({}, {__index = lib.gooey.component})

getmetatable(dropdown).__call = function()
  return setmetatable({}, {__index = dropdown})
end

function dropdown:activate()
  self.value = lib.rx.Subject.create(self.value)
  self.choices = self.choices or {}
  self.factor = 0
  self.prevFactor = self.factor
  self.hoverFactor = 0
  self.prevHoverFactor = self.hoverFactor
  self.choiceHoverFactors = {}
  self.prevChoiceHoverFactors = {}
  self.hoverDirty = false
  self.padding = self.padding or 0
end

function dropdown:update()
  local mx, my = love.mouse.getPosition()
  local ox, oy = self:getOffset()
  mx, my = mx + ox, my + oy
  local hover = self:contains(mx, my)
  self.prevFactor = self.factor
  self.prevHoverFactor = self.hoverFactor
  self.factor = math.lerp(self.factor, self:focused() and 1 or 0, math.min(16 * lib.tick.rate, 1))
  self.hoverFactor = math.lerp(self.hoverFactor, (self:focused() or hover) and 1 or 0, math.min(16 * lib.tick.rate, 1))
  if self:focused() then
    local hoverIndex = self:contains(mx, my)
    local hoverAmount = 1 + (love.mouse.isDown(1) and .5 or 0)
    for i = 1, #self.choices do
      self.prevChoiceHoverFactors[i] = self.choiceHoverFactors[i] or 0
      self.choiceHoverFactors[i] = math.lerp(self.prevChoiceHoverFactors[i], i == hoverIndex and hoverAmount or 0, math.min(16 * lib.tick.rate, 1))
    end

    if hover then
      if self.hoverDirty ~= hoverIndex and hoverIndex ~= 0 and (not self.gooey.focused or self.gooey.focused == self) then
        self.hoverDirty = hoverIndex
      end
    else
      self.hoverDirty = false
    end
  end

  if hover then
    if not self.hoverDirty and (not self.gooey.focused or self.gooey.focused == self) then
      self.hoverDirty = true
    end
  else
    self.hoverDirty = false
  end
end

function dropdown:render()
  local x, y, w, h = self.geometry()
  local mx, my = love.mouse.getPosition()
  local ox, oy = self:getOffset()
  mx, my = mx + ox, my + oy
  local hoverIndex = self:contains(mx, my)
  local choiceHoverFactors = table.interpolate(self.prevChoiceHoverFactors, self.choiceHoverFactors, lib.tick.accum / lib.tick.rate)
  local hoverFactor = math.lerp(self.prevHoverFactor, self.hoverFactor, lib.tick.accum / lib.tick.rate)
  local factor = math.lerp(self.prevFactor, self.factor, lib.tick.accum / lib.tick.rate)
  local dropdownHeight = self:getdropdownHeight() * factor
  local font = g.setFont(self.gooey.font)
  local value = self.value:getValue()

  g.white(40 + (20 * hoverFactor))
  g.rectangle('fill', x, y, w, h)

  g.setColor(0, 0, 0, 255 * factor)
  g.rectangle('fill', x, y + h, w, dropdownHeight)

  if hoverIndex and hoverIndex > 0 then
    g.white(30 * choiceHoverFactors[hoverIndex])
    g.rectangle('fill', x, y + h * hoverIndex, w, h)
  end

  --[[g.white()
  g.rectangle('line', lume.round(x) + .5, lume.round(y) + .5, w, h)]]

  for i = 1, #self.choices do
    local factor = factor
    local hoverFactor = 0
    if self:focused() then
      local prev = self:getdropdownHeight() * (i - 1) / #self.choices
      factor = math.clamp((dropdownHeight - prev) / h, 0, 1) ^ 4
      hoverFactor = choiceHoverFactors[i]
    end
    local alpha = math.min(180 * factor + (75 * hoverFactor), 255)
    if self.choices[i] == value then g.setColor(100, 200, 50, 255 * factor)
    else g.setColor(220, 220, 220, alpha) end
    g.print(self.choices[i], x + self.padding, y + h * i + self.padding)
  end

  g.setColor(255, 255, 255)
  g.print(self.label, x + self.padding, y + self.padding)

  g.setColor(100, 200, 50, 255)
  g.print(value, x + w - self.padding - g.getFont():getWidth(value), y + self.padding)
end

function dropdown:mousepressed(mx, my, b)
  local ox, oy = self:getOffset()
  mx, my = mx + ox, my + oy
  if b == 1 and self:contains(mx, my) then
    self.gooey.hot = self
    if self:focused() then return true end
  end
end

function dropdown:mousereleased(mx, my, b)
  local ox, oy = self:getOffset()
  mx, my = mx + ox, my + oy

  if b == 1 then
    if not self:focused() then
      if self.gooey.hot == self and self:contains(mx, my) then
        self.gooey:focus(self)
      end
    else
      local hit = self.gooey.hot == self and self:contains(mx, my)

      self.gooey:unfocus()
      if hit then
        if self.choices[hit] then
          self.value:onNext(self.choices[hit])
        end
        return true
      end
    end
  end
end

function dropdown:contains(mx, my)
  local x, y, w, h = self.geometry()
  if math.inside(mx, my, x, y, w, h) then return 0 end

  if self:focused() then
    for i = 1, #self.choices do
      if math.inside(mx, my, x, y + h * i, w, h) then
        return i
      end
    end
  end

  return false
end

function dropdown:getdropdownHeight()
  local x, y, w, h = self.geometry()
  return h * (#self.choices)
end

return dropdown
