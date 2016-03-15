local command = lib.object.create():include(lib.ability)

function command:getColor()
  local entity = lib.target.objectAtPosition(app.context.view:worldPoint(love.mouse.getPosition()))
  if entity and entity.isEnemy then
    return { 255, 140, 140 }
  else
    return { 140, 255, 140 }
  end
end

function command:canCast()
  return true
end

function command:cast(x, y)
  local entity = lib.target.objectAtPosition(x, y)

  if entity and (util.isa(entity, app.juju) or entity.isEnemy) then
    self.owner.target = entity
  else

    -- Moving to a juju picks it up
    if util.isa(entity, app.juju) then
      self.owner.target = entity
      return
    end

    local muju = app.context.objects.muju
    local distance, angle = util.vector(x, y, muju.position.x, muju.position.y)
    local minDistance = self.owner.config.radius + muju.config.radius
    if distance * (2 - math.abs(math.sin(angle))) < minDistance * (2 - math.abs(math.sin(angle))) then
      x = muju.position.x + util.dx(minDistance + 4, angle + math.pi)
      y = muju.position.y + util.dy(minDistance + 4, angle + math.pi) / 2
    end

    self.owner.destination.x = x
    self.owner.destination.y = y
    self.owner.target = nil
  end
end

return command
