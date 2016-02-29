local unit = {}

function unit:isInRangeOf(other)
  return unit.distanceTo(self, other) < self.config.range
end

function unit:moveIntoRangeOf(other, speed)
  if not unit.inRangeOf(self, other) then
    unit.moveTowards(self, other, speed)
  end
end

function unit:moveTowards(other, speed)
  return unit.moveTowardsPoint(self, other.position.x, other.position.y, speed)
end

function unit:moveTowardsPoint(x, y, speed)
  local distance, direction = lib.entity.distanceToPoint(self, x, y), lib.entity.directionToPoint(self, x, y)
  speed = math.min(distance, speed)
  self.position.x = self.position.x + math.cos(direction) * speed
  self.position.y = self.position.y + math.sin(direction) * speed
end

function unit:moveWithSpeed(speed, y)
  local x
  if y then
    x = speed
  else
    x, y = speed.x, speed.y
  end

  self.position.x = self.position.x + x * lib.tick.rate
  self.position.y = self.position.y + y * lib.tick.rate
end

function unit:adjustSpeedToVector(length, direction, smooth)
  local lerp = smooth and (smooth * lib.tick.rate) or 1
  self.speed.x = util.lerp(self.speed.x, length * math.cos(direction), lerp)
  self.speed.y = util.lerp(self.speed.y, length * math.sin(direction), lerp)
  return self.speed
end

function unit:isEscaped()
  if self.config.shape == 'circle' or self.config.shape == 'ellipse' then
    local r = self.config.radius
    local x, y = self.position.x, self.position.y
    local w, h = app.context.scene.width, app.context.scene.height
    local x1, y1, x2, y2 = x - r, y - r, x + r, y + r
    return x1 < 0 or y1 < 0 or x2 > w or y2 > h
  end
  return false
end

function unit:enclose()
  if self.config.shape == 'circle' or self.config.shape == 'ellipse' then
    local r = self.config.radius
    local x, y = self.position.x, self.position.y
    local w, h = app.context.scene.width, app.context.scene.height
    self.position.x = util.clamp(x, r, w - r)
    self.position.y = util.clamp(y, r, h - r)
  end
end

function unit:hurt(amount)
  self.health = self.health - amount
  if self.health <= 0 then
    self:die()
  end
end

return unit
