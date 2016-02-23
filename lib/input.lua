local input = lib.object.create()

local function isLeft(x, y, b)
  return b == 1
end

function input:isCasting()
  return self.casting or self.autoCasting
end

function input:getAutocast(x, y)
  local muju = app.context.objects.muju

  if util.distance(x, y, muju.position.x, muju.position.y) <= muju.config.radius then
    return muju.abilities.auto
  end
end

input.state = function()
  return {
    casting = nil,
    autoCasting = nil
  }
end

function input:bind()
  self:dispose({
    love.mousepressed
      :filter(isLeft)
      :reject(self:wrap(self.isCasting))
      :map(self:wrap(self.getAutocast))
      :filter(f.id)
      :tap(function(ability)
        self.autoCasting = ability
      end)
      :flatMapLatest(function(ability)
        return love.mousereleased
          :filter(isLeft)
          :map(function(x, y)
            return x, y, ability
          end)
      end)
      :subscribe(function(x, y, ability)
        ability:cast(x, y)
        self.autoCasting = nil
      end)
  })
end

return input
