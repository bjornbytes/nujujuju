local spell = {}

function spell:decayTimer()
  self.timer = self.timer - math.min(self.timer, lib.tick.rate)
end

return spell