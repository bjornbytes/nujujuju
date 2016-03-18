local burst = lib.object.create():include(lib.ability)

burst.cooldown = 3
burst.cost = 1

function burst:canCast(owner)
  return util.isa(owner, app.minions.bruju.object) and not self:isOnCooldown() and self:canPayJuju()
end

function burst:cast(owner, x, y)
  util.each(lib.entity.inRange(owner.position.x, owner.position.y, 100, 'enemy'), function(enemy)
    enemy:hurt(3, owner)
  end)

  self:payJuju()

  owner:hurt(owner.health, owner)

  self.lastCast = lib.tick.index
end

return burst
