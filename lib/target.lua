local target = {}

function target.objectAtPosition(x, y)
  local x, y = love.mouse.getPosition()
  local candidates = {}
  candidates = util.concat(candidates, util.filter(app.context.objects, 'isMinion'))
  candidates = util.concat(candidates, util.filter(app.context.objects, 'isEnemy'))
  candidates = util.concat(candidates, { app.context.objects.muju })

  table.sort(candidates, function(a, b)
    return a.position.y > b.position.y
  end)

  return util.match(candidates, function(candidate)
    return candidate.animation:contains(x, y)
  end)
end

return target
