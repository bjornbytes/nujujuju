local enemy = {}

function enemy:draw()
  local image = app.art.shadow
  local scale = 70 / image:getWidth()
  g.setColor(255, 255, 255, 120)
  g.draw(image, self.position.x, self.position.y, 0, scale, scale / 2, image:getWidth() / 2, image:getHeight() / 2)

  g.setColor(255, 255, 255)
  self.animation:tick(lib.tick.delta)
  self.animation:draw(self.position.x, self.position.y)

  if app.context.inspector.active then
    g.setLineWidth(2)
    g.setColor(255, 255, 255, 50)
    g.ellipse('line', self.position.x, self.position.y, self.config.radius, self.config.radius / self.config.perspective, 0, 32)
  end

  return -self.position.y + 3
end

function enemy:drawUI(u, v)
  local x, y = app.context.view:screenPoint(self.position.x, self.position.y)
  local font = app.context.hud.font
  local str = self.health
  g.setColor(0, 0, 0)
  g.print(str, x - font:getWidth(str) / 2 + 1, y - .1 * v - font:getHeight() + 1)
  g.setColor(255, 255, 255)
  g.print(str, x - font:getWidth(str) / 2, y - .1 * v - font:getHeight())
end

function enemy:updatePushes()
  for i = #self.pushes, 1, -1 do
    local push = self.pushes[i]
    local force, direction = push.force, push.direction
    self.position.x = self.position.x + math.cos(direction) * force
    self.position.y = self.position.y + math.sin(direction) * force
    push.force = math.lerp(push.force, 0, 16 * lib.tick.rate)
    if push.force < 1 then
      table.remove(self.pushes, i)
    end
  end
end

function enemy:push(push)
  table.insert(self.pushes, push)
end

function enemy:hurt(amount)
  self.health = self.health - amount
  if self.health <= 0 then
    self:unbind()
  end
end

return enemy
