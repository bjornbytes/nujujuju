local thuju = {}

function thuju:createSpawnParticles()
  app.context.particles:emit('thujustep', self.position.x, self.position.y, 30, function()
    return { direction = love.math.random() < .5 and math.pi or 0 }
  end)
end

return thuju