local environment = lib.object.create()

environment.config = {
  background = {
    image = app.environment.textures.grass,
    perspective = 2
  }
}

function environment:bind()
  self.config.background.image:setWrap('repeat', 'repeat')
  self.quad = g.newQuad(0, 0, g.getWidth(), g.getHeight() * self.config.background.perspective, self.config.background.image:getDimensions())

  app.context.view.draw
    :subscribe(function()
      g.setColor(255, 255, 255)
      g.draw(self.config.background.image, self.quad, 0, 0, 0, 1, 1 / self.config.background.perspective)
    end)
end

return environment
