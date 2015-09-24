local funk = {}

function funk.try(f, ...)
  if type(f) == 'function' then
    return f(...)
  end
end

function funk.eq(x)
  return function(y)
    return y == x
  end
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
