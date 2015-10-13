local enemy = lib.object.create()

enemy:include(lib.obstacle)
enemy:include(lib.enemy)

enemy.config = app.enemy.config

enemy.state = function()
  return {
    health = app.enemy.config.maxHealth,
    animation = lib.animation.create(app.spuju.spine, app.spuju.animation),
    pushes = {}
  }
end

function enemy:bind()
  self:setIsSolid()
  self.animation:set('idle')

  self:dispose({
    love.update
      :subscribe(self:wrap(self.updatePushes)),

    app.context.view.draw
      :subscribe(self:wrap(self.draw))
  })
end

function enemy:unbind()
  app.context.objects.enemy = nil
  return lib.object.unbind(self)
end

return enemy
