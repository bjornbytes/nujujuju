local attack = lib.object.create()

function attack:canCast()
  return true
end

function attack:canCastAtPosition()
  local entity = lib.target.objectAtPosition(x, y)

  return entity and (util.isa(entity, app.juju) or entity.isEnemy)
end

function attack:cast(x, y)
  self.owner.target = lib.target.objectAtPosition(x, y)
end

return attack
