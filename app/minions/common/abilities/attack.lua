local attack = lib.object.create()

function attack:cast(x, y)
  local entity = lib.target.objectAtPosition(x, y)

  if entity then
    self.owner.target = entity
  end
end

return attack
