local bruju = {}

function bruju:spawn()
  -- noop
end

function bruju:idle()
  if self.target or self:distanceToPoint(self.destination.x, self.destination.y) > 0 then
    self.state = 'move'
    return
  else
    local closest = self:closest('enemy')

    if closest and not closest.dead and self:distanceTo(closest) <= self.config.aggroRange then
      self.target = closest
      self.state = 'move'
      return
    end
  end

  self.animation:set('idle')
end

function bruju:move()
  if self.target and self.target.isEnemy and self.target.dead then
    self.destination.x = self.position.x
    self.destination.y = self.position.y
    self.target = nil
    self.state = 'idle'
  end

  if self.target then
    local distance = self:distanceTo(self.target)
    if distance <= self.config.radius + self.target.config.radius then
      if self.target.isEnemy then
        self.state = 'attack'
        self.attacking = self.target
        return
      elseif util.isa(self.target, app.juju) then
        self.target:pickup()
        self.state = 'idle'
        return
      else
        self.state = 'idle'
        return
      end
    else
      local speed = math.min(self:getBaseSpeed() * lib.tick.rate, distance)
      self:moveTowards(self.target, speed)
      self.animation:set('walk')
    end
  else
    local distance = self:distanceToPoint(self.destination.x, self.destination.y)

    if distance > 0 then
      local speed = math.min(self:getBaseSpeed() * lib.tick.rate, distance)
      self:moveTowardsPoint(self.destination.x, self.destination.y, speed)
      self.animation:set('walk')
    else
      self.state = 'idle'
    end
  end
end

function bruju:attack()
  if not self.attacking or self.attacking.dead then
    self.state = 'idle'
    self.attacking = nil
    lib.quilt.remove(self.attackCooldown)
    self.attackCooldown = nil
    return
  end

  if not self.attackCooldown then
    self.animation:set('attack')
    self.attackCooldown = lib.quilt.add(function()
      coroutine.yield(self.config.attackSpeed)
      self.attackCooldown = nil
      self.attacking = nil
      self.state = 'idle'
    end)
  elseif self.animation.active ~= self.animation.states.attack and self:distanceTo(self.attacking) > self.config.radius * 2 + self.attacking.config.radius then
    self.state = 'move'
    self.target = self.attacking
    self.attacking = nil
    lib.quilt.remove(self.attackCooldown)
    self.attackCooldown = nil
  end
end

function bruju:onAttack()
  if self.attacking then
    self.attacking:hurt(self.config.damage, self)

    if self.attacking.dead then
      self.destination.x = self.position.x
      self.destination.y = self.position.y
    end

    self.animation:set('idle')
  end
end

function bruju:draw()
  local image = app.art.shadow
  local scale = 60 / image:getWidth()

  g.white(70)
  g.draw(image, self.position.x, self.position.y, 0, scale, scale / 1.5, image:getWidth() / 2, image:getHeight() / 2)

  self:drawRing(40, 200, 40)

  if self.state == 'move' or self.state == 'attack' then
    g.setLineWidth(2)
    local alpha = 1 + math.sin(lib.tick.index * lib.tick.rate * 5) / 2

    if self.state == 'attack' or self.target then
      g.setColor(200, 40, 40, 20 + 60 * alpha)
    else
      g.setColor(40, 200, 40, 20 + 60 * alpha)
    end

    local x, y
    if self.target then
      x, y = self.target.position.x, self.target.position.y
    else
      x, y = self.destination.x, self.destination.y
    end

    g.line(self.position.x, self.position.y, x, y)
    g.setLineWidth(1)
  end

  self.animation:tick(lib.tick.delta)

  if util.timeSince(self.lastHurt) < self.config.damageFlashDuration then
    self.animation:draw(self.position.x, self.position.y)
    app.shaders.colorize:send('color', { 1, 1, 1, 1 - util.timeSince(self.lastHurt) / self.config.damageFlashDuration })
    g.setShader(app.shaders.colorize)
    self.animation:draw(self.position.x, self.position.y)
    g.setShader()
  elseif not self:isInvincible() then-- or util.round(util.timeSince(self.lastHurt) * 4) % 2 == 0 then
    self.animation:draw(self.position.x, self.position.y)
  else
    self.animation:draw(self.position.x, self.position.y)
    app.shaders.colorize:send('color', { 1, 0, 0, 1 * (1 - util.timeSince(self.lastHurt) / self.config.hurtGrace) })
    g.setShader(app.shaders.colorize)
    self.animation:draw(self.position.x, self.position.y)
    g.setShader()
  end

  return -self.position.y
end

return bruju
