local summon = lib.object.create():include(lib.ability)

function summon:getCost()
  return #util.filter(app.context.objects, 'isMinion')
end

function summon:canCast(owner)
  local muju = app.context.objects.muju
  return owner == muju and self:canPayJuju()
end

function summon:cast(owner, x, y)
  if not self:canCast(owner) then return false end

  self:payJuju()

  local distance = owner.config.radius + app.minions.bruju.config.radius
  local angle = util.angle(owner.position.x, owner.position.y, x, y)

  local minion = app.context:addObject(app.minions.bruju.object, {
    position = {
      x = owner.position.x + util.dx(distance, angle),
      y = owner.position.y + util.dy(distance, angle) / 2
    }
  })

  minion:command(x, y)

  self.lastCast = lib.tick.index

  owner.animation:set('summon')
end

return summon
