local heal = lib.object:new():include(lib.ability)

heal.cost = 1
heal.amount = 1

function heal:canCast(owner)
  return owner == app.context.objects.muju and owner.juju >= self.cost
end

function heal:cast(owner, x, y)
  local entity = lib.target.objectAtPosition(x, y)

  if entity and entity.isMinion and entity.health < entity.config.maxHealth then
    if owner.juju < self.cost then return false end

    owner:spendJuju(self.cost)
    entity:heal(self.amount, owner)

    return true
  end

  return false
end

return heal
