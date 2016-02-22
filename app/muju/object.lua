local muju = lib.object.create()

muju:include(lib.muju)
muju:include(lib.entity)

muju.config = app.muju.config

muju.state = function()
  local state = {
    team = 'player',
    position = {
      x = app.context.scene.width / 2,
      y = app.context.scene.height / 2
    },
    health = 5,
    juju = 5,
    totalJuju = 5,
    jujuTrickleTimer = 0,
    dead = false
  }

  state.animations = {}
  state.animations.muju = lib.animation.create(app.muju.spine, app.muju.animation)

  state.animation = state.animations.muju
  state.animation.speed = 1
  state.animation:set('idle')

  return state
end

function muju:bind()
  self:tint(.5, .2, .7)
  self.collisions = app.context.collision:add(self)

  self:dispose({
    love.update
      :subscribe(self:wrap(self.jujuTrickle)),

    love.update
      :subscribe(self:wrap(self.animate)),

    self.collisions
      :subscribe(self:wrap(self.onCollision))
  })

  app.context.view.draw:subscribe(self:wrap(self.draw))
end

return muju
