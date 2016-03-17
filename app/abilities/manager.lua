local abilities = lib.object.create()

local function isLeft(x, y, b)
  return b == 1
end

function abilities:isCasting()
  return self.active
end

function abilities:init()
  self.selected = nil
  self.casting = false
  self.ox = nil
  self.oy = nil
  self.x = nil
  self.y = nil
  self.owner = nil
  self.tick = nil
  self.factor = 0

  self.muju = {
    app.abilities.summon:new(),
    app.abilities.heal:new()
  }
end

function abilities:bind()
  return {

    -- Autocast
    love.mousepressed
      :filter(isLeft)
      :map(function(...)
        return app.context.view:worldPoint(...)
      end)
      :map(lib.target.objectAtPosition)
      :filter(f.id)
      :filter(function(owner)
        return owner.isMinion or owner == app.context.objects.muju
      end)
      :filter(function(owner)
        if not self.selected or self.selected == 'auto' then
          if owner == app.context.objects.muju then
            return self.muju[1]:canCast(owner)
          end

          return true
        end

        return self.selected:canCast(owner)
      end)
      :tap(function(owner)
        self.selected = self.selected or 'auto'
        self.casting = true
        self.ox = app.context.view:worldMouseX()
        self.oy = app.context.view:worldMouseY()
        self.owner = owner
        self.tick = lib.tick.index
        self.factor = 0
        lib.flux.to(self, .3, { factor = 1 }):ease('backinout')
      end)
      :flatMapLatest(function()
        return love.update
          :takeUntil(love.mousereleased)
          :sample(love.mousereleased:filter(isLeft):take(1))
      end)
      :subscribe(function()
        local mx, my = app.context.view:worldPoint(love.mouse.getPosition())

        if self.selected == 'auto' then
          if self.owner.isMinion then
            self.owner:command(mx, my)
          else
            self.muju[1]:cast(self.owner, mx, my)
          end
        else
          self.selected:cast(self.owner, mx, my)
        end

        self.casting = false
        self.x = mx
        self.y = my

        lib.flux.to(self, .35, { factor = 0 })
          :ease('cubicout')
          :oncomplete(function()
            self.owner = nil
            self.selected = nil
          end)
      end),

    app.context.view.draw:subscribe(self:wrap(self.draw))
  }
end

function abilities:draw()
  if self.factor > 0 and self.owner then
    local ox, oy = self.owner.position.x, self.owner.position.y
    local points = {}
    local radius = 30
    local mx, my = app.context.view:worldPoint(love.mouse.getPosition())

    if not self.casting then
      radius = radius + 20 * (1 - self.factor)
      mx = self.x
      my = self.y
    end

    local entity = lib.target.objectAtPosition(mx, my)
    if entity and entity.isEnemy then
      mx = util.lerp(mx, entity.position.x, .5)
      my = util.lerp(my, entity.position.y, .5)
    end

    local dir = util.angle(ox, oy, mx, my)
    local pointCount = 80

    for i = 1, 80 do
      local x = mx + util.dx(radius, dir + (2 * math.pi * (i / 80)))
      local y = my + util.dy(radius, dir + (2 * math.pi * (i / 80)))
      local mouseDir = util.angle(x, y, mx, my)

      if util.distance(ox, oy, mx, my) >= radius then
        local max = math.pi / 2 + (math.pi / 2) * util.distance(ox, oy, mx, my) / 500 -- how bulbous it is
        local dif = (max - util.clamp(math.abs(util.anglediff(mouseDir, dir)), 0, max)) / max
        if self.casting then
          x = util.lerp(ox, x, self.factor ^ 2)
          y = util.lerp(oy, y, self.factor ^ 2)
        end
        x = util.lerp(x, ox, dif ^ 5)
        y = util.lerp(y, oy, dif ^ 5)
      end

      if util.distance(x, y, ox, oy) < 1 then
        table.insert(points, x)
        table.insert(points, y)
      else
        if util.distance(ox, oy, mx, my) >= radius then
          local sign = util.sign(util.anglediff(mouseDir, dir))
          x = x + 2 * math.cos(dir + (math.pi / 2) * sign)
          y = y + 2 * math.sin(dir + (math.pi / 2) * sign)
        end
        table.insert(points, x)
        table.insert(points, y)
      end
    end

    if #points >= 3 then
      g.white(40 * self.factor)
      g.setLineWidth(3)
      g.polygon('fill', points)
      g.setLineWidth(1)
    end

    local image
    local color
    if self.selected == 'auto' then
      if self.owner.isMinion then
        image = app.art.icons.command
        color = (entity and entity.isEnemy) and { 255, 140, 140 } or { 140, 255, 140 }
      else
        image = app.art.icons.summon
        color = { 255, 255, 255 }
      end
    else
      image = app.art.icons[self.selected.tag]
      color = { 255, 255, 255 }
    end
    local w, h = image:getDimensions()
    local size = .75 * 2 * radius * self.factor
    local scale = size / ((w > h) and w or h)

    g.setColor(g.alpha(color, 255 * self.factor ^ 3))
    g.draw(image, mx, my, 0, scale, scale, w / 2, h / 2)
  end

  return -1000
end

return abilities
