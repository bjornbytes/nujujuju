local object = {}

function object.create(state)
  local self = {
    _state = lib.rx.Subject.create(state)
  }

  return setmetatable(self, {
    __index = function(_, key)
      if key == 'state' then
        return self._state:getValue()
      else
        local val = rawget(self, key)
        if val then return val end
        return object[key]
      end
    end
  })
end

function object:setState(updates)
  local state = self._state:getValue()

  for key, value in pairs(updates) do
    state[key] = value
  end

  self._state:onNext(state)
end

return object
