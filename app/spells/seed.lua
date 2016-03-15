local seed = lib.object.create():include(lib.entity)

seed.config = {
  speed = 400,
  radius = 6,
  shape = 'circle'
}

function seed:init()
  self.position = {
    x = app.context.scene.width / 2,
    y = app.context.scene.height / 2,
  }
  self.collisions = app.context.collision:add(self)
end

function seed:bind()
  return {
    love.update
      :subscribe(function()
        self:moveInDirection(self.direction, self.config.speed)
      end),

    self.collisions
      :filter(function(other) return other.isMinion or other == app.context.objects.muju end)
      :subscribe(function(other)
        other:hurt(1, self.owner)
        self:unbind()
        app.context:removeObject(self)
      end),

    love.update
      :filter(self:wrap(self.isEscaped))
      :subscribe(self:wrap(self.remove)),

    app.context.view.draw
      :subscribe(function()
        g.white()
        g.circle('fill', self.position.x, self.position.y, self.config.radius)
        return -self.position.y
      end)
  }
end

return seed
