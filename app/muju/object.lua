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

  love.update:subscribe(app.muju.actions.animate(self))

  love.draw:subscribe(app.muju.actions.render(self))

  return self
end

return muju
