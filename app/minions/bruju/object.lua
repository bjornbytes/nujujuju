local bruju = lib.object.create()

bruju:include(lib.unit)
bruju:include(lib.minion)

bruju.config = app.minions.bruju.config

bruju.state = function()
  local state = {
    team = 'player',
    position = {
      x = app.context.scene.width / 2,
      y = app.context.scene.height / 2
    },
    destination = {
      x = nil,
      y = nil
    },
    health = bruju.config.maxHealth
  }

  state.animation = lib.animation.create(app.minions.bruju.spine, app.minions.bruju.animation)
  state.animation.speed = 1
  state.animation:set('idle')

  return state
end

function bruju:bind()
  self.abilities = {}
  self.abilities.auto = app.minions.common.abilities.auto:new({ owner = self })

  self:setIsMinion()

  self:dispose({
    love.update
      :subscribe(function()
        if self.target then
          local distance = self:distanceTo(self.target)
          if distance <= self.config.radius + self.target.config.radius then
            self.animation:set('idle')
          else
            self.animation:set('walk')
          end
        elseif self:distanceToPoint(self.destination.x, self.destination.y) > 0 then
          self.animation:set('walk')
        else
          self.animation:set('idle')
        end

        local sign
        if self.target then
          sign = self:signTo(self.target)
        else
          sign = util.sign(self.destination.x - self.position.x)
        end

        if sign ~= 0 then
          self.animation.flipped = sign < 0
        end

        self.animation:tick(lib.tick.rate)
      end),

    love.update
      :subscribe(function()
        if self.target then
          local distance = self:distanceTo(self.target)
          if distance <= self.config.radius + self.target.config.radius then
            -- attack I guess
          else
            local speed = math.min(self.config.speed * lib.tick.rate, distance)
            self:moveTowards(self.target, speed)
          end
        else
          local distance = self:distanceToPoint(self.destination.x, self.destination.y)
          local speed = math.min(self.config.speed * lib.tick.rate, distance)
          self:moveTowardsPoint(self.destination.x, self.destination.y, speed)
        end
      end),

    app.context.view.draw
      :subscribe(self:wrap(self.draw))
  })
end

function bruju:draw()
  local image = app.art.shadow
  local scale = 60 / image:getWidth()

  g.white(70)
  g.draw(image, self.position.x, self.position.y, 0, scale, scale / 1.5, image:getWidth() / 2, image:getHeight() / 2)

  self:drawRing(80, 200, 80)

  self.animation:draw(self.position.x, self.position.y)

  return -self.position.y
end

return bruju
