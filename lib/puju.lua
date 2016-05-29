local puju = {}

function puju:idle()
  self.target = self:closest('minion', 'shruju')

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

  self.target = self:closest('minion', 'shruju')

  if self.target then
    sign = self:signTo(self.target)
  else
    sign = util.sign(self.destination.x - self.position.x)
  end

  if sign ~= 0 then
    self.animation.flipped = sign > 0
  end

  local distance = self:distanceTo(self.target)
  local angle = self:directionTo(self.target)
  local targetVelocityX = math.cos(angle) * self.config.speed * lib.tick.rate
  local targetVelocityY = math.sin(angle) * self.config.speed * lib.tick.rate

  if self.target.isShruju then
    self.velocity.x = util.lerp(self.velocity.x, targetVelocityX, lib.tick.getLerpFactor(self.config.acceleration))
    self.velocity.y = util.lerp(self.velocity.y, targetVelocityY, lib.tick.getLerpFactor(self.config.acceleration))

    if self:isCarryingShruju(self.target) then
      self.state = 'run'
    end

    if self:distanceTo(self.target) <= self.config.radius + self.target.config.radius then
      if self:pickupShruju(self.target) then
        self.state = 'run'
      end
    end

    return
  end

  local distanceFactor = util.clamp((distance - self.config.range) / (self.config.range / 4), 0, 1)
  self.velocity.x = util.lerp(self.velocity.x, targetVelocityX, lib.tick.getLerpFactor(self.config.acceleration))
  self.velocity.y = util.lerp(self.velocity.y, targetVelocityY, lib.tick.getLerpFactor(self.config.acceleration))

  if self:isInRangeOf(self.target) and love.math.random() < lib.tick.rate * 2 and not self.target.isShruju then
    self.state = 'attack'
  end
end

function puju:attack()
  self.attackThread = self.attackThread or lib.quilt.add(function()
    self.attackDirection = self:directionTo(self.target)

    self.chargeStart = lib.tick.index

    self.animation:set('mouthsuck')

    coroutine.yield(self.config.chargeTime)

    self.animation:set('mouthblow')

    self.chargeStart = nil

    app.context:addObject(app.spells.seed, {
      position = util.copy(self.position),
      direction = self.attackDirection,
      owner = self
    })

    self.velocity.x = util.dx(self.config.recoil, self.attackDirection + math.pi)
    self.velocity.y = util.dy(self.config.recoil, self.attackDirection + math.pi)

    self.yank = -self.velocity.x / 2

    coroutine.yield(self.config.attackCooldown)

    self.state = 'idle'
    self.attackDirection = nil
    self.attackThread = nil
  end)

  self.velocity.x = util.lerp(self.velocity.x, 0, lib.tick.getLerpFactor(self.config.acceleration))
  self.velocity.y = util.lerp(self.velocity.y, 0, lib.tick.getLerpFactor(self.config.acceleration))
end

function puju:run()
  local targetX, targetY

  if self.position.x < app.context.scene.width / 2 then
    targetX = 0
    targetY = app.context.scene.height / 2
  else
    targetX = app.context.scene.width
    targetY = app.context.scene.height / 2
  end

  local distance = self:distanceToPoint(targetX, targetY)
  local angle = self:directionToPoint(targetX, targetY)
  local velocityX = math.cos(angle) * self.config.speed / 2 * lib.tick.rate
  local velocityY = math.sin(angle) * self.config.speed / 2 * lib.tick.rate

  self.velocity.x = util.lerp(self.velocity.x, velocityX, lib.tick.getLerpFactor(self.config.acceleration))
  self.velocity.y = util.lerp(self.velocity.y, velocityY, lib.tick.getLerpFactor(self.config.acceleration))

  if distance < 50 then
    print('HA')
    app.context:removeObject(self.target)
    self.target:unbind()
    self.state = 'idle'
  end
end

function puju:isHovered(x, y)
  local hoverAllowanceFactor = 1.5
  local dis = util.distance(self.position.x, self.position.y, x, y)
  local dir = util.angle(self.position.x, self.position.y, x, y)
  local ellipseHover = dis < self.config.radius * hoverAllowanceFactor / (2 - math.abs(math.cos(dir)))

  local image = app.art.puju
  local baseScale = self:getBaseScale()
  local scale = g.imageScale(image, 35 * baseScale)
  local width, height = self.config.radius * 2, image:getHeight() * scale
  local offset = math.sin(lib.tick.index * lib.tick.rate * 3) * 4
  local x1 = self.position.x - width / 2
  local y1 = self.position.y - 20 + offset - height
  local mouseHover = util.inside(x, y, x1, y1, width, height)

  return self:isTargetable() and (mouseHover or ellipseHover)
end

function puju:drift()
  self.velocity.x = self.velocity.x + math.sin((self.floatOffset + lib.tick.index) * lib.tick.rate * 2) * lib.tick.rate
  self.velocity.y = self.velocity.y + math.cos((self.floatOffset + lib.tick.index) * lib.tick.rate * 2) * lib.tick.rate

  self.position.x = self.position.x + self.velocity.x
  self.position.y = self.position.y + self.velocity.y

  local yank = util.clamp(self.velocity.x / (self.config.speed * lib.tick.rate), -1, 1)
  self.yank = util.lerp(self.yank, yank, lib.tick.getLerpFactor(.02))
end

function puju:getBaseScale()
  return self.chargeStart and 1 + ((lib.tick.index - self.chargeStart) * lib.tick.rate / self.config.chargeTime) * .5 or 1
end

function puju:draw()
  local baseScale = self:getBaseScale()
  local image = app.art.shadow
  local offset = math.sin(lib.tick.index * lib.tick.rate * 3) * 4
  local scale = g.imageScale(image, (70 + offset) * baseScale)

  g.white(70 * self.alpha)
  g.draw(image, self.position.x, self.position.y, 0, scale, scale / 1.5, image:getWidth() / 2, image:getHeight() / 2)

  self:drawRing(255, 40, 40)

  g.white()
  self.animation:tick(lib.tick.delta)
  self.animation.skeleton:findBone('body').rotation = 270 + self.yank * 20 * (self.animation.flipped and 1 or -1)

  if util.timeSince(self.lastHurt) < self.config.damageFlashDuration then
    self.animation:draw(self.position.x, self.position.y)
    app.shaders.colorize:send('color', { 1, 1, 1, 1 - util.timeSince(self.lastHurt) / self.config.damageFlashDuration })
    g.setShader(app.shaders.colorize)
    self.animation:draw(self.position.x, self.position.y)
    g.setShader()
  else
    self.animation:draw(self.position.x, self.position.y)
  end

  local image = app.art.puju
  local scale = g.imageScale(image, 35 * baseScale)

  g.white(self.alpha * 255)
  --g.draw(image, self.position.x, self.position.y - 20 + offset - image:getHeight() * scale, self.yank * .4, scale * self.direction, scale, image:getWidth() / 2, 0)

  return -self.position.y
end

function puju:die()
  if self.attackThread then
    lib.quilt.remove(self.attackThread)
  end

  if self.dead then return end

  self.dead = true
  self:dropShruju()

  lib.flux.to(self, .4, { alpha = 0 }):ease('cubicout'):oncomplete(function()
    self:remove()
  end)
end

return puju
