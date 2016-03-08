local minion = {}

function minion:setIsMinion()
  self.isMinion = true
end

function minion:getBaseSpeed()
  return self.config.speed
end

function minion:isCarryingJuju()
  return util.match(app.context.objects, function(object)
    return util.isa(object, app.juju) and object.carrier == self
  end)
end

return minion
