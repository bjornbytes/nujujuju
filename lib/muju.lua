local muju = {}

function muju:jujuTrickle()
  self.jujuTrickleTimer = math.max(self.jujuTrickleTimer - lib.tick.rate, 0)
  if self.jujuTrickleTimer == 0 then
    self.jujuTrickleTimer = self.config.jujuTrickleRate
    self.juju = math.min(self.juju + 1, self.maxJuju)
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
  if self.dead then return end

  self.health = math.max(self.health - amount, 0)
  app.context.view:screenshake(.1)

  if self.health == 0 then
    self.dead = true
    app.context:unload()
    app.context.load('overgrowth')
  end
end

function muju:addJuju(amount)
  self.juju = self.juju + amount
  self.totalJuju = self.totalJuju + amount
end

function muju:spendJuju(amount)
  self.juju = self.juju - amount
end

function muju:draw()
  local image = app.environment.art.stump
  local scale = 60 / image:getWidth()

  self:drawRing(128, 0, 255)

  g.white()
  g.draw(image, self.position.x, self.position.y - 10, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

  self.animation:tick(lib.tick.delta)
  self.animation:draw(self.position.x, self.position.y)

  if app.context.inspector.active then
    g.setLineWidth(3)
    g.white(30)
    g.circle('line', self.position.x, self.position.y, self.config.radius, 64)
    g.setLineWidth(1)
  end

  return -self.position.y
end

return muju
