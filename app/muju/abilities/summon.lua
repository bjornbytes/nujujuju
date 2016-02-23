local summon = lib.object.create()

function summon:cast(x, y)
  local minion = app.minions.bruju.object:new({
    position = {
      x = app.context.objects.muju.position.x,
      y = app.context.objects.muju.position.y,
    },
    target = {
      x = x,
      y = y
    }
  })

  app.context.objects.muju.animation:set('summon')
end

return summon
