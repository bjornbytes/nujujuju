local summon = lib.object.create()

function summon:cast(x, y)
  local minion = app.minions.bruju.object:new({
    position = {
      x = app.context.objects.muju.position.x,
      y = app.context.objects.muju.position.y,
    },
    destination = {
      x = x,
      y = y
    }
  })

  app.context.objects[minion] = minion

  self.owner.animation:set('summon')
end

return summon
