local ui = lib.object.create()

ui:include(lib.timeline.ui)

ui.config = {
  height = 120
}

ui.state = function()
  return {
    active = false,
    y = -ui.config.height,
    hand = love.mouse.getSystemCursor('hand'),
    prevScale = 60,
    scale = 60,
    targetScale = 60,
    prevTime = 30,
    time = 30
  }
end

function ui:bind()
  love.keypressed
    :filter(f.eq('`'))
    :subscribe(self:wrap(self.toggleActive))

  love.update
    :subscribe(function()
      if self.time - self.scale / 2 < 0 then
        self.time = self.scale / 2
      end
    end)

  love.update
    :subscribe(function()
      local mx = love.mouse.getX()
      local originalValue = self:timeAtPosition(mx)

      self.prevScale = self.scale
      self.scale = math.lerp(self.scale, self.targetScale, 10 * lib.tick.rate)

      self.prevTime = self.time
      self.time = self.time + (originalValue - self:timeAtPosition(mx))
    end)

  love.mousepressed
    :subscribe(function(mx, my, b)
      if self:contains(mx, my) then
        if b == 'wu' then
          self.targetScale = math.max(self.targetScale - 5, 10)
        elseif b == 'wd' then
          self.targetScale = self.targetScale + 5
        end
      end
    end)

  love.update
    :subscribe(self:wrap(self.smoothY))

  local function isLeft(_, _, b) return b == 'l' end
  local mousepress = love.mousepressed:filter(isLeft)
  local mouserelease = love.mousereleased:filter(isLeft)
  local dx
  local originalTime

  mousepress
    :filter(self:wrap(self.contains))
    :tap(function(x)
      originalTime = self.time
      dx = x
    end)
    :map(function()
      return love.mousemoved:takeUntil(mouserelease)
    end)
    :tap(function()
    end)
    :flatten()
    :subscribe(function(x, y)
      local _, y, w, h = self:geometry()
      self.time = originalTime - (x - dx) * self.scale / w
    end)

  mouserelease
    :subscribe(function(x)
      if dx and math.abs(x - dx) < 3 then
        app.context.timeline:addEvent({
          time = self:timeAtPosition(x)
        })
      end
    end)

  app.context.view.hud
    :subscribe(self:wrap(self.draw))
end

return ui
