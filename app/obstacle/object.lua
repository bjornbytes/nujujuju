local obstacle = lib.object.create()

function obstacle:bind()
  local xstart, ystart = self.state.position.x, self.state.position.y

  love.update
    :subscribe(function()
      self:updateState(function(state)
        state.position.x = math.lerp(state.position.x, xstart, 24 * lib.tick.rate)
        state.position.y = math.lerp(state.position.y, ystart, 24 * lib.tick.rate)
      end)
    end)

  love.draw
    :subscribe(function()
      local state = self.state
      g.setColor(255, 255, 255)
      g.drawCenter(state.image, state.size, state.position.x, state.position.y)

      return -state.position.y
    end)

  return self
end

return obstacle
