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

      app.art.heartFrame:setFilter('nearest')
      app.art.heart:setFilter('nearest')
      app.art.heartHalf:setFilter('nearest')

      local healthbars = {}
      healthbars = util.concat(healthbars, { app.context.objects.muju })
      healthbars = util.concat(healthbars, util.filter(app.context.objects, 'isMinion'))
      healthbars = util.concat(healthbars, util.filter(app.context.objects, 'isEnemy'))

      util.each(healthbars, function(unit)
        self:drawHealthbar(unit)
      end)

      return -1000
    end)

  return self
end

function hud:drawHealthbar(unit)
  g.white(180)

  local size = app.art.heart:getWidth()
  local inc = size + 2
  local x = unit.position.x - (inc * (unit.config.maxHealth - 1) / 2)
  local y = unit.position.y - 80

  for i = 1, unit.config.maxHealth do
    g.draw(app.art.heartFrame, x, y, 0, 1, 1, size / 2, size / 2)

    if unit.health >= i then
      g.draw(app.art.heart, x, y, 0, 1, 1, size / 2, size / 2)
    end

    x = x + inc
  end
end

return hud
