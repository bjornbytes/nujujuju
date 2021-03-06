local entity = {}

function entity:isHovered(x, y)
  local hoverAllowanceFactor = 2
  local dis = util.distance(self.position.x, self.position.y, x, y)
  local dir = util.angle(self.position.x, self.position.y, x, y)
  local ellipseHover = dis < self.config.radius * hoverAllowanceFactor / (2 - math.abs(math.cos(dir)))

  return self:isTargetable() and ((self.animation and self.animation:contains(x, y)) or ellipseHover)
end

function entity:isTargetable()
  return true
end

function entity:drawRing(r, gg, b)
  local mx, my = app.context.view:worldPoint(love.mouse.getPosition())
  local isCasting = app.context.abilities:isCasting() and app.context.abilities.owner == self
  local isTargeted = app.context.abilities:isCasting() and self.isEnemy and lib.target.objectAtPosition(mx, my) == self
  local alpha = (isCasting or isTargeted) and 1 or 0.5

  self.ringAlpha = util.lerp(self.ringAlpha or 0, alpha, 8 * lib.tick.delta)

  local radius = self.config.radius * (1 + .5 * (self.ringAlpha - .5))

  if app.context.abilities:isValidCastTarget(self) then
    radius = radius * (1 + math.abs(math.sin(lib.tick.index * lib.tick.rate * 4)) * .2)

    g.white(50)
    g.ellipse('fill', self.position.x, self.position.y, radius, radius / 2)
  else
    radius = radius * (1 + math.abs(math.sin(lib.tick.index * lib.tick.rate * 4)) * .05)
  end

  g.setColor(r, gg, b, self.ringAlpha * 80)
  g.setLineWidth(4 + 3 * alpha)
  g.ellipse('line', self.position.x, self.position.y, radius, radius / 2)

  g.white(self.ringAlpha * 160)
  g.setLineWidth(2 + 2 * (alpha - .5))
  g.ellipse('line', self.position.x, self.position.y, radius, radius / 2)

  g.setLineWidth(1)
end

function entity.closest(source, ...)
  local getEntries = {
    enemy = function(source, result)
      util.each(util.filter(app.context.objects, 'isEnemy'), function(enemy)
        if source ~= enemy then
          table.insert(result, {enemy, entity.distanceTo(source, enemy)})
        end
      end)
    end,

    minion = function(source, result)
      util.each(util.filter(app.context.objects, 'isMinion'), function(minion)
        if source ~= minion then
          table.insert(result, {minion, entity.distanceTo(source, minion)})
        end
      end)
    end,

    player = function(source, result)
      local player = app.context.objects.muju
      if source ~= player then
        table.insert(result, {player, entity.distanceTo(source, player)})
      end
    end,

    shruju = function(source, result)
      util.each(util.filter(app.context.objects, 'isShruju'), function(shruju)
        if source ~= shruju and not shruju.carrier then
          table.insert(result, {shruju, entity.distanceTo(source, shruju)})
        end
      end)
    end
  }

  local kinds = {...}
  local targets = {}
  util.each(kinds, function(kind) getEntries[kind](source, targets) end)
  table.sort(targets, function(a, b) return a[2] < b[2] end)
  if targets[1] then return unpack(targets[1]) end
  return nil
end

function entity.closestToPoint(x, y, ...)
  local getEntries = {
    enemy = function(result)
      util.each(util.filter(app.context.objects, 'isEnemy'), function(enemy)
        table.insert(result, {enemy, entity.distanceToPoint(enemy, x, y)})
      end)
    end,

    minion = function(result)
      util.each(util.filter(app.context.objects, 'isMinion'), function(minion)
        table.insert(result, {minion, entity.distanceToPoint(minion, x, y)})
      end)
    end,

    player = function(result)
      local player = app.context.objects.muju
      table.insert(result, {player, entity.distanceToPoint(player, x, y)})
    end,

    shruju = function(result)
      util.each(util.filter(app.context.objects, 'isShruju'), function(shruju)
        if not shruju.carrier then
          table.insert(result, {shruju, entity.distanceToPoint(shruju, x, y)})
        end
      end)
    end
  }

  local kinds = {...}
  local targets = {}
  util.each(kinds, function(kind) getEntries[kind](targets) end)
  table.sort(targets, function(a, b) return a[2] < b[2] end)
  if targets[1] then return unpack(targets[1]) end
  return nil
