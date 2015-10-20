local enemy = lib.object.create()

enemy:include(lib.obstacle)
enemy:include(lib.enemy)
enemy:include(lib.entity)

enemy.config = app.enemy.config

enemy.state = function()
  local state = {
    team = 'enemy',
    kind = 'spuju',
    health = app.enemy.config.maxHealth,
    animation = lib.animation.create(app.spuju.spine, app.spuju.animation),
    pushes = {},
    lastHurt = -math.huge
  }

  return state
end

function enemy:bind()
  self:setIsEnemy()
  self:setIsSolid()

  local ai = app[self.kind].ai
  self.ai = ai:new({owner = self})

  self.animation:set('idle')

  app.context.collision:add(self)

  self:dispose({
    love.update
      :subscribe(self:wrap(self.updatePushes)),

    love.update
      :subscribe(self:wrap(self.enclose)),

    app.context.view.draw
      :subscribe(self:wrap(self.draw)),

    app.context.view.hud
      :subscribe(self:wrap(self.hud))
  })
end

function enemy:unbind()
  app.context.collision:remove(self)
  app.context:removeObject(self)
  return lib.object.unbind(self)
end

return enemy
