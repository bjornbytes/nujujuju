local patch = lib.object.create()

patch.props = {
  blob = app.environment.blob
}

function patch:bind()
  self:initCanvas()

  app.scene.view.draw
    :subscribe(function()
      local props = patch.props
      g.setColor(255, 255, 255)
      g.draw(self.canvas, self.x, self.y, self.angle, 1, .5, self.canvas:getWidth() / 2, self.canvas:getHeight() / 2)
    end)
end

function patch:initCanvas()
  local props = patch.props

  self.canvas = g.newCanvas(512, 512)
  g.setCanvas(self.canvas)

  g.setColor(255, 255, 255)
  local image = self.texture
  local scale = self.canvas:getWidth() / image:getWidth()
  g.draw(self.texture, 0, 0, 0, scale, scale)

  g.setBlendMode('subtractive')
  image = props.blob
  scale = self.canvas:getWidth() / image:getWidth()
  g.setColor(255, 255, 255, 255)
  g.draw(image, 0, 0, 0, scale, scale)
  g.setBlendMode('alpha')

  g.setCanvas()
end

return patch