local input = lib.object.create()

local function isLeft(x, y, b)
  return b == 1
end

function input:isCasting()
  return self.casting
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
    love.mousepressed
      :filter(isLeft)
      :reject(self:wrap(self.isCasting))
      :map(lib.target.objectAtPosition)
      :tap(function(owner)
        self.selected = owner
      end)
      :filter(function(owner)
        return owner and owner.abilities and owner.abilities.auto
      end)
      :tap(function(owner)
        self.castContext = {
          active = false,
          ox = love.mouse.getX(),
          oy = love.mouse.getY(),
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
              if util.distance(context.ox, context.oy, love.mouse.getPosition()) > 10 then
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
          context.ability:cast(love.mouse.getPosition())
          context.ability = nil
          context.active = false
          lib.flux.to(context, .3, { factor = 0 })
            :ease('cubicout')
            :oncomplete(function()
              context.owner = nil
            end)
        end
      end, print)
  })

  app.context.view.draw:subscribe(self:wrap(self.draw))
end

function input:draw()
  local context = self.castContext
  if context.factor > 0 and context.owner then
    local ox, oy = context.owner.position.x, context.owner.position.y
    local points = {}
    local radius = 30
    local mx, my = love.mouse.getPosition()
    local dir = util.angle(ox, oy, mx, my)
    local pointCount = 80

    if not context.active then
      radius = radius + 20 * (1 - context.factor)
    end

    for i = 1, 80 do
      local x = mx + util.dx(radius, dir + (2 * math.pi * (i / 80)))
      local y = my + util.dy(radius, dir + (2 * math.pi * (i / 80)))
      local max = math.pi / 2 + (math.pi / 2) * util.distance(ox, oy, mx, my) / 500 -- how bulbous it is
      local dif = (max - util.clamp(math.abs(util.anglediff(util.angle(mx, my, x, y), dir + math.pi)), 0, max)) / max
      if context.active then
        x = util.lerp(ox, x, context.factor ^ 2)
        y = util.lerp(oy, y, context.factor ^ 2)
      end
      x = util.lerp(x, ox, dif ^ 5)
      y = util.lerp(y, oy, dif ^ 5)

      table.insert(points, x)
      table.insert(points, y)
    end

    g.white(40 * context.factor)
    g.polygon('fill', points)
  end

  return -1000
end

return input
