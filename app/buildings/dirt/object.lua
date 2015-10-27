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
    growTimer = 0,
    growStart = nil
  }
end

function dirt:bind()
  self:setAnchor()
  self:setIsSolid()
  self:setIsBuilding()

  self.threads = {}
  self.threads.grow = function()
    self.isGrowing = true
    self.growStart = lib.tick.index
    coroutine.yield(self.config.growTime)
    self.isGrowing = false
    self.isGrown = true
  end

  app.context.collision:add(self)

  self:dispose({
    love.update
      :subscribe(self:wrap(self.revertToStartPosition)),

    app.context.view.draw
      :subscribe(self:wrap(self.draw))
  })

  return self
end

function dirt:canInteractWith(player)
  return player.form == 'muju' and (self.isGrown or not self.isGrowing)
end

function dirt:interact()
  if not self.isGrowing and not self.isGrown then
    lib.quilt.add(self.threads.grow)
  elseif self.isGrown then
    app.context.objects.muju:eatMushroom()
    self.isGrown = false
  end
end

function dirt:canTarget()
  return self.isGrown
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
    g.white()
    g.print(str, x - font:getWidth(str) / 2, y - font:getHeight() / 2)
  end

  if self.isGrowing or self.isGrown then
    local percent = math.clamp(((lib.tick.index - self.growStart) * lib.tick.rate) / self.config.growTime, 0, 1)
    local width = .1 * v
    local height = .02 * v
    local y = y - .06 * v
    g.setColor(0, 0, 0, 60)
    g.rectangle('fill', x - width / 2, y - height / 2, width, height)
    g.setColor(self.isGrowing and {255, 255, 255, 60} or {100, 255, 100, 60})
    g.rectangle('fill', x - width / 2, y - height / 2, (width * percent), height)

    if self.isGrowing or self.isGrown then
      local font = app.context.hud.font
      g.white()
      g.setFont(font)
      local str = self.isGrowing and 'Growing shruju...' or 'Shruju ready!'
      g.print(str, x - font:getWidth(str) / 2, y + .02 * v)
    end
  end
end

return dirt
