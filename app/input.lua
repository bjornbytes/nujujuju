local input = lib.object.create()

local function isLeft(x, y, b)
  return b == 1
end

function input:isCasting()
  return self.castContext.active
end

input.state = function()
  return {
    castContext = {
      active = false,
      ox = nil,
      oy = nil,
      owner = nil,
      ability = nil,
      tick = nil,
      factor = 0
    },
    selected = nil
  }
end

function input:bind()
  self:dispose({

    -- Autocast
    love.mousepressed
      :filter(isLeft)
      :filter(function(x, y)
        local kind  = app.context.objects.hud:getElement(x, y)
        return kind == nil
      end)
      :reject(self:wrap(self.isCasting))
      :map(function(...)
        return app.context.view:worldPoint(...)
      end)
      :map(lib.target.objectAtPosition)
      :tap(function(owner)
        self.selected = owner
      end)
      :filter(function(owner)
        if not owner or not owner.abilities or not owner.abilities.auto then return false end
        return not owner.abilities.auto.canCast or owner.abilities.auto:canCast()
      end)
      :tap(function(owner)
        self.castContext = {
          active = false,
          ox = app.context.view:worldMouseX(),
          oy = app.context.view:worldMouseY(),
          owner = owner,
          ability = owner.abilities.auto,
          tick = lib.tick.index,
          factor = 0
        }
      end)
      :flatMapLatest(function()
        return love.update
          :takeUntil(love.mousereleased)
          :tap(function()
            local context = self.castContext
            if not context.active then
              if util.distance(context.ox, context.oy, app.context.view:worldPoint(love.mouse.getPosition())) > 10 then
                context.active = true
                lib.flux.to(context, .3, { factor = 1 })
                  :ease('backinout')
              end
            end
          end)
          :sample(love.mousereleased:filter(isLeft):take(1))
      end)
      :subscribe(function()
        local context = self.castContext
        if context.active then
          local mx, my = app.context.view:worldPoint(love.mouse.getPosition())

          if not context.ability.canCastAtPosition or context.ability:canCastAtPosition(mx, my) then
            context.ability:cast(mx, my)
          end

          context.ability = nil
          context.active = false

          lib.flux.to(context, .3, { factor = 0 })
            :ease('cubicout')
            :oncomplete(function()
              context.owner = nil
            end)
        end
      end),

    love.mousereleased
      :filter(isLeft)
      :filter(f.negate(self:wrap(self.isCasting)))
      :filter(function() return self.selected end)
      :map(function(x, y)
        return app.context.objects.hud:getElement(x, y)
      end)
      :filter(f.id)
      :tap(function(_, index)
        self.castContext = {
          active = false,
          ox = app.context.view:worldMouseX(),
          oy = app.context.view:worldMouseY(),
          owner = self.selected,
          ability = self.selected.abilities[index],
          tick = lib.tick.index,
          factor = 0
        }

        self.castContext.active = true
        lib.flux.to(self.castContext, .3, { factor = 1 })
          :ease('backinout')
      end)
      :flatMapLatest(function()
        return love.mousepressed:filter(isLeft):take(1)
      end)
      :subscribe(function()
        local context = self.castContext
        if context.active then
          local mx, my = app.context.view:worldPoint(love.mouse.getPosition())

          if not context.ability.canCastAtPosition or context.ability:canCastAtPosition(mx, my) then
            context.ability:cast(mx, my)
          end

          context.ability = nil
          context.active = false

          lib.flux.to(context, .3, { factor = 0 })
            :ease('cubicout')
            :oncomplete(function()
              context.owner = nil
            end)
        end
      end),

    app.context.view.draw:subscribe(self:wrap(self.draw))
  })
end

function input:draw()
  local context = self.castContext
  if context.factor > 0 and context.owner then
    local ox, oy = context.owner.position.x, context.owner.position.y
    local points = {}
    local radius = 30
    local mx, my = app.context.view:worldPoint(love.mouse.getPosition())
    local dir = util.angle(ox, oy, mx, my)
    local pointCount = 80

    if not context.active then
      radius = radius + 20 * (1 - context.factor)
    end

    for i = 1, 80 do
      local x = mx + util.dx(radius, dir + (2 * math.pi * (i / 80)))
      local y = my + util.dy(radius, dir + (2 * math.pi * (i / 80)))
      local mouseDir = util.angle(x, y, mx, my)

      if util.distance(ox, oy, mx, my) >= radius then
        local max = math.pi / 2 + (math.pi / 2) * util.distance(ox, oy, mx, my) / 500 -- how bulbous it is
        local dif = (max - util.clamp(math.abs(util.anglediff(mouseDir, dir)), 0, max)) / max
        if context.active then
          x = util.lerp(ox, x, context.factor ^ 2)
          y = util.lerp(oy, y, context.factor ^ 2)
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
      g.white(40 * context.factor)
      g.setLineWidth(3)
      g.polygon('fill', points)
      g.setLineWidth(1)
    end
  end

  return -1000
end

return input
