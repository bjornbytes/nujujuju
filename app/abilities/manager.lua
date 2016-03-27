local abilities = lib.object.create()

local function isLeft(x, y, b)
  return b == 1
end

local function hasTouch(id)
  return util.find(love.touch.getTouches(), id)
end

function abilities:isCasting()
  return self.casting
end

function abilities:init()
  self.selected = nil

  self.casts = {}

  -- TODO group these eventually once UI is decided
  self.list = {
    app.abilities.summon:new(),
    app.abilities.heal:new(),

    app.abilities.burst:new()
  }
end

function abilities:bind()
  local abilityCast, autoCast = love.touchpressed
    :map(function(id, x, y)
      return id, lib.target.objectAtPosition(app.context.view:worldPoint(x, y))
    end)
    :filter(function(id, owner)
      return owner and (owner.isMinion or owner == app.context.objects.muju)
    end)
    :partition(function()
      return self.selected
    end)

  return {

    abilityCast
      :filter(function(id, owner)
        return owner:canCast(self.selected)
      end)
      :tap(function(id, owner)
        local ox, oy = app.context.view:worldPoint(love.touch.getPosition(id))

        self.casts[id] = {
          id = id,
          ability = self.selected,
          owner = owner,
          ox = ox,
          oy = oy,
          active = true,
          factor = 0,
          tick = lib.tick.index
        }

        lib.flux.to(self.casts[id], .3, { factor = 1 }):ease('backinout')
      end)
      :flatMapLatest(function(id, owner)
        return love.touchreleased
          :filter(f.eq(id))
          :take(1)
      end)
      :subscribe(function(id, x, y)
        local mx, my = app.context.view:worldPoint(x, y)
        local cast = self.casts[id]

        if not cast then return end

        cast.active = false
        cast.x = mx
        cast.y = my

        cast.ability:cast(cast.owner, mx, my)

        lib.flux.to(cast, .35, { factor = 0 })
          :ease('cubicout')
          :oncomplete(function()
            if not hasTouch(id) then
              self.casts[id] = nil
            end
          end)

        self.selected = nil
      end),

    love.touchreleased
      :filter(function(id)
        local casting = util.match(self.casts, function(cast) return cast.active and cast.id == id end)
        return self.selected and not casting
      end)
      :subscribe(function()
        self.selected = nil
      end),

    autoCast
      :filter(function(id, owner)
        return owner.isMinion or owner:canCast(self.list[1])
      end)
      :tap(function(id, owner)
        local ox, oy = app.context.view:worldPoint(love.touch.getPosition(id))

        self.casts[id] = {
          id = id,
          ability = nil,
          owner = owner,
          ox = ox,
          oy = oy,
          active = true,
          factor = 0,
          tick = lib.tick.index
        }

        lib.flux.to(self.casts[id], .3, { factor = 1 }):ease('backinout')
      end)
      :flatMapLatest(function(id)
        return love.touchreleased
          :filter(f.eq(id))
          :take(1)
      end)
      :subscribe(function(id, x, y)
        local mx, my = app.context.view:worldPoint(x, y)
        local cast = self.casts[id]

        if not cast then return end

        cast.active = false
        cast.x = mx
        cast.y = my

        if cast.owner.isMinion then
          cast.owner:command(mx, my)
        else
          cast.owner:cast(self.list[1], mx, my)
        end

        lib.flux.to(cast, .35, { factor = 0 })
          :ease('cubicout')
          :oncomplete(function()
            if not hasTouch(id) then
              self.casts[id] = nil
            end
          end)
      end),

    app.context.view.draw:subscribe(self:wrap(self.draw))
  }
end

function abilities:draw()
  util.each(self.casts, function(cast)
    if cast.factor > 0 and cast.owner then
      local ox, oy = cast.owner.position.x, cast.owner.position.y
      local points = {}
      local radius = 35
      local tx, ty

      if cast.active and (util.find(love.touch.getTouches(), cast.id) or cast.id == 'm') then
        tx, ty = app.context.view:worldPoint(love.touch.getPosition(cast.id))
      else
        radius = radius + 20 * (1 - cast.factor)
        tx = cast.x
        ty = cast.y
      end

      if not tx or not ty then return end

      local entity = lib.target.objectAtPosition(tx, ty)
      if entity and entity.isEnemy then
        tx = util.lerp(tx, entity.position.x, .5)
        ty = util.lerp(ty, entity.position.y, .5)
        radius = radius + 10
      end

      local dir = util.angle(ox, oy, tx, ty)
      local pointCount = 80

      for i = 1, 80 do
        local x = tx + util.dx(radius, dir + (2 * math.pi * (i / 80)))
        local y = ty + util.dy(radius, dir + (2 * math.pi * (i / 80)))
        local mouseDir = util.angle(x, y, tx, ty)

        if util.distance(ox, oy, tx, ty) >= radius then
          local max = math.pi / 2 + (math.pi / 2) * util.distance(ox, oy, tx, ty) / 500 -- how bulbous it is
          local dif = (max - util.clamp(math.abs(util.anglediff(mouseDir, dir)), 0, max)) / max
          if cast.active then
            x = util.lerp(ox, x, cast.factor ^ 2)
            y = util.lerp(oy, y, cast.factor ^ 2)
          end
          x = util.lerp(x, ox, dif ^ 5)
          y = util.lerp(y, oy, dif ^ 5)
        end

        if util.distance(x, y, ox, oy) < 1 then
          table.insert(points, x)
          table.insert(points, y)
        else
          if util.distance(ox, oy, tx, ty) >= radius then
            local sign = util.sign(util.anglediff(mouseDir, dir))
            x = x + 2 * math.cos(dir + (math.pi / 2) * sign)
            y = y + 2 * math.sin(dir + (math.pi / 2) * sign)
          end
          table.insert(points, x)
          table.insert(points, y)
        end
      end

      if #points >= 3 then
        g.white(40 * cast.factor)
        g.setLineWidth(3)
        g.polygon('fill', points)
        g.setLineWidth(1)
      end

      local image, color, angle
      if self.selected then
        image = app.art.icons[self.selected.tag]
        color = { 255, 255, 255 }
        angle = 0
      else
        if cast.owner.isMinion then
          image = app.art.icons.command
          color = (entity and entity.isEnemy) and { 255, 140, 140 } or { 140, 255, 140 }
          angle = dir - math.pi / 4
        else
          image = app.art.icons.summon
          color = { 255, 255, 255 }
          angle = 0
        end
      end

      local w, h = image:getDimensions()
      local size = .75 * 2 * radius * cast.factor
      local scale = size / ((w > h) and w or h)

      g.setColor(g.alpha(color, 255 * cast.factor ^ 3))
      g.draw(image, tx, ty, angle, scale, scale, w / 2, h / 2)
    end
  end)

  return -1000
end

function abilities:isValidCastTarget(entity)
  --[[util.match(self.casts, function(cast)
    print(cast.ability)
    return cast.ability and cast.ability:canCast(entity)
  end)]]

  return self.selected and self.selected:canCast(entity)
end

return abilities
