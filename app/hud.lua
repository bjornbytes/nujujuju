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
  self.font = self.config.font(self.v * .04)

  love.update
    :subscribe(function()
      local muju = app.context.objects.muju
      self.prevJujuFactor = self.jujuFactor
      local percent = muju.totalJuju / 50
      self.jujuFactor = util.lerp(self.jujuFactor, percent, lib.tick.getLerpFactor(.6))
    end)

  app.context.view.hud
    :subscribe(function()

      local p = app.context.objects.muju
      local population = #util.filter(app.context.objects, 'isMinion')
      local maxPop = p.config.maxMinions

      if population < maxPop then
        g.white()
      else
        g.setColor(255, 160, 160)
      end

      g.setFont(self.font)
      g.print(population .. ' / ' .. app.context.objects.muju.config.maxMinions, 4, 4)

      g.setColor(160, 255, 160)
      g.print(p.juju, 4, 4 + g.getFont():getHeight())

      return -1000
    end)

  return self
end

return hud
