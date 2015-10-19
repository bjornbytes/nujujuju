local muju = lib.object.create()

muju:include(lib.muju)

muju.config = app.muju.config

muju.state = function()
  local state = {
    team = 'player',
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
    lastHurt = -math.huge,
    health = 3,
    juju = 3,
    shuffle = love.audio.play(app.muju.sound.shuffle),
    nearbyBuilding = nil,
    jujuTrickleTimer = 0
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

  lib.input
    :pluck('building')
    :changes()
    :filter(f.eq(true))
    :subscribe(self:wrap(self.interactWithBuilding))

  love.update
    :subscribe(self:wrap(self.flipAnimation))

  love.update
    :subscribe(self:wrap(self.setShuffleVolume))

  love.update
    :subscribe(self:wrap(self.setActiveBuilding))

  love.update
    :subscribe(self:wrap(self.jujuTrickle))

  self.animations.thuju.events
    :pluck('data', 'name')
    :filter(f.eq('spawn'))
    :subscribe(self:wrap(lib.thuju.createSpawnParticles))

  self.animations.thuju.events
    :pluck('data', 'name')
    :filter(f.eq('attack'))
    :subscribe(self:wrap(self.eventAttack))

  self.animations.muju.events
    :pluck('data', 'name')
    :filter(f.eq('step'))
    :subscribe(self:wrap(self.eventFootstep))

  self.animations.muju.events
    :pluck('data', 'name')
    :filter(f.eq('staff'))
    :subscribe(self:wrap(self.eventLimp))

  self.animations.muju.events
    :pluck('data', 'name')
    :filter(f.eq('attack'))
    :subscribe(self:wrap(self.eventAttack))

  self.collisions = app.context.collision:add(self)

  self.collisions
    :subscribe(function(other, dx, dy)
      other.position.x = other.position.x + dx / 2
      other.position.y = other.position.y + dy / 2
      self.position.x = self.position.x - dx / 2
      self.position.y = self.position.y - dy / 2
    end)

  app.context.view.draw:subscribe(self:wrap(self.draw))
end

return muju
