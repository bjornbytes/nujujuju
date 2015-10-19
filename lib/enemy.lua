local enemy = {}

function enemy:setIsEnemy()
  self.isEnemy = true
end

function enemy:draw()
  local image = app.art.shadow
  local scale = 70 / image:getWidth()
  g.white(120)
  g.draw(image, self.position.x, self.position.y, 0, scale, scale / 2, image:getWidth() / 2, image:getHeight() / 2)

  g.white()
  self.animation:tick(lib.tick.delta)
  self.animation:draw(self.position.x, self.position.y)

  if app.context.inspector.active then
    g.setLineWidth(2)
    g.white(50)
    g.ellipse('line', self.position.x, self.position.y, self.config.radius, self.config.radius / self.config.perspective, 0, 32)
    g.setLineWidth(1)
  end

  return -self.position.y + 3
end

function enemy:drawUI(u, v)
  local x, y = app.context.view:screenPoint(self.position.x, self.position.y)
  local font = app.context.hud.font
  local str = self.health
  g.setColor(0, 0, 0)
  g.print(str, x - font:getWidth(str) / 2 + 1, y - .1 * v - font:getHeight() + 1)
  g.white()
  g.print(str, x - font:getWidth(str) / 2, y - .1 * v - font:getHeight())
end

function enemy:updatePushes()
  if self:isDead() then return end
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
  if self:isDead() then return end
  table.insert(self.pushes, push)
end

function enemy:hurt(amount)
  if self:isDead() then return end
  self.health = self.health - amount
  if self.health <= 0 then
    lib.quilt.add(function()
      self.ai:unbind()
      self.animation:set('death')
      coroutine.yield(1)
      self:unbind()
    end)
  end
end

function enemy:attack()
  self.animation:set('attack')
end

function enemy:isDead()
  return self.animation.states.death.active
end

return enemy
