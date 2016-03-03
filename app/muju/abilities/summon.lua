local summon = lib.object.create()

function summon:canCast()
  local minionCount = #util.filter(app.context.objects, 'isMinion')
  return minionCount < self.owner.config.maxMinions
end

function summon:canCastAtPosition(x, y)
  return true
end

function summon:cast(x, y)
  if not self:canCast() or not self:canCastAtPosition(x, y) then return end

  local minion = app.minions.bruju.object:new({
    position = {
      x = app.context.objects.muju.position.x,
      y = app.context.objects.muju.position.y,
    }
  })

  app.context.objects[minion] = minion

  minion.abilities.auto:cast(x, y)

  self.owner.animation:set('summon')
end

return summon
