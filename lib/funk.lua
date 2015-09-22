local funk = {}

funk.try = function(f, ...)
  if type(f) == 'function' then
    return f(...)
  end
end

return funk
