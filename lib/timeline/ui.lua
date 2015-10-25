local ui = {}

function ui:toggleActive()
  self.active = not self.active
  lib.flux.to(self, .3, {y = self.active and 0 or -self.config.height}):ease('quartout')
end

function ui:smoothY()
  local targetY = self.active and 0 or -self.config.height
  self.y = math.lerp(self.y, targetY, 16 * lib.tick.rate)
end

function ui:draw()
  local u, v = g.getDimensions()
  local x, y, w, h = self:geometry()
  local time = math.lerp(self.prevTime, self.time, lib.tick.accum / lib.tick.rate)
  local scale = math.lerp(self.prevScale, self.scale, lib.tick.accum / lib.tick.rate)
  local timeline = app.context.timeline

  -- background
  g.setColor(35, 35, 35, 220)
  g.rectangle('fill', x, y, w, h)

  local font = lib.gooey.controller.font
  local min, max = time - scale / 2, time + scale / 2

  -- text markers
  g.setFont(font)
  for i = math.floor(min / 60) * 60, math.ceil(max / 60) * 60, 60 do
    local affine = (i - min) / (max - min)
    local xx = math.lerp(x, x + w, affine)
    if affine >= 0 and affine <= 1 and i > 0 then
      g.setColor(100, 200, 50, 100)
      g.line(xx, y, xx, y + h)
    end

    g.white()
    local val = math.clamp(i, min, max)
    local str = string.format('%02d', math.floor(val / 60)) .. ':' .. string.format('%02d', val % 60)
    local width = font:getWidth(str)
    local pos = math.clamp(xx, x, x + w - font:getWidth(str))
    if xx < x then
      local n = math.ceil(min / 60) * 60
      local affine = (n - min) / (max - min)
      local nx = math.lerp(x, x + w, affine)
      if pos > nx - width - 4 then
        pos = nx - width - 4
      end

      g.white(math.clamp((pos + width - x) / width, 0, 1) * 255)
      g.print(str, pos, y)
    elseif xx > x + w then
      local n = math.floor(max / 60) * 60
      local affine = (n - min) / (max - min)
      local nx = math.lerp(x, x + w, affine)
      if pos < nx + width + 4 then
        pos = nx + width + 4
      end

      g.white((1 - math.clamp((pos - (x + w - width)) / width, 0, 1)) * 255)
      g.print(str, pos, y)
    else
      g.print(str, pos, y)
    end
  end

  -- axis
  g.setColor(100, 200, 50)

  -- tick marks
  g.line(x, y + h / 2, x + w, y + h / 2)
  for i = math.round(min), math.round(max) do
    local affine = (i - min) / (max - min)
    local xx = math.lerp(x, x + w, affine)

    if xx > x and xx < x + w then
      local size

      if scale < 120 then
        size = ((i % 10 == 0) and 6 or 2)
      else
        size = ((i % 10 == 0) and 6 or 0)
      end

      if size > 0 then
        g.line(xx, y + h / 2 - size / 2, xx, y + h / 2 + size / 2)
      end
    end
  end

  -- current time
  local affine = (timeline.time - min) / (max - min)
  if affine >= 0 and affine <= 1 then
    g.setColor(200, 200, 100, 100)
    g.setLineWidth(2)
    local xx = math.lerp(x, x + w, affine)
    g.line(xx, y, xx, y + h)
    g.setLineWidth(1)
  end

  -- events
  for i = 1, #timeline.events do
    local event = timeline.events[i]
    local affine = (event.time - min) / (max - min)
    if affine >= 0 and affine <= 1 then
      g.setColor(255, 100, 100, 100)
      g.setLineWidth(2)
      local xx = math.lerp(x, x + w, affine)
      g.line(xx, y, xx, y + h)
      g.setLineWidth(1)
    end
  end

  return -10000
end

function ui:contains(x, y)
  return math.inside(x, y, self:geometry())
end

function ui:timeAtPosition(px)
  local x, y, w, h = self:geometry()
  local min, max = self.time - self.scale / 2, self.time + self.scale / 2
  return math.lerp(min, max, (px - x) / w)
end

function ui:geometry()
  local u, v = g.getDimensions()
  local inspectorWidth = app.inspector.config.width
  local x = (app.context.inspector.x or 0) + inspectorWidth
  local y = self.y
  local w = u - inspectorWidth - app.context.inspector.x
  local h = self.config.height
  if y > 0 then
    h = h + y
    y = 0
  end
  return x, y, w, h
end

return ui
