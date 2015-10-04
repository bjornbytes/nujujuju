local blink = lib.object.create()

function blink:bind()
  lib.input
    :filter(f.self(self.canUse, self))
    :pluck('spells', self.state.position)
    :changes()
    :filter(f.eq(true))
    :subscribe(function()
      app.scene.objects.muju:updateState(function(state)
        state.position.x = state.position.x + 100 * (state.speed.x > 0 and 1 or -1)
      end)

      self:updateState(function(state)
        state.timer = 1
      end)
    end)

  love.update
    :subscribe(function()
      self:updateState(function(state)
        state.timer = state.timer - math.min(state.timer, lib.tick.rate)
      end)
    end)

  return self
end

function blink:canUse()
  return self.state.timer == 0
end

return blink
