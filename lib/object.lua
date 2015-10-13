local object = {}

function object.create()
  return setmetatable({}, {__index = object})
end

function object:include(source)
  table.merge(source, self)
end

function object:wrap(fn)
  return f.self(fn, self)
end

function object:dispose(subscriptions)
  self._subscriptions = subscriptions
end

function object:unbind()
  for i = 1, #self._subscriptions do
    self._subscriptions[i]()
  end
end

function object:new(state)
  local baseState = type(self.state) == 'function' and self.state() or self.state
  state = table.merge(state, baseState)
  local instance = table.merge(state, {})

  setmetatable(instance, { __index = self })

  f.try(instance.bind, instance)

  return instance
end

return object
