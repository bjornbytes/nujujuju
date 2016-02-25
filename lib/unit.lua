local unit = {}

function unit:drawRing(r, gg, b)
  local alpha = self.animation:contains(love.mouse.getPosition()) and 1 or .5

  g.setColor(r, gg, b, alpha * 160)
  g.setLineWidth(3)
  g.ellipse('line', self.position.x, self.position.y, 30, 30 / 2)

  g.white(alpha * 160)
  g.setLineWidth(1)
  g.ellipse('line', self.position.x, self.position.y, 30, 30 / 2)
end

return unit
