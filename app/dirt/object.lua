local dirt = lib.object.create()

function dirt:bind()
  local xstart, ystart = self.state.position.x, self.state.position.y

  love.update
    :subscribe(function()
      self:updateState(function(state)
        state.position.x = math.lerp(state.position.x, xstart, 16 * lib.tick.rate)
        state.position.y = math.lerp(state.position.y, ystart, 16 * lib.tick.rate)
      end)
    end)

  app.scene.view.draw
    :subscribe(function()
      local props, state = app.dirt.props, self.state
      local image = app.dirt.image
      local scale = props.size / image:getWidth()
      g.setColor(255, 255, 255)
      g.draw(image, state.position.x, state.position.y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

      return -state.position.y
    end)

  return self
end

return dirt
