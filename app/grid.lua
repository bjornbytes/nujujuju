local grid = lib.object.create()

grid.props = {
  size = 55
}

function grid:bind()
  self.bg = app.environment.dirt
  self.bg:setWrap('repeat', 'repeat')
  self.quad = g.newQuad(0, 0, g.getWidth(), g.getHeight(), self.bg:getDimensions())

  love.update
    :subscribe(function()
      self:setState({
        debug = love.keyboard.isDown('`')
      })
    end)

  love.draw
    :subscribe(function()
      local w, h = g.getDimensions()

      g.setColor(255, 255, 255)
      g.draw(self.bg, self.quad, 0, 0)

      g.drawCenter(app.environment.bush, 60, 600, 100)
      g.drawCenter(app.environment.rock1, 60, 200, 200)
      g.drawCenter(app.environment.rock2, 60, 700, 500)
      g.drawCenter(app.environment.rock3, 60, 500, 400)
      g.drawCenter(app.environment.rock4, 60, 300, 450)

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
