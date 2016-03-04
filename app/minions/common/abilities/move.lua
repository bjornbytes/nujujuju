local move = lib.object.create()

function move:cast(x, y)
  local entity = lib.target.objectAtPosition(x, y)

  -- Moving to a juju picks it up
  if util.isa(entity, app.juju) then
    self.owner.target = entity
    return
  end

  self.owner.destination.x = x
  self.owner.destination.y = y
  self.owner.target = nil
end

return move
