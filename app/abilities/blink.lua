local blink = lib.object.create()

function blink:bind()
  lib.input
    :filter(f.self(self.canUse, self))
    :pluck('spells', self.position)
    :changes()
    :filter(f.eq(true))
    :subscribe(function()
      local muju = app.scene.objects.muju
      muju.position.x = muju.position.x + 100 * (muju.speed.x > 0 and 1 or -1)

      self.timer = 1
    end)

  love.update
    :subscribe(function()
      self.timer = self.timer - math.min(self.timer, lib.tick.rate)
    end)

  return self
end

function blink:canUse()
  return self.timer == 0
end

return blink
