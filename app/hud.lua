local hud = lib.object.create()

hud:include(lib.hud)

hud.config = {
  font = fonts.existence,
  margin = .03,
  padding = .015
}

function hud:bind()
  self.u, self.v = g.getDimensions()
  self.font = self.config.font(self.v * .05)

  app.context.view.hud
    :subscribe(function()
      g.setFont(self.font)

      --self:drawShapeshiftCooldown()
      --self:drawAbilities()
      self:drawPlayerHealthbar()
      self:drawPlayerJuju()

      return -1000
    end)

  return self
end

return hud
