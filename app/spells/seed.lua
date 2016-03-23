local seed = lib.object.create():include(lib.entity)

seed.config = {
  speed = 500,
  gravity = 800,
  radius = 6,
  shape = 'circle'
}

function seed:init()
  self.position = {
    x = app.context.scene.width / 2,
    y = app.context.scene.height / 2,
  }
  self.collisions = app.context.collision:add(self)
  self.vz = -100
  self.speed = self.config.speed
  self.alpha = 1
end

function seed:bind()
  self.position.z = -30

  return {
    love.update
      :subscribe(function()
        self:moveInDirection(self.direction, self.speed)
        self.position.z = self.position.z + self.vz * lib.tick.rate
        if self.position.z > 0 then
          self.vz = self.vz * -.75
          self.speed = self.speed / 2
          if math.abs(self.vz) < 20 then
            self.position.z = 0
            self.vz = 0
            self.speed = 0
            lib.flux.to(self, .5, { alpha = 0 })
              :oncomplete(function()
                self:unbind()
                app.context:removeObject(self)
              end)
          end
        else
          self.vz = self.vz + self.config.gravity * lib.tick.rate
        end
      end),

    self.collisions
      :filter(function(other) return other.isMinion or other == app.context.objects.muju end)
      :filter(function() return self.speed > self.config.speed / 2 end)
      :subscribe(function(other)
        other:hurt(self.owner.config.damage, self.owner)
        self:unbind()
        app.context:removeObject(self)
      end),

    love.update
      :filter(self:wrap(self.isEscaped))
      :subscribe(self:wrap(self.remove)),

    app.context.view.draw
      :subscribe(function()
        local image = app.art.shadow
        local scale = g.imageScale(image, 24)

        g.white(60 * self.alpha)
        g.draw(image, self.position.x, self.position.y, self.direction, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

        local image = app.art.seed
        local scale = g.imageScale(image, 16)

        g.white(255 * self.alpha)
        g.draw(image, self.position.x, self.position.y + self.position.z / 2, self.direction, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
        return -self.position.y
      end)
  }
end

return seed
