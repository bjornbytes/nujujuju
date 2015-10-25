local hud = lib.object.create()

hud:include(lib.hud)

hud.config = {
  font = fonts.roundedElegance,
  margin = .03,
  padding = .015
}

hud.state = function()
  return {
    fadeout = 0
  }
end

function hud:bind()
  self.u, self.v = g.getDimensions()
  self.font = self.config.font(self.v * .02)

  app.context.view.hud
    :subscribe(function()
      g.setFont(self.font)

      self:drawBlood()
      self:drawPlayerHealthbar()
      self:drawPlayerJuju()
      self:drawBuildingUI()
      self:drawFadeout()

      return -1000
    end)

  return self
end

return hud
