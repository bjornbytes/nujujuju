local muju = lib.object.create()

muju.state = function()
  local state = {
    position = {
      x = 400,
      y = 300
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

  return state
end

function muju:bind()
  lib.input:subscribe(app.muju.actions.move(self))

  app.muju.actions.tint(self, .5, .2, .7)

  self.abilities = lib.abilities.create()
  self.abilities:add('blink')

  lib.input
    :filter(app.muju.actions.canShapeshift(self))
    :pluck('shapeshift')
    :changes()
    :filter(f.eq(true))
    :subscribe(function()
      local state = self.state
      state.form = state.form == 'muju' and 'thuju' or 'muju'
      state.animation = state.animations[state.form]
      if state.form == 'thuju' then
        state.animation:clear()
        state.animation:reset('spawn')
        state.animation:add('idle')
      end
      state.lastShapeshift = lib.tick.index
      self:setState(state)
    end)

  lib.input
    :pluck('attack')
    :changes()
    :filter(f.eq(true))
    :subscribe(function()
      self.state.animation:set('attack')
      self.state.animation:add('idle')
    end)

  love.update
    :map(function() return self.state end)
    :subscribe(function()
      local props, state = app.muju.props, self.state
      local speed = math.sqrt((state.speed.x ^ 2) + (state.speed.y ^ 2)) / props.speed
      state.shuffle:setVolume(speed * props.shuffleVolume)
    end)

  love.update:map(function() return self.state end)
    :pluck('speed', 'x')
    :filter(f.negate(f.eq(0)))
    :subscribe(app.muju.actions.flip(self))

  self.state.animation.events
    :pluck('data', 'name')
    :filter(f.eq('step'))
    :subscribe(app.muju.actions.footstep)

  self.state.animation.events
    :pluck('data', 'name')
    :filter(f.eq('staff'))
    :subscribe(app.muju.actions.limp(self))

  love.update
    :with(lib.input)
    :subscribe(app.muju.actions.animate(self))

  for _, object in ipairs({'shrine', 'dirt', 'rock1', 'rock2', 'rock3', 'rock4', 'bush'}) do
    self:subscribeCollision(object, app.muju.actions.resolveCollision(self, app.scene.objects[object]))
  end

  love.draw:subscribe(app.muju.actions.draw(self))

  return self
end

function muju:subscribeCollision(name, fn)
  local object = app.scene.objects[name]
  local myProps = app.muju.props
  local theirProps = app[name] and app[name].props or app.obstacle.props
  return love.update
    :map(function()
      local self, other = self.state.position, object.state.position
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
