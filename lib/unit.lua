local unit = {}

function unit.closest(source, ...)
  local getEntries = {
    enemy = function(source, result)
      util.each(util.filter(app.context.objects, 'isEnemy'), function(enemy)
        if source ~= enemy then
          table.insert(result, {enemy, lib.unit.distanceTo(source, enemy)})
        end
      end)
    end,

    minion = function(source, result)
      util.each(util.filter(app.context.objects, 'isMinion'), function(minion)
        if source ~= minion then
          table.insert(result, {minion, lib.unit.distanceTo(source, minion)})
        end
      end)
    end,

    player = function(source, result)
      local player = app.context.objects.muju
      if source ~= player then
        table.insert(result, {player, lib.unit.distanceTo(source, player)})
      end
    end
  }

  local kinds = {...}
  local targets = {}
  util.each(kinds, function(kind) getEntries[kind](source, targets) end)
  table.sort(targets, function(a, b) return a[2] < b[2] end)
  if targets[1] then return unpack(targets[1]) end
  return nil
end

function unit.closestToPoint(x, y, ...)
  local getEntries = {
    enemy = function(result)
      util.each(util.filter(app.context.objects, 'isEnemy'), function(enemy)
        table.insert(result, {enemy, lib.unit.distanceToPoint(enemy, x, y)})
      end)
    end,

    minion = function(result)
      util.each(util.filter(app.context.objects, 'isMinion'), function(minion)
        table.insert(result, {minion, lib.unit.distanceToPoint(minion, x, y)})
      end)
    end,

    player = function(result)
      local player = app.context.objects.muju
      table.insert(result, {player, lib.unit.distanceToPoint(player, x, y)})
    end
  }

  local kinds = {...}
  local targets = {}
  util.each(kinds, function(kind) getEntries[kind](targets) end)
  table.sort(targets, function(a, b) return a[2] < b[2] end)
  if targets[1] then return unpack(targets[1]) end
  return nil
end

function unit:distanceTo(other)
  return unit.distanceToPoint(self, other.position.x, other.position.y)
end

function unit:distanceToPoint(x, y)
  return util.distance(self.position.x, self.position.y, x, y)
end

function unit:directionTo(other)
  return unit.directionToPoint(self, other.position.x, other.position.y)
end

function unit:directionToPoint(x, y)
  return util.angle(self.position.x, self.position.y, x, y)
end

function unit:signTo(other)
  return -util.sign(self.position.x - other.position.x)
end

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
  local distance, direction = unit.distanceToPoint(self, x, y), unit.directionToPoint(self, x, y)
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

function unit:drawRing(r, gg, b)
  local alpha = self.animation:contains(love.mouse.getPosition()) and 1 or .5

  g.setColor(r, gg, b, alpha * 160)
  g.setLineWidth(3)
  g.ellipse('line', self.position.x, self.position.y, 30, 30 / 2)

  g.white(alpha * 160)
  g.setLineWidth(1)
  g.ellipse('line', self.position.x, self.position.y, 30, 30 / 2)
end

return unit
