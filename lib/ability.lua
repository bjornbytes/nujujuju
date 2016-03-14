local ability = {}

function ability:getColor()
  return { 255, 255, 255 }
end

function ability:getCost()
  return self.cost
end

return ability
