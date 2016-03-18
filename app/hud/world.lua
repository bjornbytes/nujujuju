local hud = lib.object.create()

local function isLeft(_, _, b) return b == 1 end

hud.config = {
  markerSize = 30,
  markerColors = {
    available = { 80, 200, 80 },
    unavailable = { 200, 80, 80 }
  },
  maxTapDistance = 32,
  panAmount = 50,
  panDeadZone = 8,
  world = app.hud.worldPositions
}

function hud:init()
  self.selected = nil
  self.dragStart = {
    x = nil,
    y = nil
  }
  self.bursts = {}
  self.tooltipFactor = 0
  self.shakeFactors = {}
  self.editing = false

  self.targetScale = app.context.view.scale
  self.originalScale = self.targetScale
end

function hud:bind()
  self.u, self.v = g.getDimensions()
  self.font = fonts.montserrat(.03 * self.v)
  self.playText = g.newText(self.font, 'Play')

  self.tooltip = {
    factor = 1,
    width = .4 * self.v,
    height = .3 * self.v,
    margin = .06 * self.v,
    hintSize = .04 * self.v,
    x = 0,
    y = 0,
    canvas = g.newCanvas(.4 * self.v + 2 * .06 * self.v, .3 * self.v + 2 * .06 * self.v),
    backCanvas = g.newCanvas(.4 * self.v + 2 * .06 * self.v, .3 * self.v + 2 * .06 * self.v)
  }

  for k in pairs(self.config.world) do
    self.shakeFactors[k] = 0
  end

  self:selectScene('overgrowth')

  return {
    love.keypressed
      :filter(f.eq('`'))
      :subscribe(function()
        self.editing = not self.editing
        if self.editing then
          self:deselect()
        else
          self:selectScene(self.selected)
        end
      end),

    love.keypressed
      :filter(f.eq('='))
      :filter(function() return love.keyboard.isDown('lgui') end)
      :subscribe(function()
        self.targetScale = self.targetScale * 1.5
      end),

    love.keypressed
      :filter(f.eq('-'))
      :filter(function() return love.keyboard.isDown('lgui') end)
      :subscribe(function()
        self.targetScale = self.targetScale / 1.5
      end),

    love.update
      :subscribe(function()
        local view = app.context.view
        local tx = self.config.world[self.selected].x
        local ty = self.config.world[self.selected].y

        if self.editing then
          if not self.dragging and love.mouse.isDown(1) then
            local dx = love.mouse.getX() - self.dragStart.x
            local dy = love.mouse.getY() - self.dragStart.y
            view.x = util.lerp(view.x, self.dragStart.vx - dx / 2, lib.tick.getLerpFactor(.2))
            view.y = util.lerp(view.y, self.dragStart.vy - dy / 2, lib.tick.getLerpFactor(.2))
            view:contain()
          end

          local prevw, prevh = view.width, view.height
          local xf, yf = .5, .5
          view.scale = util.lerp(view.scale, self.targetScale, lib.tick.getLerpFactor(.2))
          view.width = g.getWidth() / view.scale
          view.height = g.getHeight() / view.scale
          view.x = view.x + (prevw - view.width) * xf
          view.y = view.y + (prevh - view.height) * yf

          return
        end

        if love.mouse.isDown(1) then
          local dis, dir = util.vector(self.dragStart.x, self.dragStart.y, love.mouse.getPosition())
          if dis > self.config.panDeadZone then
            dis = dis / (1 + (dis / self.config.panAmount) ^ .5)
            tx = tx - math.cos(dir) * dis
            ty = ty - math.sin(dir) * dis
          end
        end

        tx = tx - view.width / 2
        ty = ty - view.height / 2

        view.x = util.lerp(view.x, tx, lib.tick.getLerpFactor(.16))
        view.y = util.lerp(view.y, ty, lib.tick.getLerpFactor(.16))
        local prevw, prevh = view.width, view.height
        local xf, yf = .5, .5
        view.scale = util.lerp(view.scale, self.originalScale, lib.tick.getLerpFactor(.1))
        view.width = g.getWidth() / view.scale
        view.height = g.getHeight() / view.scale
        view.x = view.x + (prevw - view.width) * xf
        view.y = view.y + (prevh - view.height) * yf
      end),

    app.context.view.draw:subscribe(function()
      g.setColor(50, 50, 50)
      g.rectangle('fill', 0, 0, app.context.scene.width, app.context.scene.height)

      g.setLineWidth(4)

      for key, scene in pairs(self.config.world) do
        if self:isSceneAvailable(key) then
          g.setColor(self.config.markerColors.available)
        else
          g.setColor(self.config.markerColors.unavailable)
        end

        local scale = self.selected == key and 1 + (.1 * math.sin(lib.tick.index * lib.tick.rate * 5)) or 1

        if self:isSceneAvailable(key) then
          g.ellipse('line', scene.x, scene.y, self.config.markerSize * scale, self.config.markerSize * scale / 1.5)
        else
          g.push()
          g.translate(scene.x, scene.y)
          g.rotate(math.sin(self.shakeFactors[key] * 10) * .25)
          g.ellipse('line', 0, 0, self.config.markerSize * scale, self.config.markerSize * scale / 1.5)
          g.pop()
        end
      end

      g.setLineWidth(1)

      for _, burst in ipairs(self.bursts) do
        local factor = burst.factor
        local alpha = burst.factor * 140
        local size = util.lerp(self.config.markerSize, self.config.markerSize * 2, 1 - factor)

        g.white(alpha)
        g.circle('fill', burst.x, burst.y, size * burst.sizeFactor)
      end
    end),

    app.context.view.hud:subscribe(function()
      if self.tooltip.factor > 0 then
        local canvas = self.tooltip.canvas
        local u, v = self.u, self.v
        local x, y = canvas:getWidth() / 2, canvas:getHeight() - self.tooltip.margin
        local w, h = self.tooltip.width, self.tooltip.height
        local hs = self.tooltip.hintSize
        local points = {
          x, y,
          x - hs, y - hs,
          x - w / 2, y - hs,
          x - w / 2, y - h,
          x + w / 2, y - h,
          x + w / 2, y - hs,
          x + hs, y - hs
        }

        for i = 1, #points, 2 do
          points[i] = util.lerp(points[i], x, 1 - self.tooltip.factor)
          points[i + 1] = util.lerp(points[i + 1], y, 1 - self.tooltip.factor)
        end

        g.setCanvas(self.tooltip.backCanvas)
        love.graphics.clear(0, 0, 0, 0)

        g.setCanvas(canvas)
        love.graphics.clear(0, 0, 0, 0)

        g.setColor(0, 0, 0, 200 * self.tooltip.factor)

        local triangles = love.math.triangulate(points)
        for i = 1, #triangles do
          g.polygon('fill', triangles[i])
        end

        g.setCanvas()

        g.white()

        for i = 1, 3 do
          app.shaders.horizontalBlur:send('amount', .0025)
          app.shaders.verticalBlur:send('amount', .0025 * (canvas:getWidth() / canvas:getHeight()))
          g.setCanvas(self.tooltip.backCanvas)
          g.setShader(app.shaders.horizontalBlur)
          g.draw(canvas)
          g.setCanvas(canvas)
          g.setShader(app.shaders.verticalBlur)
          g.draw(self.tooltip.backCanvas)
        end

        g.setCanvas()
        g.setShader()

        local x, y = app.context.view:screenPoint(self.tooltip.x, self.tooltip.y)

        g.white()
        g.draw(self.tooltip.canvas, x, y, 0, 1, 1, canvas:getWidth() / 2, canvas:getHeight() - self.tooltip.margin)

        local buttonPadding = {
          x = .04 * v,
          y = .01 * v
        }

        local bx = x
        local by = util.lerp(y - canvas:getHeight() * .3, y, 1 - self.tooltip.factor)
        local bw = self.playText:getWidth() + 2 * buttonPadding.x
        local bh = self.playText:getHeight() + 2 * buttonPadding.y
        g.setLineWidth(5)
        g.setColor(152, 255, 130, self.tooltip.factor * 60)
        g.rectangle('fill', bx - bw / 2, by - bh / 2, bw, bh, 8, 8)
        g.setColor(152, 255, 130, self.tooltip.factor * 255)
        g.rectangle('line', bx - bw / 2, by - bh / 2, bw, bh, 8, 8)

        g.white(self.tooltip.factor * 255)
        g.draw(self.playText, bx - self.playText:getWidth() / 2, by - self.playText:getHeight() / 2)

        g.setFont(self.font)
        local scene = app.scenes[self.selected].name
        local titleY = util.lerp(y - canvas:getHeight() * .58, y, 1 - self.tooltip.factor)
        g.print(scene, x - g.getFont():getWidth(scene) / 2, titleY)
      end
    end),

    -- Selects scenes on tap, but only if mouse hasn't moved very far
    love.mousepressed
      :filter(function() return not self.editing end)
      :filter(isLeft)
      :flatMapLatest(function(x1, y1)
        return love.mousemoved
          :startWith(x1, y1)
          :map(function(x2, y2)
            return util.distance(x1, y1, x2, y2)
          end)
          :takeUntil(love.mousereleased:take(1))
          :max()
      end)
      :filter(function(distance)
        return distance < self.config.maxTapDistance
      end)
      :map(function() return app.context.view:worldMouseX(), app.context.view:worldMouseY() end)
      :map(function(x, y)
        local _, key = util.match(self.config.world, function(info)
          local dir = util.angle(info.x, info.y, x, y)
          return util.distance(info.x, info.y, x, y) <= self.config.markerSize * 2 / (1.5 - math.abs(math.cos(dir)) * .5)
        end)

        return key, x, y
      end)
      :subscribe(function(key, x, y)
        if not key then
          local burst = {
            factor = 1,
            sizeFactor = .5,
            x = x,
            y = y
          }

          table.insert(self.bursts, 1, burst)

          lib.flux.to(burst, .4, { factor = 0 })
            :ease('cubicout')
            :oncomplete(function()
              table.remove(self.bursts)
            end)

          return
        end

        if not self:isSceneAvailable(key) then
          self.shakeFactors[key] = 1
          lib.flux.to(self.shakeFactors, .3, { [key] = 0 }):ease('linear')
          return
        end

        local burst = {
          factor = 1,
          sizeFactor = 1,
          x = x,
          y = y
        }

        table.insert(self.bursts, 1, burst)

        lib.flux.to(burst, .4, { factor = 0 })
          :ease('cubicout')
          :oncomplete(function()
            table.remove(self.bursts)
          end)

        self:selectScene(key)
      end),

    love.mousepressed
      :filter(isLeft)
      :subscribe(function(x, y)
        self.dragStart.x = x
        self.dragStart.y = y
        self.dragStart.vx = app.context.view.x
        self.dragStart.vy = app.context.view.y
      end),

    love.mousereleased
      :filter(function() return not self.editing end)
      :filter(isLeft)
      :subscribe(function(x, y)
        if not self.selected then return nil end

        local u, v = self.u, self.v

        local buttonPadding = {
          x = .04 * v,
          y = .01 * v
        }

        local bw = self.playText:getWidth() + 2 * buttonPadding.x
        local bh = self.playText:getHeight() + 2 * buttonPadding.y

        local sx, sy = app.context.view:screenPoint(self.config.world[self.selected].x, self.config.world[self.selected].y)

        local bx = sx - bw / 2
        local by = sy - self.tooltip.canvas:getHeight() * .3 - bh / 2

        if util.inside(x, y, bx, by, bw, bh) then
          local selected = self.selected
          app.context.unload()
          app.context.load(selected)
        end
      end),

    love.mousepressed
      :filter(function() return self.editing end)
      :filter(isLeft)
      :map(function() return app.context.view:worldMouseX(), app.context.view:worldMouseY() end)
      :map(function(x, y)
        local _, key = util.match(self.config.world, function(info)
          local dir = util.angle(info.x, info.y, x, y)
          return util.distance(info.x, info.y, x, y) <= self.config.markerSize * 2 / (1.5 - math.abs(math.cos(dir)) * .5)
        end)

        return key
      end)
      :filter(f.id)
      :tap(function(key)
        self.dragging = key
        self.editOffset = {}
        self.editOffset.x = app.context.view:worldMouseX() - self.config.world[key].x
        self.editOffset.y = app.context.view:worldMouseY() - self.config.world[key].y
      end)
      :flatMapLatest(function()
        return love.mousemoved
          :startWith(love.mouse.getPosition())
          :map(util.fn(app.context.view.worldPoint, app.context.view))
          :takeUntil(love.mousereleased:filter(isLeft))
      end)
      :subscribe(function(x, y)
        self.config.world[self.dragging].x = x - self.editOffset.x
        self.config.world[self.dragging].y = y - self.editOffset.y
      end, print),

    love.mousereleased
      :filter(function() return self.editing end)
      :filter(isLeft)
      :subscribe(function()
        local file = io.open(love.filesystem.getWorkingDirectory() .. '/app/hud/worldPositions.lua', 'w+')
        if file then
          file:write('return ' .. util.serialize(self.config.world))
          file:close()
        end
        self.dragging = nil
      end)
  }
end

function hud:isSceneAvailable(key)
  return key == 'overgrowth'
end

function hud:selectScene(key)
  local changed = self.selected ~= key

  self.selected = key

  if changed or self.tooltip.factor == 0 then
    lib.flux.to(self.tooltip, .2, { factor = 0 })
      :ease('backin')
      :oncomplete(function()
        self.tooltip.x = self.config.world[self.selected].x
        self.tooltip.y = self.config.world[self.selected].y
      end)
      :after(self.tooltip, .35, { factor = 1 })
        :ease('backout')
  end
end

function hud:deselect()
  lib.flux.to(self.tooltip, .2, { factor = 0 })
    :ease('backin')
end

return hud
