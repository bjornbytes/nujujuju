local grid = lib.object.create()

grid.props = {
  size = 55
}

function grid:bind()
  love.update
    :subscribe(function()
      self:setState({
        debug = love.keyboard.isDown('`')
      })
    end)

  love.draw
    :subscribe(function()
      local w, h = g.getDimensions()

      g.setColor(35, 35, 35)
      g.rectangle('fill', 0, 0, w, h)

      if not self.state.debug then return end

      g.setColor(255, 255, 255, 50)

      local size = self.props.size
      for x = size, w, size do
        g.line(x, 0, x, h)
      end

      for y = size, h, size do
        g.line(0, y, w, y)
      end
    end)
end

return grid:new({
  debug = false
})
