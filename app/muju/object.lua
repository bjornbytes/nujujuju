local muju = lib.object.create()

muju.state = function()
  local state = {
    position = {
      x = app.scene.width / 2,
      y = 301
    },
    speed = {
      x = 0,
      y = 0
    },
    form = 'muju',
    lastShapeshift = -math.huge,
    shuffle = love.audio.play(app.muju.sound.shuffle)
  }

  state.shuffle:setVolume(0)
  state.shuffle:setLooping(true)

  state.animations = {}
  state.animations.muju = lib.animation.create(app.muju.spine, app.muju.animation)
  state.animations.thuju = lib.animation.create(app.thuju.spine, app.thuju.animation)

  state.animation = state.animations.muju

  state.abilities = lib.abilities.create()
  state.abilities:add('blink')

  return state
end

function muju:bind()
  lib.input:subscribe(app.muju.actions.move(self))

  app.muju.actions.tint(self, .5, .2, .7)

  lib.input
    :filter(app.muju.actions.canShapeshift(self))
    :pluck('shapeshift')
    :changes()
    :filter(f.eq(true))
    :subscribe(function()
      self.form = self.form == 'muju' and 'thuju' or 'muju'
      self.animation = self.animations[self.form]
      if self.form == 'thuju' then
        self.animation:clear()
        self.animation:reset('spawn')
        self.animation:add('idle')
      end
      self.lastShapeshift = lib.tick.index
    end)

  lib.input
    :pluck('attack')
    :changes()
    :filter(f.eq(true))
    :subscribe(function()
      self.animation:set('attack')
      self.animation:add('idle')
    end)

  love.update
    :subscribe(function()
      local props = app.muju.props
      local speed = math.sqrt((self.speed.x ^ 2) + (self.speed.y ^ 2)) / props.speed
      self.shuffle:setVolume(speed * props.shuffleVolume)
    end)

  love.update:subscribe(app.muju.actions.flip(self))

  self.animations.thuju.events
    :pluck('data', 'name')
    :filter(f.eq('spawn'))
    :subscribe(function()
      local x = self.position.x
      local y = self.position.y
      app.scene.particles:emit('thujustep', x, y, 30, function()
        return { direction = love.math.random() < .5 and math.pi or 0 }
      end)
    end)

  self.animations.muju.events
    :pluck('data', 'name')
    :filter(f.eq('step'))
    :subscribe(app.muju.actions.footstep)

  self.animations.muju.events
    :pluck('data', 'name')
    :filter(f.eq('staff'))
    :subscribe(app.muju.actions.limp(self))

  love.update
    :with(lib.input)
    :subscribe(app.muju.actions.animate(self))

  for _, object in ipairs({'shrine', 'dirt'}) do
    self:subscribeCollision(object, app.muju.actions.resolveCollision(self, app.scene.objects[object]))
  end

  app.scene.view.draw:subscribe(app.muju.actions.draw(self))

  return self
end

function muju:subscribeCollision(name, fn)
  local object = app.scene.objects[name]
  local myProps = app.muju.props
  local theirProps = app[name] and app[name].props or app.obstacle.props
  return love.update
    :map(function()
      local self, other = self.position, object.position
      local distance = math.distance(self.x, self.y, other.x, other.y)
      local direction = math.direction(self.x, self.y, other.x, other.y)
      return distance, direction
    end)
    :filter(function(distance, direction)
      return distance < myProps.radius + theirProps.radius * math.abs(math.cos(direction))
    end)
    :map(function(distance, direction)
      local delta = (myProps.radius + theirProps.radius) - distance
      return delta * math.cos(direction), delta * math.sin(direction) * math.abs(math.cos(direction))
    end)
    :subscribe(fn)
end

return muju
