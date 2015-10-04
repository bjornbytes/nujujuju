local environment = lib.object.create()

function environment:bind()
  love.draw
    :subscribe(function()
      local state = self.state
      g.setColor(255, 255, 255)
      g.drawCenter(state.image, state.size, state.x, state.y)

      return -state.y
    end)

  return self
end

return environment
