local hud = lib.object.create()

hud.config = {
  markerSize = 30,
  markerColors = {
    [true] = { 80, 200, 80 },
    [false] = { 200, 80, 80 }
  },
  maxDrag = 300,
  world = {
    overgrowth = {
      x = 800,
      y = 600
    },
    hollow = {
      x = 1100,
      y = 700
    },
    tundra = {
      x = 1000,
      y = 500
    }
  }
}

hud.state = function()
  return {
    selected = 'overgrowth',
    peeking = false,
    bursts = {}
  }
end

function hud:bind()
  self.u, self.v = g.getDimensions()

  self:dispose({
    love.update:subscribe(function()
      local view = app.context.view
      local tx = self.config.world[self.selected].x
      local ty = self.config.world[self.selected].y

      tx = tx - view.width / 2
      ty = ty - view.height / 2

      view.x = util.lerp(view.x, tx, lib.tick.getLerpFactor(.2))
      view.y = util.lerp(view.y, ty, lib.tick.getLerpFactor(.2))
    end),

    app.context.view.draw:subscribe(function()
      g.setColor(50, 50, 50)
      g.rectangle('fill', 0, 0, app.context.scene.width, app.context.scene.height)

      g.setLineWidth(4)

      for key, scene in pairs(self.config.world) do
        g.setColor(self.config.markerColors[self:isSceneAvailable(key)])
        g.ellipse('line', scene.x, scene.y, self.config.markerSize, self.config.markerSize / 1.5)
      end

      g.setLineWidth(1)

      for _, burst in ipairs(self.bursts) do
        local factor = burst.factor
        local alpha = burst.factor * 140
        local size = util.lerp(self.config.markerSize, self.config.markerSize * 2, 1 - factor)

        g.white(alpha)
        g.circle('fill', burst.x, burst.y, size)
      end
    end),

    love.mousepressed
      :filter(function(_, _, b) return b == 1 end)
      :map(function(x, y)
        return app.context.view:worldPoint(x, y)
      end)
      :map(function(x, y)
        local _, key = util.match(self.config.world, function(info)
          local dir = util.angle(info.x, info.y, x, y)
          return util.distance(info.x, info.y, x, y) <= self.config.markerSize * 2 / (1.5 - math.abs(math.cos(dir)) * .5)
        end)

        return key, x, y
      end)
      :filter(f.id)
      :subscribe(function(key, x, y)
        self.selected = key

        local burst = {
          factor = 1,
          x = x,
          y = y
        }

        table.insert(self.bursts, 1, burst)

        lib.flux.to(burst, .4, { factor = 0 })
          :ease('cubicout')
          :oncomplete(function()
            table.remove(self.bursts)
          end)
      end, print)
  })
end

function hud:isSceneAvailable(key)
  return key == 'overgrowth'
end

return hud
