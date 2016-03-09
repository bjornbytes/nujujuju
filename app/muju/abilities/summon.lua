local summon = lib.object.create()

function summon:canCast()
  local minionCount = #util.filter(app.context.objects, 'isMinion')
  return minionCount < self.owner.config.maxMinions
end

function summon:cast(x, y)
  if not self:canCast() then return false end

  local muju = self.owner

  local dir = util.angle(muju.position.x, muju.position.y, x, y)

  local minion = app.minions.bruju.object:new({
    position = {
      x = muju.position.x + (muju.config.radius + app.minions.bruju.config.radius) * math.cos(dir),
      y = muju.position.y + (muju.config.radius + app.minions.bruju.config.radius) * math.sin(dir) / 2
    }
  })

  app.context.objects[minion] = minion

  minion.activeAbility:cast(x, y)

  self.owner.animation:set('summon')
end

return summon