end

function entity.inRange(x, y, range, ...)
  local getEntries = {
    enemy = function(result)
      util.each(util.filter(app.context.objects, 'isEnemy'), function(enemy)
        local distance = entity.distanceToPoint(enemy, x, y)
        if distance <= range then
          table.insert(result, enemy)
        end
      end)
    end,

    minion = function(result)
      util.each(util.filter(app.context.objects, 'isMinion'), function(minion)
        local distance = entity.distanceToPoint(minion, x, y)
        if distance <= range then
          table.insert(result, minion)
        end
      end)
    end,

    player = function(result)
      local player = app.context.objects.muju
      local distance = entity.distanceToPoint(player, x, y)
      if distance <= range then
        table.insert(result, player)
      end
    end,

    shruju = function(result)
      util.each(util.filter(app.context.objects, 'isShruju'), function(shruju)
        local distance = entity.distanceToPoint(shruju, x, y)
        if distance <= range and not shruju.carrier then
          table.insert(result, shruju)
        end
      end)
    end
  }

  local kinds = {...}
  local targets = {}

  util.each(kinds, function(kind) getEntries[kind](targets) end)

  return targets
end

function entity:distanceTo(other)
  return entity.distanceToPoint(self, other.position.x, other.position.y)
end

function entity:distanceToPoint(x, y)
  return util.distance(self.position.x, self.position.y, x, y)
end

function entity:directionTo(other)
  return entity.directionToPoint(self, other.position.x, other.position.y)
end

function entity:directionToPoint(x, y)
  return util.angle(self.position.x, self.position.y, x, y)
end

function entity:signTo(other)
  return -util.sign(self.position.x - other.position.x)
end

function entity:isInRangeOf(other)
  return self:distanceTo(other) < self.config.range
end

function entity:moveIntoRangeOf(other, speed)
  if not entity.isInRangeOf(self, other) then
    entity.moveTowards(self, other, speed)
  end
end

function entity:moveTowards(other, speed)
  return entity.moveTowardsPoint(self, other.position.x, other.position.y, speed)
end

function entity:moveTowardsPoint(x, y, speed)
  local distance, direction = lib.entity.distanceToPoint(self, x, y), lib.entity.directionToPoint(self, x, y)
  speed = math.min(distance, speed)
  self.position.x = self.position.x + math.cos(direction) * speed
  self.position.y = self.position.y + math.sin(direction) * speed
end

function entity:moveWithSpeed(speed, y)
  local x
  if y then
    x = speed
  else
    x, y = speed.x, speed.y
  end

  self.position.x = self.position.x + x * lib.tick.rate
  self.position.y = self.position.y + y * lib.tick.rate
end

function entity:moveInDirection(direction, speed)
  self:moveWithSpeed(util.dx(speed, direction), util.dy(speed, direction))
end

function entity:isEscaped()
  if self.config.shape == 'circle' or self.config.shape == 'ellipse' then
    local r = self.config.radius
    local x, y = self.position.x, self.position.y
    local w, h = app.context.scene.width, app.context.scene.height
    local x1, y1, x2, y2 = x - r, y - r, x + r, y + r
    return x1 < 0 or y1 < 0 or x2 > w or y2 > h
  end
  return false
end

function entity:enclose()
  if self.config.shape == 'circle' or self.config.shape == 'ellipse' then
    local r = self.config.radius
    local x, y = self.position.x, self.position.y
    local w, h = app.context.scene.width, app.context.scene.height
    self.position.x = util.clamp(x, r, w - r)
    self.position.y = util.clamp(y, r, h - r)
  end
end

function entity:remove()
  self:unbind()
  app.context:removeObject(self)
end

-- Sugar
function entity:canCast(ability, ...)
  return ability:canCast(self, ...)
end

function entity:cast(ability, ...)
  return ability:cast(self, ...)
end

return entity
