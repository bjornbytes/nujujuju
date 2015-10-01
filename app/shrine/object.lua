local shrine = lib.object.create()

function shrine:bind()
  love.draw
    :subscribe(function()
      local props, state = app.shrine.props, self.state
      local image = app.shrine.image
      local scale = app.grid.props.size / image:getWidth()
      g.setColor(255, 255, 255)
      g.draw(image, state.x, state.y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

      --[[g.setColor(255, 255, 255, 80)
      g.circle('fill', state.x, state.y, props.radius, 50)
      g.setColor(255, 255, 255, 255)
      g.setLineWidth(2)
      g.circle('line', state.x, state.y, props.radius, 50)
      g.setLineWidth(1)]]
    end)

  return self
end

return shrine
