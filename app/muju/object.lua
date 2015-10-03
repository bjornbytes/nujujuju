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

  for _, object in ipairs({'shrine', 'dirt'}) do
    self:subscribeCollision(object, app.muju.actions.resolveCollision(self, app.scene.objects[object]))
  end

  love.draw:subscribe(app.muju.actions.draw(self))

  return self
end

function muju:subscribeCollision(name, fn)
  local object = app.scene.objects[name]
  local myProps = app.muju.props
  local theirProps = app[name].props
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
