local muju = lib.object.create():include(lib.entity, lib.muju)

function muju:init()
  self.team = 'player'
  self.position = {
    x = app.context.scene.width / 2,
    y = app.context.scene.height / 2
  }
  self.health = muju.config.maxHealth
  self.juju = 0
  self.totalJuju = 0
  self.dead = false

  self.animation = lib.animation.create(app.muju.spine, app.muju.animation)
  self.animation.speed = 1
  self.animation.flipped = true
  self.animation:set('idle')
end

function muju:bind()
  self:tint(.5, .2, .7)
  self.collisions = app.context.collision:add(self)

  self.abilities = {
    app.abilities.summon:new({ owner = self }),
    app.abilities.heal:new({ owner = self })
  }

  self.activeAbility = self.abilities[1]

  return {
    app.context.view.draw
      :subscribe(self:wrap(self.draw))
  }
end

return muju
