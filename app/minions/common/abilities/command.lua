local command = lib.object.create()

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
