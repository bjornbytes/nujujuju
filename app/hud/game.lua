local hud = lib.object.create()

local function isLeft(_, _, b) return b == 1 end

hud.config = {
  font = fonts.roundedElegance,
  margin = .03,
  padding = .015
}

function hud:init()
  self.abilityFactor = {}
  self.jujuCostActive = false
  self.jujuCostFactor = 0

  local brujuConfig = util.merge({ scale = 1, speedHack = true }, util.clone(app.minions.bruju.animation))

  self.animations = {}
  self.animations.bruju = lib.animation.create(app.minions.bruju.spine, brujuConfig)
  self.animations.bruju.speed = .5
  self.animations.bruju:set('idle')
end

function hud:bind()
  self.u, self.v = g.getDimensions()
  self.font = self.config.font(self.v * .04)
  self.smallFont = self.config.font(self.v * .03)
  self.bigFont = self.config.font(self.v * .065)

  for i = 1, #app.context.abilities.list do
    self.abilityFactor[i] = 1
  end

  local tap = love.touchpressed
    :flatMapLatest(function(id, ox, oy)
      return love.touchmoved
        :startWith(id, ox, oy)
        :filter(f.eq(id))
        :map(function(id, x, y)
          return util.distance(ox, oy, x, y)
        end)
        :takeUntil(
          love.touchreleased
            :filter(f.eq(id))
            :take(1)
        )
        :max()
        :filter(function(d) return d < 64 end)
        :map(function()
          return ox, oy
        end)
    end)

  return {
    app.context.view.hud
      :subscribe(function()
        self:drawJuju()
        --self:drawWaves()

        app.art.heartFrame:setFilter('nearest')
        app.art.heart:setFilter('nearest')
        app.art.heartHalf:setFilter('nearest')

        local healthbars = {}
        healthbars = util.concat(healthbars, util.filter(app.context.objects, 'isMinion'))
        healthbars = util.concat(healthbars, util.filter(app.context.objects, 'isEnemy'))

        util.each(healthbars, function(unit)
          self:drawHealthbar(unit)
        end)

        self:drawAbilities2()

        return -1000
      end),

    tap
      :map(self:wrap(self.getElement))
      :filter(f.eq('ability'))
      :subscribe(function(ability, index)
        if app.context.abilities.selected ~= app.context.abilities.list[index] then
          app.context.abilities.selected = app.context.abilities.list[index]
        else
          app.context.abilities.selected = nil
        end
      end),

    love.update
      :subscribe(function()
        local isActuallyCastingSomething = util.match(app.context.abilities.casts, function(cast)
          return cast.active and (not cast.owner.isMinion or cast.ability)
        end)

        if isActuallyCastingSomething then
          if not self.jujuCostActive then
            lib.flux.to(self, .2, { jujuCostFactor = 1 })
            self.jujuCostActive = true
          end
        else
          if self.jujuCostActive then
            lib.flux.to(self, .2, { jujuCostFactor = 0 })
            self.jujuCostActive = false
          end
        end
      end)
  }
end

