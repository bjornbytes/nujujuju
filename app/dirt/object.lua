local dirt = lib.object.create()

function dirt:bind()
  local xstart, ystart = self.position.x, self.position.y

  love.update
    :subscribe(function()
      self.position.x = math.lerp(self.position.x, xstart, 16 * lib.tick.rate)
      self.position.y = math.lerp(self.position.y, ystart, 16 * lib.tick.rate)
    end)

  app.scene.view.draw
    :subscribe(function()
      local props = app.dirt.props
      local image = app.dirt.image
      local scale = props.size / image:getWidth()
      g.setColor(255, 255, 255)
      g.draw(image, self.position.x, self.position.y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

      return -self.position.y
    end)

  return self
end

return dirt
