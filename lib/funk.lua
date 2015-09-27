local funk = {}

function funk.try(f, ...)
  if type(f) == 'function' then
    return f(...)
  end
  return f
end

function funk.eq(x)
  return function(y)
    return x == y
  end
end

function funk.chain(combine, ...)
  local fs = {...}
  return function(...)
    local result = nil
    for i = 1, #fs do
      result = combine(result, fs[i](...))
    end
    return result
  end
end

function funk.flow(...)
  return funk.chain(funk.id, ...)
end

function funk.any(...)
  local result = nil
  for i = 1, #arg do
    result = result or arg[i]
  end
  return result
end

function funk.all(...)
  local result = nil
  for i = 1, #arg do
    result = result and arg[i]
  end
  return result
end

function funk.val(value)
  return function()
    return value
  end
end

function funk.id(x)
  return x
end

function funk.self(f, self)
  return function(...)
    return f(self, ...)
  end
end

return funk
