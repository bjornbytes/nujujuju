local ability = {}

function ability:getColor()
  return { 255, 255, 255 }
end

function ability:getCost()
  return self.cost
end

function ability:canPayJuju()
  return app.context.objects.muju.juju >= self:getCost()
end

function ability:payJuju()
  if self:canPayJuju() then
    app.context.objects.muju:spendJuju(self:getCost())
    return true
  end

  return false
end

function ability:getCooldown()
  return self.cooldown
end

function ability:isOnCooldown()
  return self:getCooldown() and self:timeUntilReady() > 0
end

function ability:timeUntilReady()
  if not self.lastCast or not self:getCooldown() then return 0 end
  return math.max(self:getCooldown() - (lib.tick.index - self.lastCast) * lib.tick.rate, 0)
end

return ability
