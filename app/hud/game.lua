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
        self:drawWaves()

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

  local u, v = self.u, self.v
  local size = .03 * v
  local scale = util.round(size / app.art.heartFrame:getWidth())
  size = scale * app.art.heartFrame:getWidth()
  local inc = size + .004 * v

  local x = unit.position.x
  local y = unit.position.y

  x, y = app.context.view:screenPoint(x, y)

  x = x - (inc * (unit.config.maxHealth - 1) / 2)
  y = y - .15 * v

  for i = 1, unit.config.maxHealth do
    local image = app.art.heartFrame
    g.draw(image, x, y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

    if unit.health >= i then
      local image = app.art.heart
      g.draw(image, x, y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
    end

    x = x + inc
  end
end

function hud:drawJuju()
  local u, v = self.u, self.v
  local p = app.context.objects.muju
  local image = app.art.juju
  local margin = .02 * v
  local scale = (.05 * v) / image:getWidth()
  local inc = .05 * v + margin
  local x = margin

  for i = 1, p.maxJuju do
    if p.juju >= i then
      g.white()
    else
      g.white(80)
    end

    g.draw(image, x, margin, 0, scale, scale)
    x = x + inc
  end
end

function hud:drawPopulation()
  local u, v = self.u, self.v
  local p = app.context.objects.muju
  local image = app.art.population
  local margin = .02 * v
  local scale = (.03 * v) / image:getWidth()
  local inc = (.03 * v) + margin
  local x = g.getWidth() - (inc * p.config.maxMinions) - margin
  local minionCount = #util.filter(app.context.objects, 'isMinion')

  for i = 1, p.config.maxMinions do
    if minionCount >= i then
      g.setColor(255, 153, 153)
    else
      g.setColor(153, 223, 255)
    end

    g.draw(image, x, margin, 0, scale, scale)
    x = x + inc
  end
end

function hud:drawWaves()
  local u, v = self.u, self.v
  local timeScale = 10
  local width = 300
  local height = 80

  if app.context.lastEvent and app.context.events[1] then
    local previousTime = app.context.lastEvent.time
    local time = lib.tick.index * lib.tick.rate - previousTime
    local percent = time / (app.context.events[1].time - previousTime)
    local alpha = (1 - percent) * 255
    local width = (app.context.events[1].time - previousTime) * timeScale
    local x = -width * percent
    g.setColor(0, 0, 0, alpha)
    g.rectangle('fill', x, v - height, width, height)
  end

  for i = 1, #app.context.events do
    local event = app.context.events[i]
    local x = (event.time - lib.tick.index * lib.tick.rate) * timeScale
    local width
    if app.context.events[i + 1] then
      width = (app.context.events[i + 1].time - event.time) * timeScale
    else
      width = 120
    end
    g.setColor(0, 0, 0, i == 1 and 255 or 150)
    g.rectangle('fill', x, v - height, width, height)
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
