local hud = lib.object.create()

hud.config = {
  font = fonts.roundedElegance,
  margin = .03,
  padding = .015
}

function hud:state()
  return {
    abilityFactor = {}
  }
end

function hud:bind()
  self.u, self.v = g.getDimensions()
  self.font = self.config.font(self.v * .04)

  for i = 1, #app.context.objects.muju.abilities do
    self.abilityFactor[i] = i == 1 and 1 or 0
  end

  return {
    app.context.view.hud
      :subscribe(function()
        self:drawJuju()
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
      end),

    love.mousepressed
      :filter(function(_, _, b) return b == 1 end)
      :map(self:wrap(self.getElement))
      :filter(f.eq('ability'))
      :subscribe(function(ability, index)
        local muju = app.context.objects.muju

        muju:selectAbility(index)

        for i = 1, #muju.abilities do
          lib.flux.to(self.abilityFactor, .25, { [i] = i == index and 1 or 0 }):ease('cubicout')
        end
      end)
  }
end

function hud:getElement(mx, my)
  local p = app.context.objects.muju

  local u, v = self.u, self.v
  local size = .06 * u
  local inc = .08 * u
  local count = #p.abilities
  local x = u / 2 - (inc * (count - 1) / 2)

  for i = 1, count do
    if util.inside(mx, my, x - size / 2, 8, size, size) then
      return 'ability', i
    end

    x = x + inc
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

  for i = 1, p.juju do
    g.white()
    g.draw(image, x, margin, 0, scale, scale)
    x = x + inc
  end
end

function hud:drawWaves()
  local u, v = self.u, self.v
  local timeScale = 10
  local width = 300
  local height = 80

  g.setFont(self.font)

  do
    if app.context.waves.grace > 0 then
      g.white()
      g.print(math.ceil(app.context.waves.grace), .02 * v, .1 * v)
    end

    return
  end

  if app.context.lastEvent and app.context.events[1] then
    local previousTime = app.context.lastEvent.time
    local time = lib.tick.index * lib.tick.rate - previousTime
    local percent = time / (app.context.events[1].time - previousTime)
    local alpha = (1 - percent) * 255
    local width = (app.context.events[1].time - previousTime) * timeScale
    local x = -width * percent
    g.setColor(0, 0, 0, alpha)
    g.rectangle('fill', x, v - height, width, height)

    g.white()
    local str = app.context.lastEvent.count
    g.print(str, x + width * .25 - g.getFont():getWidth(str), v - height * .5 - g.getFont():getHeight() / 2)
  end

  for i = 1, #app.context.events do
    local event = app.context.events[i]
    local x = (event.time - lib.tick.index * lib.tick.rate) * timeScale + 3 * i
    local width
    if app.context.events[i + 1] then
      width = (app.context.events[i + 1].time - event.time) * timeScale
    else
      width = 120
    end
    g.setColor(0, 0, 0, i == 1 and 255 or 150)
    g.rectangle('fill', x, v - height, width, height)

    g.white()
    local str = event.count
    g.print(str, x + width * .25 - g.getFont():getWidth(str) / 2, v - height * .5 - g.getFont():getHeight() / 2)
  end
end

function hud:drawAbilities()
  local p = app.context.objects.muju

  local u, v = self.u, self.v
  local size = .06 * u
  local inc = .08 * u
  local count = #p.abilities
  local x = u / 2 - (inc * (count - 1) / 2)

  for i = 1, count do
    g.setColor(0, 0, 0, 100 + 80 * self.abilityFactor[i])
    g.rectangle('fill', x - size / 2, 8, size, size)
    x = x + inc
  end
end

return hud
