local dirt = lib.object.create()

function dirt:bind()
  love.draw
    :subscribe(function()
      local image = app.dirt.image
      local scale = app.grid.props.size / image:getWidth()
      g.setColor(255, 255, 255)
      g.draw(image, self.state.x, self.state.y, 0, scale, scale)
    end)

  return self
end

return dirt
