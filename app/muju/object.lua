local muju = lib.object.create()

muju.tag = 'muju'

muju:include(lib.entity)
muju:include(lib.muju)

muju.config = app.muju.config

muju.state = function()
  local state = {
    team = 'player',
    position = {
      x = app.context.scene.width / 2,
      y = app.context.scene.height / 2
    },
    health = muju.config.maxHealth,
    juju = 0,
    totalJuju = 0,
    dead = false,
    squishFactor = 0,
    squishActive = false
  }

  state.animation = lib.animation.create(app.muju.spine, app.muju.animation)
  state.animation.speed = 1
  state.animation.flipped = true
  state.animation:set('idle')

  return state
end

function muju:bind()
  self:tint(.5, .2, .7)
  self.collisions = app.context.collision:add(self)

  self.abilities = {
    app.muju.abilities.summon:new({ owner = self }),
    app.muju.abilities.heal:new({ owner = self })
  }

  self.activeAbility = self.abilities[1]

  return {
    app.context.view.draw
      :subscribe(self:wrap(self.draw))
  }
end

return muju
