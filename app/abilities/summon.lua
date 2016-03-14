local summon = lib.object.create()

summon:include(lib.ability)

function summon:getCost()
  return #util.filter(app.context.objects, 'isMinion')
end

function summon:canCast()
  return self.owner.juju >= self:getCost()
end

function summon:cast(x, y)
  if not self:canCast() then return false end

  local muju = self.owner

  muju:spendJuju(self:getCost())

  local distance = muju.config.radius + app.minions.bruju.config.radius
  local angle = util.angle(muju.position.x, muju.position.y, x, y)
  local minion = app.minions.bruju.object:new({
    position = {
      x = muju.position.x + util.dx(distance, angle),
      y = muju.position.y + util.dy(distance, angle) / 2
    }
  })

  app.context.objects[minion] = minion

  minion.activeAbility:cast(x, y)

  self.owner.animation:set('summon')
end

return summon
