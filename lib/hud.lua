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

return hud