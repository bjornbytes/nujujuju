local target = {}

function target.objectAtPosition(x, y)
  local candidates = {}
  candidates = util.concat(candidates, util.filter(app.context.objects, 'isMinion'))
  candidates = util.concat(candidates, util.filter(app.context.objects, 'isEnemy'))
  candidates = util.concat(candidates, { app.context.objects.muju })
  candidates = util.concat(candidates, util.filter(app.context.objects, function(object)
    return object.isShruju and not object.carrier and (object.initialPosition.x ~= object.position.x and object.initialPosition.y ~= object.position.y)
  end))

  table.sort(candidates, function(a, b)
    local d1 = util.distance(x, y, a.position.x, a.position.y)
    local d2 = util.distance(x, y, b.position.x, b.position.y)
    local y1 = -a.position.y / 10
    local y2 = -b.position.y / 10
    return d1 + y1 < d2 + y2
  end)

  return util.match(candidates, function(candidate)
    return candidate:isTargetable() and candidate:isHovered(x, y)
  end)
end

return target
