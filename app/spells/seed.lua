local seed = lib.object.create():include(lib.entity)

seed.config = {
  speed = 400,
  size = 6
}

function seed:init()

end

function seed:bind()
  return {
    love.update
      :subscribe(function()
        self:moveInDirection(self.direction, self.config.speed)
      end),

    love.update
      :filter(self:wrap(self.isEscaped))
      :subscribe(self:wrap(self.remove)),

    app.context.view.draw
      :subscribe(function()
        g.white()
        g.circle('fill', self.position.x, self.position.y, self.config.size)
        return -self.position.y
      end)
  }
end

return seed
