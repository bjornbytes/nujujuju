local obstacle = {}

function obstacle:setIsSolid()
  self.isSolid = true
end

function obstacle:setAnchor(x, y)
  self.position.anchor = {
    x = x or self.position.x,
    y = y or self.position.y
  }
end

function obstacle:revertToStartPosition()
  self.position.x = math.lerp(self.position.x, self.position.anchor.x, 16 * lib.tick.rate)
  self.position.y = math.lerp(self.position.y, self.position.anchor.y, 16 * lib.tick.rate)
end

function obstacle:draw()
  g.setColor(255, 255, 255, 120)
  g.drawCenter(app.art.shadow, 70, self.position.anchor.x, self.position.anchor.y, 0, 1, .5)

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
