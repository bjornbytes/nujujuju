local minion = {}

function minion:setIsMinion()
  self.isMinion = true
end

function minion:getBaseSpeed()
  if self:isCarryingShruju() then
    return self.config.speed / 1.5
  end

  return self.config.speed
end

return minion
