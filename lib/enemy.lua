local enemy = {}

function enemy:setIsEnemy()
  self.isEnemy = true
end

function enemy:remove()
  local juju = app.juju:new({
    position = {
      x = self.position.x,
      y = self.position.y
    }
  })

  app.context.objects[juju] = juju

  lib.unit.remove(self)
end

return enemy
