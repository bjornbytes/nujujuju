local dirt = lib.object.create()

dirt:include(lib.obstacle)
dirt:include(lib.building)

dirt.config = app.buildings.dirt.config
dirt.image = app.buildings.dirt.image

dirt.state = function()
  return {
    team = 'player',
    isGrowing = false,
    isGrown = false,
    growTimer = 0
  }
end

function dirt:bind()
  self:setAnchor()
  self:setIsSolid()
  self:setIsBuilding()

  love.update
    :subscribe(self:wrap(self.revertToStartPosition))

  love.update
    :filter(function()
      return self.isGrowing
    end)
    :subscribe(function()
      self.growTimer = math.max(self.growTimer - lib.tick.rate, 0)
      if self.growTimer == 0 then
        self.isGrown = true
        self.isGrowing = false
      end
    end)

  app.context.view.draw
    :subscribe(self:wrap(self.draw))

  return self
end

function dirt:canInteractWith(player)
  return player.form == 'muju' and (self.isGrown or not self.isGrowing)
end

function dirt:interact()
  if not self.isGrowing and not self.isGrown then
    self.isGrowing = true
    self.growTimer = self.config.growTime
  elseif self.isGrown then
    app.context.objects.muju:eatMushroom()
    self.isGrown = false
  end
end

function dirt:drawUI(u, v)
  local x, y = app.context.view:screenPoint(self.position.anchor.x, self.position.anchor.y)

  if app.context.objects.muju.nearbyBuilding == self and not self.isGrowing and not self.isGrown then
    local font = app.context.hud.font
    local y = y - .05 * v
    local str = 'Grow Shruju?'
    local w, h = font:getWidth(str), font:getHeight()
    local padding = 4
    g.setColor(0, 0, 0, 180)
    g.rectangle('fill', x - w / 2 - padding, y - h / 2 - padding, w + 2 * padding, h + 2 * padding)
    g.setColor(255, 255, 255)
    g.print(str, x - font:getWidth(str) / 2, y - font:getHeight() / 2)
  end

  if self.isGrowing or self.isGrown then
    local percent = 1 - (self.growTimer / self.config.growTime)
    local width = .1 * v
    local height = .02 * v
    local y = y - .06 * v
    g.setColor(0, 0, 0, 60)
    g.rectangle('fill', x - width / 2, y - height / 2, width, height)
    g.setColor(self.isGrowing and {255, 255, 255, 60} or {100, 255, 100, 60})
    g.rectangle('fill', x - width / 2, y - height / 2, (width * percent), height)

    if self.isGrowing or self.isGrown then
      local font = app.context.hud.font
      g.setColor(255, 255, 255)
      g.setFont(font)
      local str = self.isGrowing and 'Growing shruju...' or 'Shruju ready!'
      g.print(str, x - font:getWidth(str) / 2, y + .02 * v)
    end
  end
end

return dirt
