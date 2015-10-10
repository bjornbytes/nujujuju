local muju = lib.object.create()

muju:include(lib.muju)

muju.config = app.muju.config

muju.state = function()
  local state = {
    position = {
      x = app.context.scene.width / 2,
      y = 301
    },
    speed = {
      x = 0,
      y = 0
    },
    form = 'muju',
    lastShapeshift = -math.huge,
    health = 5,
    juju = 3,
    shuffle = love.audio.play(app.muju.sound.shuffle)
  }

  state.shuffle:setVolume(0)
  state.shuffle:setLooping(true)

  state.animations = {}
  state.animations.muju = lib.animation.create(app.muju.spine, app.muju.animation)
  state.animations.thuju = lib.animation.create(app.thuju.spine, app.thuju.animation)

  state.animation = state.animations.muju

  state.abilities = lib.abilities:new()
  state.abilities:add('blink')

  return state
end

function muju:bind()
  self:tint(.5, .2, .7)

  lib.input
    :subscribe(self:wrap(self.move))

  lib.input
    :filter(self:wrap(self.canShapeshift))
    :pluck('shapeshift')
    :changes()
    :filter(f.eq(true))
    :subscribe(self:wrap(self.shapeshift))

  lib.input
    :pluck('attack')
    :changes()
    :filter(f.eq(true))
    :subscribe(self:wrap(self.attack))

  lib.input
    :subscribe(self:wrap(self.animate))

  love.update
    :subscribe(self:wrap(self.flipAnimation))

  love.update
    :subscribe(self:wrap(self.setShuffleVolume))

  self.animations.thuju.events
    :pluck('data', 'name')
    :filter(f.eq('spawn'))
    :subscribe(self:wrap(lib.thuju.createSpawnParticles))

  self.animations.muju.events
    :pluck('data', 'name')
    :filter(f.eq('step'))
    :subscribe(self:wrap(self.eventFootstep))

  self.animations.muju.events
    :pluck('data', 'name')
    :filter(f.eq('staff'))
    :subscribe(self:wrap(self.eventLimp))

  for _, object in pairs(table.filter(app.context.objects, 'solid')) do
    self:resolveCollisionsWith(object)
  end

  app.context.view.draw:subscribe(self:wrap(self.draw))
end

return muju
