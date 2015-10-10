local hud = {}

function hud:drawShapeshiftCooldown(u, v)
  local u, v = self.u, self.v
  local muju = app.context.objects.muju
  local margin = self.config.margin * v
  local padding = self.config.padding * v

  local w = self.font:getWidth('SHAPESHIFT') + 2 * padding
  g.setColor(0, 0, 0, 40)
  g.rectangle('fill', margin, margin, w, self.font:getHeight() + 2 * padding)

  g.setColor(255, 255, 255)
  g.print('SHAPESHIFT', margin + padding, margin + padding)

  local muju = app.context.objects.muju
  local percent = math.clamp((lib.tick.index - muju.lastShapeshift) / (muju.config.shapeshiftCooldown / lib.tick.rate), 0, 1)
  if percent < 1 then
    g.setColor(0, 0, 0, 255 * (.5 - percent / 2))
    g.rectangle('fill', margin + w * percent, margin, w * (1 - percent), self.font:getHeight() + 2 * padding)
  end
end

function hud:drawAbilities(u, v)
  local u, v = self.u, self.v
  local muju = app.context.objects.muju
  local margin = self.config.margin * v
  local padding = self.config.padding * v

  local y = 2 * margin + self.font:getHeight() + 2 * padding
  local size = .06 * v
  for i = 1, 3 do
    local ability = muju.abilities.list[i]

    g.setColor(0, 0, 0, 40)
    g.rectangle('fill', margin, y, size, size)

    if muju.abilities.list[i] then
      g.setColor(255, 255, 255, 150 / ((f.try(ability.canCast, ability)) and 1 or 2))
      g.rectangle('line', margin, y, size, size)
    end

    y = y + size + margin / 2
  end
end

function hud:drawPlayerHealthbar()
  local u, v = self.u, self.v
  local padding = .005 * v
  local muju = app.context.objects.muju
  local icon = app.art.juju
  local size = .06 * v
  local scale = size / icon:getWidth()
  local x, y = .02 * v, .02 * v

  g.setColor(255, 255, 255)
  g.draw(icon, x, y, 0, scale, scale)

  local segmentWidth = .04 * v
  local segmentHeight = .02 * v
  local totalWidth = (2 * padding) + (5 * segmentWidth) + ((5 - 1) * padding)
  local totalHeight = (2 * padding) + segmentHeight

  g.setColor(0, 0, 0, 100)
  g.rectangle('fill', x + size + (.02 * v), y, totalWidth, totalHeight)

  g.setColor(200, 50, 50, 200)
  for i = 1, 5 do
    g.rectangle('fill', x + size + (.02 * v) + padding + (segmentWidth + padding) * (i - 1), y + padding, segmentWidth, segmentHeight)
  end

  -- draw health icon
  -- draw frame
  -- draw bars
end

function hud:drawPlayerJuju()
  local u, v = self.u, self.v
  local muju = app.context.objects.muju

  -- draw juju icon
  -- draw frame
  -- draw bars
end

return hud
