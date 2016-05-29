local shruju = lib.object.create()

function shruju:init()
  self.carrier = nil
end

function shruju:bind()
  return {
    love.update
      :filter(function() return self.carrier end)
      :subscribe(function()
        self.position.x = self.carrier.postiion.x
        self.position.y = self.carrier.postiion.y
      end),

    app.context.view.draw
      :subscribe(self:wrap(self.draw))
  }
end

function shruju:draw()
  local image = app.art.shadow
  local size = self.config.radius * 3
  local scale = g.imageScale(image, size)

  g.white()
  g.draw(image, self.position.x, self.position.y, 0, scale, scale / 2, image:getWidth() / 2, image:getHeight() / 2)

  g.circle('fill', self.position.x, self.position.y, shruju.config.radius)

  return -self.position.y
end

return shruju
