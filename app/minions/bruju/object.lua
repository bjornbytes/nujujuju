local bruju = lib.object.create()

bruju.tag = 'bruju'

bruju:include(lib.entity)
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
      x = app.context.scene.width / 2,
      y = app.context.scene.height / 2
    },
    health = bruju.config.maxHealth,
    lastHurt = -math.huge
  }

  state.animation = lib.animation.create(app.minions.bruju.spine, app.minions.bruju.animation)
  state.animation.speed = 1

  return state
end

function bruju:bind()
  self.activeAbility = app.abilities.command:new({ owner = self })

  self:setIsMinion()

  return {
    love.update
      :subscribe(function()
        local sign
        if self.target then
          sign = self:signTo(self.target)
        else
          sign = util.sign(self.destination.x - self.position.x)
        end

        if sign ~= 0 then
          self.animation.flipped = sign < 0
        end
      end),

    love.update
      :subscribe(function()
        local targetIsUnavailable = self.target and self.target.isEnemy and (self.target.dead)

        if targetIsUnavailable then
          self.destination.x = self.position.x
          self.destination.y = self.position.y
          self.target = nil
        end

        if not self.target and self:distanceToPoint(self.destination.x, self.destination.y) == 0 then
          local closest = self:closest('enemy')

          if closest and not closest.dead and self:distanceTo(closest) <= self.config.aggroRange then
            self.target = closest
          end
        end

        if self.dead then return end

        if self.target then
          local distance = self:distanceTo(self.target)
          if distance <= self.config.radius + self.target.config.radius then
            if self.target.isEnemy then
              self.animation:set('attack')
            elseif util.isa(self.target, app.juju) then
              self.target:pickup(self)
              self.animation:set('idle')
            else
              self.animation:set('idle')
            end
          else
            local speed = math.min(self:getBaseSpeed() * lib.tick.rate, distance)
            self:moveTowards(self.target, speed)
            self.animation:set('walk')
          end
        else
          local distance = self:distanceToPoint(self.destination.x, self.destination.y)
          local speed = math.min(self:getBaseSpeed() * lib.tick.rate, distance)
          self:moveTowardsPoint(self.destination.x, self.destination.y, speed)

          if distance > 0 then
            self.animation:set('walk')
          else
            self.animation:set('idle')
          end
        end
      end),

    self.animation.completions
      :filter(f.eq('death'))
      :subscribe(self:wrap(self.remove)),

    self.animation.events
      :pluck('data', 'name')
      :filter(f.eq('attack'))
      :subscribe(function()
        if self.target then
          self.target:hurt(1, self)

          if self.target.dead then
            self.destination.x = self.position.x
            self.destination.y = self.position.y
          end
        end
      end),

    app.context.view.draw
      :subscribe(self:wrap(self.draw))
  }
end

function bruju:draw()
  local image = app.art.shadow
  local scale = 60 / image:getWidth()

  g.white(70)
  g.draw(image, self.position.x, self.position.y, 0, scale, scale / 1.5, image:getWidth() / 2, image:getHeight() / 2)

  self:drawRing(40, 200, 40)

  self.animation:tick(lib.tick.delta)

  if util.timeSince(self.lastHurt) < self.config.damageFlashDuration then
    self.animation:draw(self.position.x, self.position.y)
    app.shaders.colorize:send('color', { 1, 1, 1, 1 - util.timeSince(self.lastHurt) / self.config.damageFlashDuration })
    g.setShader(app.shaders.colorize)
    self.animation:draw(self.position.x, self.position.y)
    g.setShader()
  elseif not self:isInvincible() then-- or util.round(util.timeSince(self.lastHurt) * 4) % 2 == 0 then
    self.animation:draw(self.position.x, self.position.y)
  else
    self.animation.skeleton.a = .5
    self.animation:draw(self.position.x, self.position.y)
    self.animation.skeleton.a = 1
  end

  return -self.position.y
end

return bruju
