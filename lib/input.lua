local input = lib.object.create()

local function isLeft(x, y, b)
  return b == 1
end

function input:isCasting()
  return self.casting
end

function input:getAbilityFromPosition(x, y)
  local candidates = util.filter(app.context.objects, 'isMinion')
  candidates = util.concat(candidates, { app.context.objects.muju })

  table.sort(candidates, function(a, b)
    return a.position.y > b.position.y
  end)

  for i, candidate in ipairs(candidates) do
    if candidate == app.context.objects.muju and util.distance(x, y, candidate.position.x, candidate.position.y) < candidate.config.radius then
      return candidate.abilities.auto, candidate
    elseif candidate.animation:contains(x, y) and candidate.abilities and candidate.abilities.auto then
      return candidate.abilities.auto, candidate
    end
  end
end

input.state = function()
  return {
    casting = nil,
    castOwner = nil,
    targetFactor = 0,
    targetActive = false
  }
end

function input:bind()
  self:dispose({
    love.mousepressed
      :filter(isLeft)
      :reject(self:wrap(self.isCasting))
      :map(self:wrap(self.getAbilityFromPosition))
      :filter(f.id)
      :tap(function(ability, owner)
        self.casting = ability
        self.castOwner = owner
      end)
      :flatMapLatest(function(ability)
        return love.mousereleased
          :filter(isLeft)
          :first()
          :map(function(x, y)
            return x, y, ability
          end)
      end)
      :subscribe(function(x, y, ability)
        ability:cast(x, y)
        self.casting = nil
      end, print),

    love.mousepressed
      :filter(isLeft)
      :subscribe(function(x, y, b)
        self.targetActive = true
        lib.flux.to(self, .3, { targetFactor = 1 })
          :ease('backinout')
      end),

    love.mousereleased
      :filter(isLeft)
      :subscribe(function(x, y, b)
        self.targetActive = false
        lib.flux.to(self, .3, { targetFactor = 0 })
          :ease('cubicout')
          :oncomplete(function()
            self.castOwner = nil
          end)
      end)
  })

  app.context.view.draw:subscribe(self:wrap(self.draw))
end

function input:draw()
  if self.targetFactor > 0 and self.castOwner then
    local ox, oy = self.castOwner.position.x, self.castOwner.position.y
    local points = {}
    local radius = 30
    local mx, my = love.mouse.getPosition()
    local dir = util.angle(ox, oy, mx, my)
    local pointCount = 80

    if not self.targetActive then
      radius = radius + 20 * (1 - self.targetFactor)
    end

    for i = 1, 80 do
      local x = mx + util.dx(radius, dir + (2 * math.pi * (i / 80)))
      local y = my + util.dy(radius, dir + (2 * math.pi * (i / 80)))
      local max = math.pi / 2 + (math.pi / 2) * util.distance(ox, oy, mx, my) / 500 -- how bulbous it is
      local dif = (max - util.clamp(math.abs(util.anglediff(util.angle(mx, my, x, y), dir + math.pi)), 0, max)) / max
      if self.targetActive then
        x = util.lerp(ox, x, self.targetFactor ^ 2)
        y = util.lerp(oy, y, self.targetFactor ^ 2)
      end
      x = util.lerp(x, ox, dif ^ 5)
      y = util.lerp(y, oy, dif ^ 5)

      table.insert(points, x)
      table.insert(points, y)
    end

    g.white(40 * self.targetFactor)
    g.polygon('fill', points)
  end

  return -1000
end

return input
