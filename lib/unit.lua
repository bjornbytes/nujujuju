local unit = {}

function unit:flipAnimation()
  local sign

  if self.target then
    sign = self:signTo(self.target)
  else
    sign = util.sign(self.destination.x - self.position.x)
  end

  if sign ~= 0 then
    self.animation.flipped = sign < 0
  end
end

function unit:isInvincible()
  return self.state == 'spawn' or (self.lastHurt and self.config.hurtGrace and (lib.tick.index - self.lastHurt) * lib.tick.rate <= self.config.hurtGrace)
end

function unit:hurt(amount, source)
  if self:isInvincible() then return end

  self.health = self.health - amount

  if self.lastHurt then
    self.lastHurt = lib.tick.index
  end

  if source.isMinion or source.isEnemy then
    if not self.target and self:distanceToPoint(self.destination.x, self.destination.y) == 0 then
      self.target = source
    end
  end

  if self.health <= 0 then
    self:die()
  end
end

function unit:heal(amount, source)
  self.health = math.min(self.health + amount, self.config.maxHealth)
end

function unit:die()
  if not self.dead then
    self.dead = true
    self.animation:set('death')
  end
end

function unit:remove()
  self.dead = true
  return lib.entity.remove(self)
end

return unit
