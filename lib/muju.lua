local muju = {}

function muju:animate()
  self.animation:tick(lib.tick.rate)
end

function muju:jujuTrickle()
  self.jujuTrickleTimer = math.max(self.jujuTrickleTimer - lib.tick.rate, 0)
  if self.jujuTrickleTimer == 0 then
    self.jujuTrickleTimer = self.config.jujuTrickleRate
    self.juju = math.min(self.juju + 1, self.config.maxJuju)
    self.totalJuju = self.totalJuju + 1
  end
end

function muju:tint(r, g, b)
  for _, slot in pairs({'robebottom', 'torso', 'front_upper_arm', 'rear_upper_arm', 'front_bracer', 'rear_bracer'}) do
    local slot = self.animation.skeleton:findSlot(slot)
    slot.r, slot.g, slot.b = r, g, b
  end
end

function muju:hurt(amount)
  if self.dead or lib.tick.index - self.lastHurt < self.config.hurtGrace / lib.tick.rate then return end
  self.health = math.max(self.health - amount, 0)
  app.context.view:screenshake(.1)
  if self.health == 0 then
    self.dead = true
    lib.quilt.add(function()
      self.animation:set('death')
      lib.tick.scale = .4
      coroutine.yield(1)
      lib.flux.to(lib.tick, 1, {scale = 1})
      coroutine.yield(1)
      lib.flux.to(app.context.hud, 1, {fadeout = 1})
      coroutine.yield(1)
      app.context.unload()
      app.context.load('overgrowth')
    end)
  else
    self.lastHurt = lib.tick.index
  end
end

function muju:spendJuju(amount)
  self.juju = self.juju - amount
end

function muju:draw()
  local image = app.environment.art.stump
  local scale = 60 / image:getWidth()

  g.white()
  g.draw(image, self.position.x, self.position.y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

  self.animation:draw(self.position.x, self.position.y)

  if app.context.inspector.active then
    g.setLineWidth(3)
    g.white(30)
    g.circle('line', self.position.x, self.position.y, self.config.radius, 64)
    g.setLineWidth(1)
  end

  if self.squishFactor > 0 then
    local points = {}
    local radius = 30
    local mx, my = love.mouse.getPosition()
    local dir = util.angle(self.position.x, self.position.y, mx, my)
    local pointCount = 80

    for i = 1, 80 do
      if self.squishFactor == 0 then
      end

      local x = mx + util.dx(radius, dir + (2 * math.pi * (i / 80)))
      local y = my + util.dy(radius, dir + (2 * math.pi * (i / 80)))
      local max = math.pi / 2 + (math.pi / 2) * util.distance(self.position.x, self.position.y, mx, my) / 500 -- how bulbous it is
      local dif = (max - util.clamp(math.abs(util.anglediff(util.angle(mx, my, x, y), dir + math.pi)), 0, max)) / max
      x = util.lerp(self.position.x, x, self.squishFactor)
      y = util.lerp(self.position.y, y, self.squishFactor)
      x = util.lerp(x, self.position.x, dif ^ 5)
      y = util.lerp(y, self.position.y, dif ^ 5)

      table.insert(points, x)
      table.insert(points, y)
    end

    g.white(40)
    g.polygon('fill', points)
  end

  return -self.position.y
end

return muju
