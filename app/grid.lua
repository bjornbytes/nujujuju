local grid = lib.object.create()

grid.config = {
  size = {
    x = 70,
    y = 70 / 1.5
  }
}

function grid.state()
  return {
    hover = {
      x = nil,
      y = nil
    },
    prevHover = {
      x = nil,
      y = nil
    }
  }
end

function grid:bind()
  love.update
    :subscribe(function()
      self.prevHover.x, self.prevHover.y = self.hover.x, self.hover.y
      local size = self.config.size
      local x, y = self:cell(app.context.view:worldPoint(love.mouse.getPosition()))
      x = x - 1
      y = y - 1
      self.hover.x = math.lerp(self.hover.x or x * size.x, x * size.x, ((1 / lib.tick.rate) * .75) * lib.tick.rate)
      self.hover.y = math.lerp(self.hover.y or y * size.y, y * size.y, ((1 / lib.tick.rate) * .75) * lib.tick.rate)
    end)

  app.context.view.hud
    :subscribe(function()
      do return end

      g.white(20)
      local w, h = app.context.scene.width, app.context.scene.height
      local size = app.context.grid.config.size

      for x = 0, w, size.x do
        g.line(x, 0, x, h)
      end

      for y = 0, h, size.y do
        g.line(0, y, w, y)
      end

      if self.prevHover.x and self.prevHover.y and self.hover.x and self.hover.y then
        local x = math.lerp(self.prevHover.x, self.hover.x, lib.tick.accum / lib.tick.rate)
        local y = math.lerp(self.prevHover.y, self.hover.y, lib.tick.accum / lib.tick.rate)
        x, y = app.context.view:screenPoint(x, y)
        g.white(30)
        g.rectangle('fill', x, y, size.x, size.y)
      end

      return -1000
    end)
end

function grid:cell(x, y)
  return math.ceil(x / self.config.size.x), math.ceil(y / self.config.size.y)
end

return grid
