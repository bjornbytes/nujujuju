local dirt = lib.object.create()

function dirt:bind()
  local xstart, ystart = self.state.x, self.state.y

  love.update
    :subscribe(function()
      self:updateState(function(state)
        state.x = math.lerp(state.x, xstart, 16 * lib.tick.rate)
        state.y = math.lerp(state.y, ystart, 16 * lib.tick.rate)
      end)
    end)

  love.draw
    :subscribe(function()
      local props, state = app.dirt.props, self.state
      local image = app.dirt.image
      local scale = app.grid.props.size / image:getWidth()
      g.setColor(255, 255, 255)
      g.draw(image, state.x, state.y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

      return -state.y
    end)

  return self
end

return dirt
