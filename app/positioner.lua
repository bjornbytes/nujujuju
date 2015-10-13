local positioner = lib.object.create()

function positioner:bind()
  local obj = self.object
  local function isLeft(_, _, b) return b == 'l' end
  local mousepress = love.mousepressed:filter(isLeft)
  local mouserelease = love.mousereleased:filter(isLeft)
  local dx, dy
  local function projectToWorldCoordinates(x, y) return app.context.view:worldPoint(x, y) end

  mousepress
    :map(projectToWorldCoordinates)
    :tap(function(x, y)
      dx = x - obj.position.x
      dy = y - obj.position.y
    end)
    :map(function()
      return love.mousemoved:takeUntil(mouserelease)
    end)
    :flatten()
    :map(projectToWorldCoordinates)
    :subscribe(function(x, y)
      obj.position.x = x - dx
      obj.position.y = y - dy
      --obj:setAnchor()
    end)
end

return positioner
