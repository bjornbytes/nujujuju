local obstacle = {}

function obstacle:setSolid()
  self.solid = true
end

function obstacle:setStartPosition()
  self.position.initial = {
    x = self.position.x,
    y = self.position.y
  }
end

function obstacle:revertToStartPosition()
  self.position.x = math.lerp(self.position.x, self.position.initial.x, 16 * lib.tick.rate)
  self.position.y = math.lerp(self.position.y, self.position.initial.y, 16 * lib.tick.rate)
end

function obstacle:draw()
  g.setColor(255, 255, 255, 120)
  g.drawCenter(app.art.shadow, 70, self.position.initial.x, self.position.initial.y, 0, 1, .5)

  g.setColor(255, 255, 255)
  g.drawCenter(self.image, self.config.size, self.position.x, self.position.y)

  if app.context.inspector.active then
    g.setLineWidth(2)
    g.setColor(255, 255, 255, 50)
    g.ellipse('line', self.position.x, self.position.y, self.config.radius, self.config.radius / self.config.perspective, 0, 32)
  end

  return -self.position.y
end

return obstacle
