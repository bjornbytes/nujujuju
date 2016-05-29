local shruju = lib.object.create():include(lib.entity)

function shruju:init()
  self.carrier = nil

  local animationKey = 'shruju' .. love.math.random(1, 5)
  local animation = app.shruju.animations[animationKey]
  self.animation = lib.animation.create(animation.spine, animation.config)
  self.animation:set('idle')
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

  g.white(50)
  g.draw(image, self.position.x, self.position.y, 0, scale, scale / 2, image:getWidth() / 2, image:getHeight() / 2)

  self:drawRing(40, 200, 40)

  self.animation:tick(lib.tick.delta)
  self.animation:draw(self.position.x, self.position.y)

  return -self.position.y
end

return shruju
