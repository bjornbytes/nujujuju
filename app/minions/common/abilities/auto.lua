local auto = lib.object.create()

function auto:cast(x, y)
  local entity = lib.target.objectAtPosition(x, y)

  if entity then
    self.owner.target = entity
  else
    self.owner.destination.x = x
    self.owner.destination.y = y
    self.owner.target = nil
  end
end

return auto
