local shrine = lib.object.create()

shrine.props = {
  image = art.shrine
}

function shrine:bind()
  love.draw
    :subscribe(function()
      local scale = app.grid.props.size / self.props.image:getWidth()
      g.setColor(255, 255, 255)
      g.draw(self.props.image, self.state.x, self.state.y, 0, scale, scale)
    end)
end

return shrine
