local totem = lib.object.create()

totem:include(lib.entity)

totem.config = app.totem.config

totem.state = function()
  return {
    health = app.totem.config.maxHealth,
    isTotem = true,
    lastHurt = -math.huge
  }
end

function totem:bind()
  self.threads = {}

  self.threads.build = function()
    self.building = true
    self.buildStartTime = lib.tick.index
    coroutine.yield(self.config.buildTime)
    self.building = false
    lib.quilt.add(self.threads.attack)
  end

  self.threads.attack = function()
    while true do
      local enemy = self:closest('enemy')
      if enemy and self:distanceTo(enemy) < self.config.range then
        self:attack(enemy)
        coroutine.yield(self.config.attackRate)
      else
        coroutine.yield(.25)
      end
    end
  end

  lib.quilt.add(self.threads.build)

  self:dispose({
    app.context.view.draw
      :subscribe(self:wrap(self.draw)),

    app.context.view.hud
      :subscribe(self:wrap(self.hud))
  })
end

function totem:unbind()
  self.shrine.totem = nil
  lib.quilt.remove(self.threads.build)
  lib.quilt.remove(self.threads.attack)
  lib.object.unbind(self)
end

function totem:draw()
  local x, y = self.position.x, self.position.y
  local w, h = 20, 60

  g.setColor(40, 40, 60)
  g.rectangle('fill', x - w / 2, y - h, w, h)

  local timeSinceLastHurt = (lib.tick.index - self.lastHurt) * lib.tick.rate
  if timeSinceLastHurt < .5 then
    g.rectangle('fill', x - w / 2, y - h, w, h)
    g.setShader(app.shaders.colorize)
    app.shaders.colorize:send('color', {.75, .2, .2, 1 - timeSinceLastHurt / .5})
    g.rectangle('fill', x - w / 2, y - h, w, h)
    g.setShader()
  end

  if not self.building then
    g.white(30)
    g.setLineWidth(2)
    g.circle('line', x, y, self.config.range)
    g.setLineWidth(1)
  end

  return -self.position.y + 10
end

function totem:hud()
  local u, v = g.getDimensions()
  local x, y = app.context.view:screenPoint(self.position.x, self.position.y)

  local percent
  if self.building then
    percent = (((lib.tick.index - self.buildStartTime) * lib.tick.rate) / self.config.buildTime)
  else
    percent = self.health / self.config.maxHealth
  end

  local width = .15 * v
  local height = .02 * v
  g.setColor(0, 0, 0, 100)
  g.rectangle('fill', x - width / 2, y - .15 * v, width, height)

  g.setColor(self.building and {255, 255, 255, 80} or {255, 0, 0, 80})
  g.rectangle('fill', x - width / 2, y - .15 * v, width * percent, height)

  if not self.building then
    local str = self.health
    local font = app.context.hud.font
    g.setFont(font)
    g.setColor(0, 0, 0)
    g.print(str, x - font:getWidth(str) / 2 + 1, y - .15 * v + height / 2 - font:getHeight() / 2 + 1)
    g.white()
    g.print(str, x - font:getWidth(str) / 2, y - .15 * v + height / 2 - font:getHeight() / 2)
  end
end

function totem:attack(enemy)
  enemy:hurt(self.config.damage)
  enemy:push({
    force = 10,
    direction = self:directionTo(enemy)
  })
end

function totem:hurt(amount, source)
  if lib.tick.index - self.lastHurt < .5 / lib.tick.rate then return end
  self.lastHurt = lib.tick.index
  self.health = math.max(self.health - 1, 0)
  if self.health <= 0 then
    app.context.objects[self] = nil
    self:unbind()
  end
end

return totem
