local blink = lib.object.create()

blink:include(lib.ability)

function blink:bind()
  lib.input
    :filter(self:wrap(self.canCast))
    :pluck('spells', self.position)
    :changes()
    :filter(f.eq(true))
    :subscribe(self:wrap(self.cast))

  love.update
    :subscribe(self:wrap(self.decayTimer))

  return self
end

function blink:canCast()
  return self.timer == 0
end

function blink:cast()
  local muju = app.context.objects.muju
  muju.position.x = muju.position.x + 100 * (muju.speed.x > 0 and 1 or -1)
  self.timer = 1
end

return blink
