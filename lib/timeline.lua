local timeline = {}

function timeline:toggleActive()
  self.active = not self.active
  lib.flux.to(self, .3, {y = self.active and 0 or -self.config.height}):ease('quartout')
end

function timeline:smoothY()
  local targetY = self.active and 0 or -self.config.height
  self.y = math.lerp(self.y, targetY, 16 * lib.tick.rate)
end

function timeline:draw()
  local u, v = g.getDimensions()
  local y = self.y
  local height = self.config.height
  if y > 0 then
    height = height + y
    y = 0
  end

  g.setColor(35, 35, 35, 220)
  g.rectangle('fill', app.inspector.config.width, y, u - app.inspector.config.width, height)
  return -10000
end

return timeline
