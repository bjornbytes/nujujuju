local spuju = lib.object.create()

spuju:include(lib.entity)
spuju:include(lib.unit)
spuju:include(lib.enemy)

spuju.config = app.enemies.spuju.config

spuju.state = function()
  local state = {
    team = 'enemy',
    position = {
      x = app.context.scene.width / 2,
      y = app.context.scene.height / 2
    },
    target = nil,
    health = spuju.config.maxHealth,
    dead = false
  }

  state.animation = lib.animation.create(app.enemies.spuju.spine, app.enemies.spuju.animation)
  state.animation.speed = 1

  return state
end

function spuju:bind()
  self:setIsEnemy()

  self.target = self:closest('minion', 'player')

  self:dispose({
    love.update
      :subscribe(function()
        if not self.dead then
          local sign = self:signTo(self.target)

          if sign ~= 0 then
            self.animation.flipped = sign > 0
          end
        end
      end),

    self.animation.completions
      :filter(f.eq('death'))
      :subscribe(function()
        self:unbind()
        app.context:removeObject(self)
        local juju = app.juju:new({
          position = {
            x = self.position.x,
            y = self.position.y
          }
        })
        app.context.objects[juju] = juju
      end),

    self.animation.events
      :pluck('data', 'name')
      :filter(f.eq('attack'))
      :subscribe(function()
        self.target:hurt(1)
      end),

    love.update
      :subscribe(function()
        if self.target and self.target.isMinion and self.target.dead then
          self.target = nil
        end

        if self.dead then return end

        self.target = self:closest('minion', 'player')
        local distance = self:distanceTo(self.target)
        local speed = math.min(self.config.speed * lib.tick.rate, distance)
        if self:isInRangeOf(self.target) then
          self.animation:set('attack')
        else
          self:moveTowards(self.target, speed)
          self.animation:set('walk')
        end
      end),

    app.context.view.draw
      :subscribe(self:wrap(self.draw))
  })
end

function spuju:die()
  if not self.dead then
    self.dead = true
    self.animation:set('death')
  end
end

function spuju:draw()
  local image = app.art.shadow
  local scale = 60 / image:getWidth()

  g.white(70)
  g.draw(image, self.position.x, self.position.y, 0, scale, scale / 1.5, image:getWidth() / 2, image:getHeight() / 2)

  self:drawRing(200, 80, 80)

  self.animation:tick(lib.tick.delta)
  self.animation:draw(self.position.x, self.position.y)

  return -self.position.y
end

return spuju
