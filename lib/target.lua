local target = {}

function target.objectAtPosition(x, y)
  local x, y = love.mouse.getPosition()
  local candidates = {}
  candidates = util.concat(candidates, util.filter(app.context.objects, 'isMinion'))
  candidates = util.concat(candidates, util.filter(app.context.objects, 'isEnemy'))
  candidates = util.concat(candidates, util.filter(app.context.objects, function(object)
    return util.isa(object, app.juju)
  end))
  candidates = util.concat(candidates, { app.context.objects.muju })

  table.sort(candidates, function(a, b)
    return a.position.y > b.position.y
  end)

  return util.match(candidates, function(candidate)
    return candidate:isTargetable() and candidate:isHovered(x, y)
  end)
end

return target
