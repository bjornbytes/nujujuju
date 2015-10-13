local shrine = lib.object.create()

shrine:include(lib.obstacle)
shrine:include(lib.building)

shrine.config = app.buildings.shrine.config
shrine.image = app.buildings.shrine.image

shrine.state = function()
  return {
    isSummoning = false,
    isSummoned = false,
    summonTimer = 0,
    totem = nil
  }
end

function shrine:bind()
  self:setStartPosition()
  self:setIsSolid()
  self:setIsBuilding()

  love.update
    :subscribe(self:wrap(self.revertToStartPosition))

  love.update
    :filter(function()
      return self.isSummoning
    end)
    :subscribe(function()
      self.summonTimer = math.max(self.summonTimer - lib.tick.rate, 0)
      if self.summonTimer == 0 then
        self.isSummoned = true
        self.isSummoning = false
        self.totem = app.totem.object:new({
          shrine = self,
          position = {
            x = self.position.initial.x,
            y = self.position.initial.y
          }
        })
      end
    end)

  app.context.view.draw
    :subscribe(self:wrap(self.draw))

  return self
end

function shrine:canInteractWith(player)
  return player.form == 'muju' and (not self.isSummoned and not self.isSummoning)
end

function shrine:interact()
  if not self.isSummoning and not self.isSummoned then
    self.isSummoning = true
    self.summonTimer = self.config.summonTime
  end
end

function shrine:resetTotem()
  if self.totem then
    self.totem = nil
    self.isSummoned = false
  end
end

function shrine:drawUI(u, v)
  local x, y = app.context.view:screenPoint(self.position.initial.x, self.position.initial.y)

  if app.context.objects.muju.nearbyBuilding == self and not self.isSummoning and not self.isSummoned then
    local font = app.context.hud.font
    local y = y - .05 * v
    local str = 'Build totem?'
    local w, h = font:getWidth(str), font:getHeight()
    local padding = 4
    g.setColor(0, 0, 0, 180)
    g.rectangle('fill', x - w / 2 - padding, y - h / 2 - padding, w + 2 * padding, h + 2 * padding)
    g.setColor(255, 255, 255)
    g.print(str, x - font:getWidth(str) / 2, y - font:getHeight() / 2)
  end

  if self.isSummoning or (self.isSummoned and self.totem) then
    local percent = 1 - (self.summonTimer / self.config.summonTime)
    if self.isSummoned then
      percent = (self.totem.time / self.totem.config.maxTime)
    end
    local width = .1 * v
    local height = .02 * v
    local y = y - .06 * v
    g.setColor(0, 0, 0, 60)
    g.rectangle('fill', x - width / 2, y - height / 2, width, height)
    g.setColor(self.isSummoning and {255, 255, 255, 60} or {100, 255, 100, 60})
    g.rectangle('fill', x - width / 2, y - height / 2, (width * percent), height)
  end

  if self.isSummoning or self.isSummoned then
    local y = y - .06 * v
    local font = app.context.hud.font
    g.setColor(255, 255, 255)
    g.setFont(font)
    local str = self.isSummoning and 'Building totem...' or 'Totem active!'
    g.print(str, x - font:getWidth(str) / 2, y + .02 * v)
  end
end

return shrine
