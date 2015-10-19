local environment = lib.object.create()

environment.config = {
  background = {
    image = app.environment.textures.grass,
    perspective = 2
  }
}

function environment:bind()
  local background = self.config.background
  background.image:setWrap('repeat', 'repeat')
  self.quad = g.newQuad(0, 0, g.getWidth(), g.getHeight() * background.perspective, background.image:getDimensions())

  app.context.view.draw
    :subscribe(function()
      local background = self.config.background
      g.white()
      g.draw(background.image, self.quad, 0, 0, 0, 1, 1 / background.perspective)
    end)
end

return environment
