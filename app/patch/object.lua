local patch = lib.object.create()

patch.props = {
  blob = app.environment.blob
}

function patch:bind()
  self:initCanvas()

  app.scene.view.draw
    :subscribe(function()
      local props, state = patch.props, self.state
      g.setColor(255, 255, 255)
      g.draw(state.canvas, state.x, state.y, state.angle, 1, .5, state.canvas:getWidth() / 2, state.canvas:getHeight() / 2)
    end)
end

function patch:initCanvas()
  local props, state = patch.props, self.state

  state.canvas = g.newCanvas(512, 512)
  g.setCanvas(self.state.canvas)

  g.setColor(255, 255, 255)
  local image = state.texture
  local scale = state.canvas:getWidth() / image:getWidth()
  g.draw(self.state.texture, 0, 0, 0, scale, scale)

  g.setBlendMode('subtractive')
  image = props.blob
  scale = state.canvas:getWidth() / image:getWidth()
  g.setColor(255, 255, 255, 255)
  g.draw(image, 0, 0, 0, scale, scale)
  g.setBlendMode('alpha')

  g.setCanvas()
end

return patch