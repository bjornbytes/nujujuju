local hud = {}

function hud:drawBlood()
  local u, v = self.u, self.v
  local muju = app.context.objects.muju

  local alpha = math.clamp(1 - ((lib.tick.index - (muju.lastHurt + (.3 / lib.tick.rate))) * lib.tick.rate), 0, 1)
  if alpha > .01 then
    g.white(alpha * 180)
    local image = app.art.hudBlood
    local scale = image:getWidth() / u
    g.draw(image, 0, 0, 0, scale, scale)
  end
end

function hud:drawPlayerHealthbar()
  local u, v = self.u, self.v
  local muju = app.context.objects.muju

  local percent = muju.health / muju.config.maxHealth
  local width = .15 * v
  local height = .02 * v
  g.setColor(0, 0, 0, 100)
  g.rectangle('fill', .02 * v, .02 * v, width, height)

  g.setColor(255, 0, 0, 80)
  g.rectangle('fill', .02 * v, .02 * v, width * percent, height)

  local str = muju.health
  g.setFont(self.font)
  g.setColor(0, 0, 0)
  g.print(str, .02 * v + width / 2 - self.font:getWidth(str) / 2 + 1, .02 * v + height / 2 - self.font:getHeight() / 2 + 1)
  g.white()
  g.print(str, .02 * v + width / 2 - self.font:getWidth(str) / 2, .02 * v + height / 2 - self.font:getHeight() / 2)
end

function hud:drawPlayerJuju()
  local u, v = self.u, self.v
  local muju = app.context.objects.muju

  local percent = muju.juju / muju.config.maxJuju
  local width = .15 * v
  local height = .02 * v
  local y = .02 * v + .02 * v + .01 * v
  g.setColor(0, 0, 0, 100)
  g.rectangle('fill', .02 * v, y, width, height)

  g.setColor(50, 255, 0, 80)
  g.rectangle('fill', .02 * v, y, width * percent, height)

  local str = muju.juju
  g.setFont(self.font)
  g.setColor(0, 0, 0)
  g.print(str, .02 * v + width / 2 - self.font:getWidth(str) / 2 + 1, y + height / 2 - self.font:getHeight() / 2 + 1)
  g.white()
  g.print(str, .02 * v + width / 2 - self.font:getWidth(str) / 2, y + height / 2 - self.font:getHeight() / 2)
end

function hud:drawBuildingUI()
  local u, v = self.u, self.v
  for _, building in pairs(table.filter(app.context.objects, 'isBuilding')) do
    building:drawUI(u, v)
  end
end

function hud:drawEnemyUI()
  local u, v = self.u, self.v
end

return hud
