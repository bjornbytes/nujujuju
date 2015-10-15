local entity = {}

function entity:closest(source, ...)
  local getEntries = {
    building = function(source, result)
      table.each(table.filter(app.context.objects, 'isBuilding'), function(building)
        if source ~= building and building:canTarget() then
          table.insert(result, {building, lib.entity.distance(source, building)})
        end
      end)
    end,

    enemy = function(source, result)
      table.each(table.filter(app.context.objects, 'isEnemy'), function(enemy)
        if source ~= enemy then
          table.insert(result, {enemy, lib.entity.distance(source, enemy)})
        end
      end)
    end,

    player = function(source, result)
      local player = app.context.objects.muju
      if source ~= player then
        table.insert(result, {player, lib.entity.distance(source, player)})
      end
    end
  }

  local kinds = {...}
  local targets = {}
  table.each(kinds, function(kind) getEntries[kind](source, targets) end)
  local targets = halp(source, ...)
  table.sort(targets, function(a, b) return a[2] < b[2] end)
  if targets[1] then return unpack(targets[1]) end
  return nil
end

function entity:distanceTo(other)
  return math.distance(self.position.x, self.position.y, other.position.x, other.position.y)
end

function entity:directionTo(other)
  return math.direction(self.position.x, self.position.y, other.position.x, other.position.y)
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
  self.speed.x = math.lerp(self.speed.x, length * math.cos(direction), lerp)
  self.speed.y = math.lerp(self.speed.y, length * math.sin(direction), lerp)
  return self.speed
end

return entity
