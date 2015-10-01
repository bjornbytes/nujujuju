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
    }
  }

  state.animation = lib.animation.create(app.muju.spine, app.muju.animation)

  return state
end

function muju:bind()
  lib.input:subscribe(app.muju.actions.move(self))

  love.update:map(function() return self.state end)
    :pluck('speed', 'x')
    :filter(f.negate(f.eq(0)))
    :subscribe(app.muju.actions.flip(self))

  self.state.animation.events
    :pluck('data', 'name')
    :filter(f.chain(f.any, f.eq('stepone'), f.eq('steptwo')))
    :subscribe(app.muju.actions.footstep)

  self.state.animation.events
    :pluck('data', 'name')
    :filter(f.eq('staff'))
    :subscribe(app.muju.actions.limp(self))

  love.update:subscribe(app.muju.actions.animate(self))

  love.update
    :map(function()
      local self, other = self.state.position, app.scene.objects.shrine.state
      local distance, direction = math.distance(self.x, self.y, other.x, other.y), math.direction(self.x, self.y, other.x, other.y)
      return self, other, distance, direction
    end)
    :filter(function(self, other, distance, direction)
      return distance < app.muju.props.radius + app.shrine.props.radius
    end)
    :map(function(self, other, distance, direction)
      local delta = (app.muju.props.radius + app.shrine.props.radius) - distance
      return delta * math.cos(direction), delta * math.sin(direction)
    end)
    :subscribe(function(dx, dy)
      local props, state = app.muju.props, self.state
      state.position.x = math.lerp(state.position.x, state.position.x - dx, 8 * lib.tick.rate)
      state.position.y = math.lerp(state.position.y, state.position.y - dy, 8 * lib.tick.rate)
      self:setState(state)
    end)

  love.draw:subscribe(app.muju.actions.draw(self))

  return self
end

return muju
