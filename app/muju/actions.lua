local actions = {}

function actions.move(self)
  return function(input)
    return self:updateState(function(state)
      local x, y = input.x, input.y
      local props = app.muju.props
      local direction = math.atan2(y, x)
      local length = math.min(math.distance(0, 0, x, y), 1)

      if x == 0 and y == 0 then
        state.speed.x = math.lerp(state.speed.x, 0, math.min(props.acceleration * lib.tick.rate, 1))
        state.speed.y = math.lerp(state.speed.y, 0, math.min(props.acceleration * lib.tick.rate, 1))
      else
        state.speed.x = math.lerp(state.speed.x, props.speed * math.cos(direction) * length, 10 * lib.tick.rate)
        state.speed.y = math.lerp(state.speed.y, props.speed * math.sin(direction) * length, 10 * lib.tick.rate)
      end

      state.position.x = state.position.x + state.speed.x * lib.tick.rate
      state.position.y = state.position.y + state.speed.y * lib.tick.rate
    end)
  end
end

function actions.footstep()
  local sound = love.audio.play(app.muju.sound['footstep' .. love.math.random(1, 2)])
  sound:setVolume(.5)
  sound:setPitch(.9 + love.math.random() * .2)
end

function actions.limp(self)
  return function()
    local state = self.state
    local x = state.position.x + (state.animation.flipped and 40 or -40)
    local y = state.position.y
    app.scene.objects.particles:emit('dust', x, y, 25, function()
      return { direction = love.math.random() < .5 and math.pi or 0 }
    end)
  end
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
    return self:updateState(function(state)
      state.animation.flipped = x > 0
    end)
  end
end

function actions.draw(self)
  return function()
    local props, state = app.muju.props, self.state
    g.setColor(255, 255, 255)
    state.animation:tick(lib.tick.delta)
    state.animation:draw(state.position.x, state.position.y)

    --[[g.setColor(255, 255, 255, 80)
    g.circle('fill', state.position.x, state.position.y, props.radius, 50)
    g.setColor(255, 255, 255, 255)
    g.setLineWidth(2)
    g.circle('line', state.position.x, state.position.y, props.radius, 50)
    g.setLineWidth(1)]]
  end
end

return actions
