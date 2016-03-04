local auto = lib.object.create()

function auto:cast(x, y)
  local entity = lib.target.objectAtPosition(x, y)

  if entity and (util.isa(entity, app.juju) or entity.isEnemy) then
    self.owner.abilities.attack:cast(x, y)
  else
    self.owner.abilities.move:cast(x, y)
  end
end

return auto
