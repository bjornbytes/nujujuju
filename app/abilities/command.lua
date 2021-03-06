local command = lib.object.create():include(lib.ability)

function command:getColor()
  local entity = lib.target.objectAtPosition(app.context.view:worldPoint(love.mouse.getPosition()))
  if entity then
    if entity.isEnemy then
      return { 255, 140, 140 }
    elseif entity.isShruju then
      return { 220, 220, 140 }
    else
      return { 140, 255, 140 }
    end
  else
    return { 140, 255, 140 }
  end
end

function command:canCast()
  return true
end

function command:cast(x, y)
end

return command
