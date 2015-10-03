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
    shuffle = love.audio.loop(app.muju.sound.shuffle)
  }

  shuffle:setVolume(.25)
  shuffle:setLooping(true)

  state.animation = lib.animation.create(app.muju.spine, app.muju.animation)

  return state
end

function muju:bind()
  lib.input:subscribe(app.muju.actions.move(self))

  self:tint(.5, .2, .7)

  love.update
    :map(function() return self.state end)
    :subscribe(function()
      local state
      local speed = math.sqrt((state.speed.x ^ 2) + (state.speed.y ^ 2)) / props.speed
      state.shuffle:setVolume(speed)
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

  self.state.animation.events
    :pluck('data', 'name')
    :filter(f.eq('stop'))
    :subscribe(function()
      self.state.animation:set('idle')
    end)

  love.update:subscribe(app.muju.actions.animate(self))

  for _, object in ipairs({'shrine', 'dirt', 'rock1', 'rock2', 'rock3', 'rock4', 'bush'}) do
    self:subscribeCollision(object, app.muju.actions.resolveCollision(self, app.scene.objects[object]))
  end

  love.draw:subscribe(app.muju.actions.draw(self))

  return self
end

function muju:tint(r, g, b)
  for _, slot in pairs({'robebottom', 'torso', 'front_upper_arm', 'rear_upper_arm', 'front_bracer', 'rear_bracer'}) do
    local slot = self.state.animation.skeleton:findSlot(slot)
    slot.r, slot.g, slot.b = r, g, b
  end
end

function muju:subscribeCollision(name, fn)
  local object = app.scene.objects[name]
  local myProps = app.muju.props
  local theirProps = app[name] and app[name].props or app.obstacle.props
  return love.update
    :map(function()
      local self, other = self.state.position, object.state
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
