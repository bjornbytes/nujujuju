local minion = {}

function minion:setIsMinion()
  self.isMinion = true
end

function minion:getBaseSpeed()
  return self.config.speed
end

return minion
