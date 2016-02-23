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
    dead = false,
    squishFactor = 0,
    squishActive = false
  }

  state.animation = lib.animation.create(app.muju.spine, app.muju.animation)
  state.animation.speed = 1
  state.animation.flipped = true
  state.animation:set('idle')

  state.abilities = {}
  state.abilities.auto = app.muju.abilities.summon:new()

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

    love.mousepressed
      :filter(function(x, y, b) return b == 1 end)
      :subscribe(function(x, y, b)
        self.squishActive = true
        lib.flux.to(self, .3, { squishFactor = 1 }):ease('backinout')
      end),

    love.mousereleased
      :filter(function(x, y, b) return b == 1 end)
      :subscribe(function(x, y, b)
        self.squishActive = false
        lib.flux.to(self, .3, { squishFactor = 0 }):ease('cubicout')
      end),

    self.collisions
      :subscribe(self:wrap(self.onCollision))
  })

  app.context.view.draw:subscribe(self:wrap(self.draw))
end

return muju
