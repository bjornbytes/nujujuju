local entity = {}

function entity.closest(source, ...)
  local getEntries = {
    totem = function(source, result)
      util.each(util.filter(app.context.objects, 'isTotem'), function(totem)
        if source ~= totem and not totem.building then
          table.insert(result, {totem, lib.entity.distanceTo(source, totem)})
        end
      end)
    end,

    enemy = function(source, result)
      util.each(util.filter(app.context.objects, 'isEnemy'), function(enemy)
        if source ~= enemy then
          table.insert(result, {enemy, lib.entity.distanceTo(source, enemy)})
        end
      end)
    end,

    player = function(source, result)
      local player = app.context.objects.muju
      if source ~= player then
        table.insert(result, {player, lib.entity.distanceTo(source, player)})
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

function entity:distanceTo(other)
  return util.distance(self.position.x, self.position.y, other.position.x, other.position.y)
end

function entity:directionTo(other)
  return util.angle(self.position.x, self.position.y, other.position.x, other.position.y)
end

function entity:signTo(other)
  return -util.sign(self.position.x - other.position.x)
end

function entity:isInRangeOf(other)
  return entity.distanceTo(self, other) < self.config.range
end

function entity:moveIntoRangeOf(other, speed)
  if not entity.inRangeOf(self, other) then
    entity.moveTowards(self, other, speed)
  end
end

function entity:moveTowards(other, speed)
  local distance, direction = entity.distanceTo(self, other), entity.directionTo(self, other)
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

function entity:adjustSpeedToVector(length, direction, smooth)
  local lerp = smooth and (smooth * lib.tick.rate) or 1
  self.speed.x = util.lerp(self.speed.x, length * math.cos(direction), lerp)
  self.speed.y = util.lerp(self.speed.y, length * math.sin(direction), lerp)
  return self.speed
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

return entity
