local object = {}

function object.create()
  return setmetatable({}, {__index = object})
end

function object:new(state)
  local baseState = type(self.state) == 'function' and self.state() or self.state
  state = table.merge(state, baseState)

  local instance = {
    _state = lib.rx.Subject.create(state)
  }

  setmetatable(instance, {
    __index = function(_, key)
      if key == 'state' then
        return instance._state:getValue()
      end

      return self[key]
    end
  })

  f.try(instance.bind, instance)

  return instance
end

function object:setState(updates)
  local state = self._state:getValue()

  for key, value in pairs(updates) do
    state[key] = value
  end

  self._state:onNext(state)
end

function object:updateState(fn)
  local state = self.state
  fn(state)
  self:setState(state)
end

function object:lerp(key, speed, getTarget)
  love.update
    :map(function() return self end)
    :map(getTarget)
    :subscribe(function(target)
      local state = self.state
      state[key] = math.lerp(state[key], target, math.min(speed * lib.tick.rate, 1))
      self:setState(state)
    end)
end

return object
