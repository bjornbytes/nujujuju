local object = {}

function object.create()
  return setmetatable({}, {__index = object})
end

function object:new(state)
  local instance = {
    _state = lib.rx.Subject.create(f.try(state or self.state))
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

return object
