local fear = lib.object.create():include(lib.ability)

fear.cooldown = 12

function fear:canCast()
  return not self:isOnCooldown()
end

function fear:cast(owner, x, y)
  local target = lib.target.objectAtPosition(x, y)

  target.buffs:add('fear', { source = owner })

  self.lastCast = lib.tick.index
end

return fear
