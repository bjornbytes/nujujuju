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
  self.abilities = {}

  self.abilities.move = app.minions.common.abilities.move:new({ owner = self })
  self.abilities.attack = app.minions.common.abilities.attack:new({ owner = self })
  self.abilities.auto = app.minions.common.abilities.auto:new({ owner = self })

  self.abilities[1] = self.abilities.move
  self.abilities[2] = self.abilities.attack

  self:setIsMinion()

  self:dispose({
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
        if self.target and (self.target.isEnemy and self.target.dead or self:isCarryingJuju()) then
          self.destination.x = self.position.x
          self.destination.y = self.position.y
          self.target = nil
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
      :subscribe(function()
        self:unbind()
        app.context:removeObject(self)
      end),

    self.animation.events
      :pluck('data', 'name')
      :filter(f.eq('attack'))
      :subscribe(function()
        if self.target then
          self.target:hurt(1)
          if self.target.dead then
            self.destination.x = self.position.x
            self.destination.y = self.position.y
          end
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

  self:drawRing(40, 200, 40)

  self.animation:tick(lib.tick.delta)

  if not self:isInvincible() or util.round((lib.tick.index - self.lastHurt) * lib.tick.rate * 3) % 2 == 0 then
    self.animation:draw(self.position.x, self.position.y)
  end

  return -self.position.y
end

function bruju:die()
  if not self.dead then
    self.dead = true
    self.animation:set('death')
  end
end

return bruju
