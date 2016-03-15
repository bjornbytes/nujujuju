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

    self.owner.destination.x = x
    self.owner.destination.y = y
    self.owner.target = nil
  end
end

return command
