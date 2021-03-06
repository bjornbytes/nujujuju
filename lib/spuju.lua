local spuju = {}

function spuju:idle()
  self.target = self:closest('minion', 'shruju')

  if self.target then
    self.state = 'move'
  end
end

function spuju:move()
  self.target = self:closest('minion', 'shruju')

  local isInRange = self:isInRangeOf(self.target)
  local distanceToTarget = self:distanceTo(self.target) - self.config.radius - self.target.config.radius
  local directionToTarget = self:directionTo(self.target)

  if self.target.isShruju then
    self.animation:set('walk')
    self.targetDirection = directionToTarget
    self.direction = util.anglerp(self.direction, self.targetDirection, lib.tick.getLerpFactor(.05))

    self:moveInDirection(self.direction, self.config.speed)

    if distanceToTarget <= 0 then
      if self:pickupShruju(self.target) then
        self.state = 'run'
      end
    end

    return
  end

  if isInRange and love.math.random() < .25 / lib.tick.rate then
    if distanceToTarget < self.config.fearRange and love.math.random() < .25 and self.abilities.fear:canCast(self) then
      local x, y = self.target.position.x, self.target.position.y
      self.abilities.fear:cast(self, x, y)
      self.animation:set('fear')
      self.state = 'fear'
    elseif not self.lastAttack or (lib.tick.index - self.lastAttack) * lib.tick.rate >= self.config.attackCooldown then
      self.animation:set('attack')
      self.state = 'attack'
    end
  elseif not isInRange then
    self.animation:set('walk')
    self.targetDirection = directionToTarget
    self.direction = util.anglerp(self.direction, self.targetDirection, lib.tick.getLerpFactor(.05))

    self:moveInDirection(self.direction, self.config.speed)
  else
    local flip = (math.floor(lib.tick.index * lib.tick.rate / 2) % 2) == 0
    self.targetDirection = flip and (directionToTarget + math.pi * .5) or (directionToTarget - math.pi * .5)
    self.direction = util.anglerp(self.direction, self.targetDirection, lib.tick.getLerpFactor(.05))
    self:moveInDirection(self.direction, self.config.speed / 2)
  end

  if self:isEscaped() then
    self:enclose()
  end
end

function spuju:attack()
  self.lastAttack = lib.tick.index
end

function spuju:fear()
  -- wait for animation to complete
end

function spuju:run()
  local targetX, targetY

  if self.position.x < app.context.scene.width / 2 then
    targetX = 0
    targetY = app.context.scene.height / 2
    self.animation.flipped = false
  else
    targetX = app.context.scene.width
    targetY = app.context.scene.height / 2
    self.animation.flipped = true
  end

  local distance = self:distanceToPoint(targetX, targetY)
  local direction = self:directionToPoint(targetX, targetY)

  self.direction = util.anglerp(self.direction, direction, lib.tick.getLerpFactor(.05))
  self:moveInDirection(self.direction, self.config.speed / 3)

  if distance < 50 then
    self.target:die()
    self.state = 'idle'
  end
end

function spuju:hurt(...)
  if self.abilities.fear:isOnCooldown() and self.abilities.fear.lastCast then
    self.abilities.fear.lastCast = self.abilities.fear.lastCast + (1 / lib.tick.rate)
  end

  if self.lastAttack then
    self.lastAttack = self.lastAttack + (1 / lib.tick.rate)
  end

  return lib.unit.hurt(self, ...)
end

function spuju:draw()
  local image = app.art.shadow
  local scale = 60 / image:getWidth()

  g.white(70)
  g.draw(image, self.position.x, self.position.y, 0, scale, scale / 1.5, image:getWidth() / 2, image:getHeight() / 2)

  self:drawRing(255, 40, 40)

  self.animation:tick(lib.tick.delta)

  if util.timeSince(self.lastHurt) < self.config.damageFlashDuration then
    self.animation:draw(self.position.x, self.position.y)
    app.shaders.colorize:send('color', { 1, 1, 1, 1 - util.timeSince(self.lastHurt) / self.config.damageFlashDuration })
    g.setShader(app.shaders.colorize)
    self.animation:draw(self.position.x, self.position.y)
    g.setShader()
  else
    self.animation:draw(self.position.x, self.position.y)
  end

  return -self.position.y
end

return spuju
