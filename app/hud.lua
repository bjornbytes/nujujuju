local hud = lib.object.create()

hud.config = {
  font = fonts.roundedElegance,
  margin = .03,
  padding = .015
}

hud.state = function()
  return {
    fadeout = 0,
    jujuFactor = 0,
    prevJujuFactor = 0
  }
end

function hud:bind()
  self.u, self.v = g.getDimensions()
  self.font = self.config.font(self.v * .02)

  love.update
    :subscribe(function()
      local muju = app.context.objects.muju
      self.prevJujuFactor = self.jujuFactor
      local percent = muju.totalJuju / 50
      self.jujuFactor = math.lerp(self.jujuFactor, percent, lib.tick.getLerpFactor(.6))
    end)

  app.context.view.hud
    :subscribe(function()

      -- render

      return -1000
    end)

  return self
end

return hud
