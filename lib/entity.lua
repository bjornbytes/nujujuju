local entity = {}

function entity:isSelected()
  return app.context.input.selected == self
end

function entity:isHovered(x, y)
  return self.animation:contains(x, y)
end

function entity:drawRing(r, gg, b)
  local alpha = (self:isSelected() or self:isHovered(love.mouse.getPosition())) and 1 or 0.5
  local radius = self.config.radius

  g.setColor(r, gg, b, alpha * 160)
  g.setLineWidth(3)
  g.ellipse('line', self.position.x, self.position.y, radius, radius / 2)

  g.white(alpha * 160)
  g.setLineWidth(1)
  g.ellipse('line', self.position.x, self.position.y, radius, radius / 2)
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
    end
  }

  local kinds = {...}
  local targets = {}
  util.each(kinds, function(kind) getEntries[kind](targets) end)
  table.sort(targets, function(a, b) return a[2] < b[2] end)
  if targets[1] then return unpack(targets[1]) end
  return nil
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

return entity
