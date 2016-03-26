local unit = {}

function unit:command(x, y)
  local entity = lib.target.objectAtPosition(x, y)

  -- Interrupt attacks
  if self.attackCooldown then
    lib.quilt.remove(self.attackCooldown)
    self.attackCooldown = nil
    self.state = 'move'
    self.attacking = nil
  end

  if entity and (util.isa(entity, app.juju) or entity.isEnemy) then
    self.target = entity
  else

    -- Moving to a juju picks it up
    if util.isa(entity, app.juju) then
      self.target = entity
      return
    end

    local muju = app.context.objects.muju
    local distance, angle = util.vector(x, y, muju.position.x, muju.position.y)
    local minDistance = self.config.radius + muju.config.radius
    if distance * (2 - math.abs(math.sin(angle))) < minDistance * (2 - math.abs(math.sin(angle))) then
      x = muju.position.x + util.dx(minDistance + 4, angle + math.pi)
      y = muju.position.y + util.dy(minDistance + 4, angle + math.pi) / 2
    end

    self.destination.x = x
    self.destination.y = y
    self.target = nil
  end
end

function unit:resolveCollision(other, dx, dy)
  if other.isMinion or other.isEnemy then
    local x1, y1, x2, y2 = self.position.x, self.position.y, other.position.x, other.position.y

    local myFactor, theirFactor
    local selfIsMoving, otherIsMoving = self:isMoving(), other:isMoving()

    if selfIsMoving and not otherIsMoving then
      myFactor, theirFactor = 0, .75
    elseif not selfIsMoving and otherIsMoving then
      myFactor, theirFactor = .75, 0
    elseif selfIsMoving and otherIsMoving then
      myFactor, theirFactor = 0, 0
    else
      myFactor, theirFactor = .5, .5
    end

    self.position.x = util.lerp(self.position.x, self.position.x - dx * myFactor, .05)
    self.position.y = util.lerp(self.position.y, self.position.y - dy * myFactor, .05)

    other.position.x = util.lerp(other.position.x, other.position.x + dx * theirFactor, .05)
    other.position.y = util.lerp(other.position.y, other.position.y + dy * theirFactor, .05)

    if not selfIsMoving and self.destination then
      self.destination.x = self.destination.x + (self.position.x - x1)
      self.destination.y = self.destination.y + (self.position.y - y1)
    end

    if not otherIsMoving and other.destination then
      other.destination.x = other.destination.x + (other.position.x - x2)
      other.destination.y = other.destination.y + (other.position.y - y2)
    end
  end
end

function unit:isMoving()
  return self.state == 'move'
end

function unit:flipAnimation()
  local sign

  if self.target then
    sign = self:signTo(self.target)
  else
    sign = util.sign(self.destination.x - self.position.x)
  end

  if self.buffs and self.buffs:getFear() then
    sign = -sign
  end

  if sign ~= 0 then
    self.animation.flipped = sign < 0
  end
end

function unit:randomizeStats(stat, ...)
  if not stat then return end
  local val = self[stat]
  self[stat] = util.clamp(love.math.randomNormal(val, val * .1), val - val * .33, val + val * .33)
  return self:randomizeStats(...)
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

function unit:runIfFeared()
  local fear = self.buffs:getFear()
  if fear then
    local direction = self:directionTo(fear.source)
    self:moveInDirection(direction + math.pi, self.config.speed / 2)
    return true
  end
end

function unit:drawBuffs()
  local fear = self.buffs:getFear()
  if fear then
    g.white()
    local image = app.art.fear
    local scale = g.imageScale(image, 40 + (1 + math.cos(math.sin(lib.tick.index) / 3) / 5))
    g.draw(image, self.position.x, self.position.y - 80, math.cos(lib.tick.index / 3) / 6, scale, scale, 53, 83)
  end
end

return unit
