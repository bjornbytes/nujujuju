local minion = {}

function minion:setIsMinion()
  self.isMinion = true
end

function minion:getBaseSpeed()
  local isCarryingJuju = util.any(app.context.objects, function(object)
    return util.isa(object, app.juju) and object.carrier == self
  end)

  return isCarryingJuju and self.config.speed / 2 or self.config.speed
end

function minion:isCarryingJuju()
  return util.match(app.context.objects, function(object)
    return util.isa(object, app.juju) and object.carrier == self
  end)
end

return minion
