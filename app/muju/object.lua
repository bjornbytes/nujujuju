local muju = lib.object.create()

muju.state = function()
  local state = {
    x = 400,
    y = 300,
    speed = {
      x = 0,
      y = 0
    },
    facing = {x = 1, y = 1},
    transformed = false,
    bob = 0,
    footstep = 0
  }

  state.animation = lib.animation.create(app.muju.spine, app.muju.animation)

  return state
end

function muju:bind()
  love.update
    :map(function()
      return {
        love.keyboard.isDown('w'),
        love.keyboard.isDown('a'),
        love.keyboard.isDown('s'),
        love.keyboard.isDown('d')
      }
    end)
    :unpack()
    :subscribe(f.self(self.move, self))

  self.state.animation.events
    :pluck('data', 'name')
    :filter(f.chain(f.any, f.eq('stepone'), f.eq('steptwo')))
    :subscribe(self.footstep)

  love.update
    :map(function() return self end)
    :subscribe(self.animate)

  love.draw
    :subscribe(function()
      local props, state = app.muju.props, self.state

      local image = state.facing.y == 1 and app.muju.art.front or app.muju.art.front
      local scale = 2 * props.radius / image:getWidth() * 1.5
      local bob = math.sin(state.bob * props.bob.rate) * props.bob.strength / 2
      g.setColor(255, 255, 255)
      state.animation.flipped = state.facing.x == 1
      state.animation:tick(lib.tick.delta)
      state.animation:draw(state.x, state.y + 10 + bob)
      --g.draw(image, state.x, state.y + 10 + bob, 0, scale * state.facing.x, scale, props.origin.x, props.origin.y)
    end)

  return self
end

function muju:move(w, a, s, d)
  local dx, dy

  if a and not d then
    dx = -1
  elseif d then
    dx = 1
  end

  if w and not s then
    dy = -1
  elseif s then
    dy = 1
  end

  local props, state = app.muju.props, self.state
  local direction = math.atan2(dy or 0, dx or 0)

  if not dx and not dy then
    state.speed.x = math.lerp(state.speed.x, 0, props.acceleration * lib.tick.rate)
    state.speed.y = math.lerp(state.speed.y, 0, props.acceleration * lib.tick.rate)
  else
    state.speed.x = math.lerp(state.speed.x, props.speed * math.cos(direction), 10 * lib.tick.rate)
    state.speed.y = math.lerp(state.speed.y, props.speed * math.sin(direction), 10 * lib.tick.rate)

    state.facing.x = dx or state.facing.x
    state.facing.y = dy or state.facing.y
    state.bob = state.bob + lib.tick.rate
  end

  state.x = state.x + state.speed.x * lib.tick.rate
  state.y = state.y + state.speed.y * lib.tick.rate
  self:setState(state)
end

function muju:footstep()
  local sound = love.audio.play(app.muju.sound['footstep' .. love.math.random(1, 2)])
  sound:setVolume(.5)
  sound:setPitch(.9 + love.math.random() * .2)
end

function muju:animate()
  local props, state = app.muju.props, self.state
  local speed = math.sqrt((state.speed.x ^ 2) + (state.speed.y ^ 2)) / props.speed
  state.animation.speed = speed > .1 and speed or 1
  state.animation:set(speed > .1 and 'walk' or 'idle')
end

return muju
