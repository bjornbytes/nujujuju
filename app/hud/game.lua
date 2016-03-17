local hud = lib.object.create()

hud.config = {
  font = fonts.roundedElegance,
  margin = .03,
  padding = .015
}

function hud:init()
  self.abilityFactor = {}
end

function hud:bind()
  self.u, self.v = g.getDimensions()
  self.font = self.config.font(self.v * .04)
  self.smallFont = self.config.font(self.v * .02)

  for i = 1, #app.context.abilities.muju do
    self.abilityFactor[i] = 1
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
        if app.context.abilities.muju[index]:canCast(app.context.objects.muju) then
          app.context.abilities.selected = app.context.abilities.muju[index]
        end
      end)
  }
end

function hud:getElement(mx, my)
  local abilities = app.context.abilities

  local u, v = self.u, self.v
  local size = .06 * u
  local inc = .08 * u
  local count = #abilities.muju
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
  y = y - .18 * v

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
  local ox = margin
  local oy = margin
  local perRow = 5

  for i = 1, p.juju do
    local x = ox + (inc * ((i - 1) % perRow))
    local y = oy + (inc * math.floor((i - 1) / perRow))
    g.white()
    g.draw(image, x, y, 0, scale, scale)
  end
end

function hud:drawWaves()
  local u, v = self.u, self.v

  g.setFont(self.font)

  if app.context.waves.grace > 0 then
    g.white()

    local font = g.getFont()
    local fh = font:getHeight()
    local padding = .02 * v
    local portraitSize = .1 * v
    local y = v - padding - fh - padding - portraitSize - padding - fh - padding - fh

    local str = math.ceil(app.context.waves.grace)
    g.print(str, .5 * u - font:getWidth(str) / 2, y)

    y = y + fh + padding

    local str = 'Incoming wave'
    g.print(str, .5 * u - font:getWidth(str) / 2, y)

    y = y + fh + padding

    local groups = {}
    local events = app.context.waves.waves[app.context.waves.current + 1].events
    for i = 1, #events do
      local event = events[i]
      if not groups[event.kind] then
        table.insert(groups, event.kind)
        groups[event.kind] = 0
      end

      groups[event.kind] = groups[event.kind] + event.count
    end

    local count = #groups
    local inc = portraitSize + .05 * v
    local x = u * .5 - (inc * (count - 1) / 2)

    for _, kind in ipairs(groups) do
      local image = app.art.portraits[kind]
      local scale = portraitSize / image:getHeight()

      g.draw(image, x, y, 0, scale, scale, image:getWidth() / 2, 0)
      local str = groups[kind]
      g.print(str, x - font:getWidth(str) / 2, y + portraitSize + padding)
      x = x + inc
    end

    y = y + portraitSize + padding + fh + padding
  end
end

function hud:drawAbilities()
  local p = app.context.objects.muju
  local abilities = app.context.abilities

  local u, v = self.u, self.v
  local size = .06 * u
  local inc = .08 * u
  local count = #abilities.muju
  local x = u / 2 - (inc * (count - 1) / 2)

  for i = 1, count do
    g.setColor(0, 0, 0, 100 + 80 * self.abilityFactor[i])
    g.rectangle('fill', x - size / 2, 8, size, size)

    local ability = abilities.muju[i]
    local image = app.art.icons[ability.tag]
    local w, h = image:getDimensions()

    local scale = (size * .75) / ((w > h) and w or h)

    g.white(200 + 55 * self.abilityFactor[i])
    g.draw(image, x, 8 + size / 2, 0, scale, scale, w / 2, h / 2)

    if ability:isOnCooldown() then
      local cooldown = ability:timeUntilReady() / ability:getCooldown()
      g.setColor(255, 255, 255, 40)
      g.rectangle('fill', x - size / 2, 8 + size * (1 - cooldown), size, size * cooldown)
    end

    local cost = ability:getCost()

    if cost then
      g.setFont(self.smallFont)
      local image = app.art.juju
      local scale = .02 * v / image:getWidth()
      local padding = .01 * v
      local totalWidth = image:getWidth() * scale + padding + g.getFont():getWidth(cost)
      g.white(p.juju >= cost and 255 or 120)
      g.draw(image, x - totalWidth / 2, 8 + size + .01 * v, 0, scale, scale)
      g.white()
      g.print(cost, x - totalWidth / 2 + image:getWidth() * scale + padding, 8 + size + .01 * v)
    end

    x = x + inc
  end
end

return hud
