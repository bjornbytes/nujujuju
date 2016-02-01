local patch = lib.object.create()

patch.config = {
  blob = app.environment.art.blob
}

function patch:bind()
  self:initCanvas()

  app.context.view.draw
    :subscribe(self:wrap(self.draw))
end

function patch:initCanvas()
  self.canvas = g.newCanvas(512, 512)
  g.setCanvas(self.canvas)

  g.white()
  local image = self.texture
  local scale = self.canvas:getWidth() / image:getWidth()
  g.draw(self.texture, 0, 0, 0, scale, scale)

  g.setBlendMode('subtract')
  image = self.config.blob
  scale = self.canvas:getWidth() / image:getWidth()
  g.white()
  g.draw(image, 0, 0, 0, scale, scale)
  g.setBlendMode('alpha')

  g.setCanvas()
end

function patch:draw()
  local canvas = self.canvas
  g.white()
  g.draw(canvas, self.x, self.y, self.angle, 1, .5, canvas:getWidth() / 2, canvas:getHeight() / 2)
  return -10
end

return patch
