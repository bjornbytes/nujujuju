local object = {}

function object.create()
  return setmetatable({}, {__index = object})
end

function object:include(source)
  util.merge(source, self)
end

function object:wrap(fn)
  return f.self(fn, self)
end

function object:dispose(subscriptions)
  if not subscriptions then return end

  self._subscriptions = self._subscriptions or {}
  for i = 1, #subscriptions do
    table.insert(self._subscriptions, subscriptions[i])
  end
end

function object:unbind()
  if not self._subscriptions then return end
  for i = 1, #self._subscriptions do
    self._subscriptions[i]:unsubscribe()
  end
end

function object:new(state)
  local baseState = type(self.state) == 'function' and self.state() or {}
  local instance = util.merge(baseState, {})
  instance = util.merge(state or {}, instance)

  setmetatable(instance, {__index = self})

  instance:dispose(f.try(instance.bind, instance))

  return instance
end

return object