function hud:getElement(mx, my)
  local abilities = app.context.abilities

  local u, v = self.u, self.v
  local size = .06 * u
  local inc = .08 * u
  local count = #abilities.list
  local x = u / 2 - (inc * (count - 1) / 2)

  for i = 1, count do
    if util.inside(mx, my, x - size / 2, v - 8 - size, size, size) then
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
    elseif unit.health >= i - .5 then
      local image = app.art.heartHalf
      g.draw(image, x, y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
    end

    x = x + inc
  end
end

function hud:drawJuju()
  local u, v = self.u, self.v
  local p = app.context.objects.muju
  local str = p.juju
  local xpadding = (18 / 720) * v
  local ypadding = (8 / 720) * v
  local spacer = (12 / 720) * v
  local height = (42 / 720) * v
  local textNudge = (-1 / 720) * v
  local icon = app.art.juju
  local scale = (height - (2 * ypadding)) / icon:getHeight()
  local font = fonts.rawengulk((30 / 720) * v)
  local width = xpadding + icon:getWidth() * scale + spacer + font:getWidth(str) + xpadding
  local x = u * .5 - width * .5
  local y = (14 / 720) * v

  g.setColor(0, 0, 0, 90)
  g.rectangle('fill', x, y, width, height, height / 2, height / 2)

  g.white()
  g.draw(icon, x + xpadding, y + ypadding, 0, scale, scale)

  g.white()
  g.setFont(font)
  g.print(str, x + xpadding + icon:getWidth() * scale + spacer, y + height / 2 - font:getHeight() / 2 + textNudge)

  if self.jujuCostFactor > 0 then
    local totalCost = util.reduce(app.context.abilities.casts, function(cost, cast)
      if cast.active and (not cast.owner.isMinion or cast.ability) then
        cost = cost or 0

        if not cast.ability then
          cost = cost + util.count(util.filter(app.context.objects, 'isMinion'))
        else
          cost = cost + cost.ability:getCost()
        end
      end

      return cost
    end, 0)

    local text = totalCost
    local width = xpadding + font:getWidth(str) + xpadding
    local x = u * .5 - width * .5
    local y = y + height + ypadding

    y = y + .01 * v * (1 - self.jujuCostFactor)

    g.setColor(0, 0, 0, 90 * self.jujuCostFactor)
    g.rectangle('fill', x, y, width, height, height / 2, height / 2)

    if totalCost > 0 then
      g.setColor(200, 140, 140, 255 * self.jujuCostFactor)
    else
      g.white(255 * self.jujuCostFactor)
    end

    g.print(text, u * .5 - font:getWidth(str) / 2, y + height / 2 - g.getFont():getHeight() / 2)
  end
end

function hud:drawWaves()
  local u, v = self.u, self.v

  g.setFont(self.smallFont)
  g.white()

  g.setFont(self.font)

  if app.context.waves.grace > 0 then
    g.white()

    local font = g.getFont()
    local fh = font:getHeight()
    local bfh = self.bigFont:getHeight()
    local padding = .02 * v
    local portraitSize = .1 * v
    local y = padding

    local str = math.ceil(app.context.waves.grace)
    g.setFont(self.bigFont)
    g.print(str, .5 * u - g.getFont():getWidth(str) / 2, v * .675)
    g.setFont(self.font)

    local str = 'Next wave'
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

  if app.context.waves.current == #app.context.waves.waves and #util.filter(app.context.objects, 'isEnemy') == 0 then
    g.setFont(self.bigFont)
    local x = u / 2
    local str = 'You win'
    g.white()
    g.print(str, x - g.getFont():getWidth(str) / 2, v * .2)
  end
end

function hud:drawAbility(ability, x, y)
  local u, v = self.u, self.v
  local p = app.context.objects.muju
  local size = (70 / 720) * v
  local cost = ability:getCost()
  local canAfford = not cost or p.juju >= cost
  local xpadding = (5 / 720) * v
  local ypadding = (4 / 720) * v
  local costHeight = (22 / 720) * v
  local juju = app.art.juju
  local jujuScale = (costHeight - 2 * ypadding) / juju:getHeight()
  local font = fonts.rawengulk((20 / 720) * v)
  local costWidth = xpadding + juju:getWidth() * jujuScale + xpadding + font:getWidth(cost) + xpadding
  local costX = x + size - costWidth
  local costY = y + size - costHeight
  local icon = app.art.icons[ability.tag]
  local iconPadding = (4 / 720) * v
  local iconScale = (size * .8) / math.max(icon:getWidth(), icon:getHeight())

  g.setColor(0, 0, 0, 90)
  g.rectangle('fill', x, y, size, size)

  g.white()
  g.draw(icon, x + size / 2, y + size / 2, 0, iconScale, iconScale, icon:getWidth() / 2, icon:getHeight() / 2)

  g.setColor(0, 0, 0, 90)
  g.rectangle('fill', costX, costY, costWidth, costHeight)

  g.white()
  g.draw(juju, costX + xpadding, costY + ypadding, 0, jujuScale, jujuScale)

  g.white()
  g.setFont(font)
  g.print(cost, costX + xpadding + juju:getWidth() * jujuScale + xpadding, costY + costHeight / 2 - font:getHeight() / 2)
end

function hud:drawAbilities()
  local p = app.context.objects.muju
  local abilities = app.context.abilities

  local u, v = self.u, self.v
  local size = .06 * u
  local inc = .08 * u
  local count = #abilities.list
  local x = u / 2 - (inc * (count - 1) / 2)

  for i = 1, count do
    local ability = abilities.list[i]
    local image = app.art.icons[ability.tag]
    local w, h = image:getDimensions()

    local cost = ability:getCost()
    local canAfford = not cost or p.juju >= cost

    g.setColor(0, 0, 0, (100 + 80 * self.abilityFactor[i]) * (canAfford and 1 or .5))
    g.rectangle('fill', x - size / 2, v - 8 - size, size, size)

    if app.context.abilities.selected == abilities.list[i] then
      g.setLineWidth(3)
      g.setColor(255, 255, 255, 100 + 80 * self.abilityFactor[i])
      g.rectangle('line', x - size / 2, v - 8 - size, size, size)
      g.setLineWidth(1)
    end

    local scale = (size * .75) / ((w > h) and w or h)

    g.white((200 + 55 * self.abilityFactor[i]) * (canAfford and 1 or .5))
    g.draw(image, x, v - 8 - size / 2, 0, scale, scale, w / 2, h / 2)

    if ability:isOnCooldown() then
      local cooldown = ability:timeUntilReady() / ability:getCooldown()
      g.setColor(255, 255, 255, 40)
      g.rectangle('fill', x - size / 2, v - 8 - size + size * (1 - cooldown), size, size * cooldown)
    end

    if cost then
      g.setFont(self.smallFont)
      local image = app.art.juju
      local scale = .02 * v / image:getWidth()
      local padding = .01 * v
      local totalWidth = image:getWidth() * scale + padding + g.getFont():getWidth(cost)
      g.white(canAfford and 255 or 120)
      g.draw(image, x - totalWidth / 2, v - 8 - size - g.getFont():getHeight() / 2, 0, scale, scale, 0, image:getHeight() / 2)
      g.setColor(canAfford and {255, 255, 255} or {255, 100, 100})
      g.print(cost, x - totalWidth / 2 + image:getWidth() * scale + padding, v - 8 - size - g.getFont():getHeight())
    end

    x = x + inc
  end
end

function hud:drawAbilities2()
  local u, v = self.u, self.v
  self.animations.bruju:tick(lib.tick.rate)
  self.animations.bruju:draw(.065 * v, .11 * v)
  self:drawAbility(app.context.abilities.list[1], .15 * v, 20)
  self:drawAbility(app.context.abilities.list[1], .275 * v, 20)
  self:drawAbility(app.context.abilities.list[1], .4 * v, 20)
end

return hud
