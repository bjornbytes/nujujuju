local dirt = lib.object.create()

function dirt:bind()
  love.draw
    :subscribe(function()
      local props, state = app.dirt.props, self.state
      local image = app.dirt.image
      local scale = app.grid.props.size / image:getWidth()
      g.setColor(255, 255, 255)
      g.draw(image, state.x, state.y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
    end)

  return self
end

return dirt
