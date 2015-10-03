local obstacle = lib.object.create()

function obstacle:bind()
  local xstart, ystart = self.state.x, self.state.y

  love.update
    :subscribe(function()
      self:updateState(function(state)
        state.x = math.lerp(state.x, xstart, 24 * lib.tick.rate)
        state.y = math.lerp(state.y, ystart, 24 * lib.tick.rate)
      end)
    end)

  love.draw
    :subscribe(function()
      local state = self.state
      g.setColor(255, 255, 255)
      g.drawCenter(state.image, state.size, state.x, state.y)

      return -state.y
    end)

  return self
end

return obstacle
