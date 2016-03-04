local attack = lib.object.create()

function attack:canCast()
  return not self.owner:isCarryingJuju()
end

function attack:canCastAtPosition()
  local entity = lib.target.objectAtPosition(x, y)

  return entity and (util.isa(entity, app.juju) or entity.isEnemy)
end

function attack:cast(x, y)
  local entity = lib.target.objectAtPosition(x, y)

  if entity then
    self.owner.target = entity
  end
end

return attack
