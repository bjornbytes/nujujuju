local puju = {}

function puju:idle()
  self.target = self:closest('minion', 'player')

  if self.target then
    self.state = 'move'
  end
end

function puju:move()
  if self.target and self.target.isMinion and self.target.dead then
    self.state = 'idle'
    self.target = nil
    return
  end

  self.target = self:closest('minion', 'player')

  self.direction = -self:signTo(self.target)

  local distance = self:distanceTo(self.target)
  local angle = self:directionTo(self.target)
  local speed = math.min(self.config.speed * lib.tick.rate, distance)
  local targetVelocityX = math.cos(angle) * self.config.speed * lib.tick.rate
  local targetVelocityY = math.sin(angle) * self.config.speed * lib.tick.rate
  local distanceFactor = util.clamp((distance - self.config.range) / (self.config.range / 4), 0, 1)

  self.velocity.x = util.lerp(self.velocity.x, targetVelocityX * distanceFactor, lib.tick.getLerpFactor(self.config.acceleration))
  self.velocity.y = util.lerp(self.velocity.y, targetVelocityY * distanceFactor, lib.tick.getLerpFactor(self.config.acceleration))

  if self:isInRangeOf(self.target) and love.math.random() < lib.tick.rate * 2 then
    self.state = 'attack'
  end
end

function puju:attack()
  self.attackThread = self.attackThread or lib.quilt.add(function()
    self.attackDirection = self:directionTo(self.target)

    self.chargeStart = lib.tick.index

    coroutine.yield(self.config.chargeTime)

    self.chargeStart = nil

    app.context:addObject(app.spells.seed, {
      position = util.copy(self.position),
      direction = self.attackDirection,
      owner = self
    })

    self.velocity.x = util.dx(self.config.recoil, self.attackDirection + math.pi)
    self.velocity.y = util.dy(self.config.recoil, self.attackDirection + math.pi)

    coroutine.yield(self.config.attackCooldown)

    self.state = 'idle'
    self.attackDirection = nil
    self.attackThread = nil
  end)

  self.velocity.x = util.lerp(self.velocity.x, 0, lib.tick.getLerpFactor(self.config.acceleration))
  self.velocity.y = util.lerp(self.velocity.y, 0, lib.tick.getLerpFactor(self.config.acceleration))
end

function puju:drift()
  self.velocity.x = self.velocity.x + math.sin((self.floatOffset + lib.tick.index) * lib.tick.rate * 2) * lib.tick.rate
  self.velocity.y = self.velocity.y + math.cos((self.floatOffset + lib.tick.index) * lib.tick.rate * 2) * lib.tick.rate

  self.position.x = self.position.x + self.velocity.x
  self.position.y = self.position.y + self.velocity.y

  local yank = util.clamp(self.velocity.x / (self.config.speed * lib.tick.rate), -1, 1)
  self.yank = util.lerp(self.yank, yank, lib.tick.getLerpFactor(.02))
end

function puju:draw()
  local baseScale = self.chargeStart and 1 + ((lib.tick.index - self.chargeStart) * lib.tick.rate / self.config.chargeTime) * .5 or 1
  local image = app.art.shadow
  local offset = math.sin(lib.tick.index * lib.tick.rate * 3) * 4
  local scale = g.imageScale(image, (70 + offset) * baseScale)

  g.white(70 * self.alpha)
  g.draw(image, self.position.x, self.position.y, 0, scale, scale / 1.5, image:getWidth() / 2, image:getHeight() / 2)

  self:drawRing(255, 40, 40)

  local image = app.art.puju
  local scale = g.imageScale(image, 35 * baseScale)

  g.white(self.alpha * 255)
  g.draw(image, self.position.x, self.position.y - 20 + offset - image:getHeight() * scale, self.yank * .4, scale * self.direction, scale, image:getWidth() / 2, 0)

  return -self.position.y
end

function puju:die()
  if self.attackThread then
    lib.quilt.remove(self.attackThread)
  end

  if self.dead then return end

  self.dead = true

  lib.flux.to(self, .4, { alpha = 0 }):ease('cubicout'):oncomplete(function()
    self:remove()
  end)
end

return puju
