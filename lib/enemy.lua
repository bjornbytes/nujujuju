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
  if (lib.tick.index - self.lastHurt) * lib.tick.rate < self.config.hurtFlash then
    g.setShader(app.shaders.colorize)
    app.shaders.colorize:send('color', {1, 1, 1, .5})
    self.animation:draw(self.position.x, self.position.y)
    g.setShader()
  end

  if app.context.inspector.active then
    g.setLineWidth(2)
    g.white(50)
    g.ellipse('line', self.position.x, self.position.y, self.config.radius, self.config.radius / self.config.perspective, 0, 32)
    g.setLineWidth(1)
  end

  return -self.position.y + 3
end

function enemy:hud()
  local u, v = g.getDimensions()
  local x, y = app.context.view:screenPoint(self.position.x, self.position.y)
  x = math.round(x)
  y = math.round(y)

  local percent
  percent = self.health / self.config.maxHealth

  local width = .1 * v
  local height = .016 * v
  g.setColor(0, 0, 0, 100)
  g.rectangle('fill', x - width / 2, y - .15 * v, width, height)

  g.setColor(255, 0, 0, 80)
  g.rectangle('fill', x - width / 2, y - .15 * v, width * percent, height)

  local str = self.health
  local font = app.context.hud.font
  g.setFont(font)
  g.setColor(0, 0, 0)
  g.print(str, x - font:getWidth(str) / 2 + 1, y - .15 * v + height / 2 - font:getHeight() / 2 + 1)
  g.white(255)
  g.print(str, x - font:getWidth(str) / 2, y - .15 * v + height / 2 - font:getHeight() / 2)

  return -self.position.y
end

function enemy:updatePushes()
  for i = #self.pushes, 1, -1 do
    local push = self.pushes[i]
    local force, direction = push.force, push.direction
    self.position.x = self.position.x + math.cos(direction) * force
    self.position.y = self.position.y + math.sin(direction) * force
    push.force = math.lerp(push.force, 0, 8 * lib.tick.rate)
    if push.force < .1 then
      table.remove(self.pushes, i)
    end
  end
end

function enemy:push(push)
  table.insert(self.pushes, push)
end

function enemy:hurt(amount)
  if self:isDead() then return end
  self.health = self.health - amount
  self.lastHurt = lib.tick.index
  love.timer.sleep(.02)
  if self.health <= 0 then
    self.animation:set('death')
    self.ai:unbind()
    lib.quilt.add(function()
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
