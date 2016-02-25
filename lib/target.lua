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

  for i, candidate in ipairs(candidates) do
    if candidate == app.context.objects.muju and util.distance(x, y, candidate.position.x, candidate.position.y) < candidate.config.radius then
      return candidate
    elseif candidate.animation:contains(x, y) then
      return candidate
    end
  end
end

return target
