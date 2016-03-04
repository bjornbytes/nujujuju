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

  self:dispose({
    love.update
      :subscribe(function()
        local muju = app.context.objects.muju
        self.prevJujuFactor = self.jujuFactor
        local percent = muju.totalJuju / 50
        self.jujuFactor = util.lerp(self.jujuFactor, percent, lib.tick.getLerpFactor(.6))
      end),

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

        self:drawJuju()
        self:drawPopulation()

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

        self:drawAbilities()

        return -1000
      end)
  })

  return self
end

function hud:getElement(mx, my)
  local selected = app.context.input.selected
  if selected and selected.abilities then
    local u, v = self.u, self.v
    local size = .06 * u
    local inc = .08 * u
    local count = #selected.abilities
    local x = u / 2 - (inc * (count - 1) / 2)

    for i = 1, count do
      if util.inside(mx, my, x - size / 2, 8, size, size) then
        return 'ability', i
      end

      x = x + inc
    end
  end

  return nil
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

function hud:drawJuju()
  local p = app.context.objects.muju
  local image = app.art.juju
  local scale = 20 / image:getWidth()
  local inc = 20 + 6
  local x = 6

  for i = 1, p.maxJuju do
    if p.juju >= i then
      g.white()
    else
      g.white(80)
    end

    g.draw(image, x, 6, 0, scale, scale)
    x = x + inc
  end
end

function hud:drawPopulation()
  local p = app.context.objects.muju
  local image = app.art.population
  local scale = 20 / image:getWidth()
  local inc = 20 + 6
  local x = g.getWidth() - (inc * p.config.maxMinions) - 6
  local minionCount = #util.filter(app.context.objects, 'isMinion')

  for i = 1, p.config.maxMinions do
    if minionCount >= i then
      g.setColor(255, 153, 153)
    else
      g.setColor(153, 223, 255)
    end

    g.draw(image, x, 6, 0, scale, scale)
    x = x + inc
  end
end

function hud:drawAbilities()
  local selected = app.context.input.selected
  if selected and selected.abilities then
    local u, v = self.u, self.v
    local size = .06 * u
    local inc = .08 * u
    local count = #selected.abilities
    local x = u / 2 - (inc * (count - 1) / 2)

    g.setColor(0, 0, 0, 150)

    for i = 1, count do
      g.rectangle('fill', x - size / 2, 8, size, size)
      x = x + inc
    end
  end
end

return hud
