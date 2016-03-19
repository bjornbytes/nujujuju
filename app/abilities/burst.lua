local burst = lib.object.create():include(lib.ability)

burst.cooldown = 3
burst.cost = 1
burst.range = 150
burst.damage = 3

function burst:canCast(owner)
  return util.isa(owner, app.minions.bruju.object) and not self:isOnCooldown() and self:canPayJuju()
end

function burst:cast(owner, x, y)
  self:payJuju()

  app.context:addObject(app.spells.burst, {
    position = util.copy(owner.position),
    radius = self.range
  })

  util.each(lib.entity.inRange(owner.position.x, owner.position.y, self.range, 'enemy'), function(enemy)
    enemy:hurt(self.damage, owner)
  end)

  owner:hurt(owner.health, owner)

  self.lastCast = lib.tick.index
end

return burst
