local blink = lib.object.create()

function blink:bind()
  lib.input
    :filter(f.self(self.canUse, self))
    :pluck('spells', self.state.position)
    :changes()
    :filter(f.eq(true))
    :subscribe(function()
      print('blink')
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
