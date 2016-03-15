local enemy = {}

function enemy:setIsEnemy()
  self.isEnemy = true
end

function enemy:remove()
  app.context:addObject(app.juju, {
    position = {
      x = self.position.x,
      y = self.position.y
    }
  })

  lib.unit.remove(self)
end

return enemy
