local auto = lib.object.create()

function auto:cast(x, y)
  print('casting the auto ability at ' .. x .. ', ' .. y)
end

return auto
