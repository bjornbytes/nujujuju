local grid = lib.object.create()

grid.props = {
  size = 55
}

function grid:bind()
  self.bg = app.environment.grass
  self.bg:setWrap('repeat', 'repeat')
  self.quad = g.newQuad(0, 0, g.getWidth(), g.getHeight() * 2, self.bg:getDimensions())

  app.scene.view.draw
    :subscribe(function()
      local w, h = g.getDimensions()

      g.setColor(255, 255, 255)
      g.draw(self.bg, self.quad, 0, 0, 0, 1, .5)
    end)
end

return grid:new({
  debug = false
})
