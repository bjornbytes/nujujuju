local actions = {}

function actions.move(self)
  return function(input)
    local x, y = input.x, input.y
    local props, state = app.muju.props, self.state
    local direction = math.atan2(y, x)

    if x == 0 and y == 0 then
      state.speed.x = math.lerp(state.speed.x, 0, props.acceleration * lib.tick.rate)
      state.speed.y = math.lerp(state.speed.y, 0, props.acceleration * lib.tick.rate)
    else
      state.speed.x = math.lerp(state.speed.x, props.speed * math.cos(direction), 10 * lib.tick.rate)
      state.speed.y = math.lerp(state.speed.y, props.speed * math.sin(direction), 10 * lib.tick.rate)
    end

    state.position.x = state.position.x + state.speed.x * lib.tick.rate
    state.position.y = state.position.y + state.speed.y * lib.tick.rate
    self:setState(state)
  end
end

function actions.footstep()
  local sound = love.audio.play(app.muju.sound['footstep' .. love.math.random(1, 2)])
  sound:setVolume(.5)
  sound:setPitch(.9 + love.math.random() * .2)
end

function actions.animate(self)
  return function()
    local props, state = app.muju.props, self.state
    local speed = math.sqrt((state.speed.x ^ 2) + (state.speed.y ^ 2)) / props.speed
    state.animation.speed = speed > .1 and speed or 1
    state.animation:set(speed > .1 and 'walk' or 'idle')
    self:setState(state)
  end
end

function actions.flip(self)
  return function(x)
    local state = self.state
    state.animation.flipped = x > 0
    self:setState(state)
  end
end

function actions.draw(self)
  return function()
    local props, state = app.muju.props, self.state
    g.setColor(255, 255, 255)
    state.animation:tick(lib.tick.delta)
    state.animation:draw(state.position.x, state.position.y)
  end
end

return actions
