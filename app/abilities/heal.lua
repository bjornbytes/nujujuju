local heal = lib.object:new()

heal:include(lib.ability)

heal.cost = 1
heal.amount = 1

function heal:canCast()
  return self.owner.juju >= self.cost
end

function heal:cast(x, y)
  local entity = lib.target.objectAtPosition(x, y)

  if entity and entity.isMinion and entity.health < entity.config.maxHealth then
    if self.owner.juju < self.cost then return false end

    self.owner:spendJuju(self.cost)
    entity:heal(self.amount, self.owner)

    return true
  end

  return false
end

return heal
