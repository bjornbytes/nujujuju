local spuju = lib.object.create():include(lib.entity, lib.unit, lib.enemy)

function spuju:init()
  self.team = 'enemy'
  self.position = {
    x = app.context.scene.width / 2,
    y = app.context.scene.height / 2
  }
  self.target = nil
  self.health = spuju.config.maxHealth
  self.dead = false
  self.lastHurt = -math.huge

  self.animation = lib.animation.create(app.enemies.spuju.spine, app.enemies.spuju.animation)
  self.animation.speed = 1
end

function spuju:bind()
  self:setIsEnemy()

  self.target = self:closest('minion', 'player')

  return {
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
      :subscribe(self:wrap(self.remove)),

    self.animation.events
      :pluck('data', 'name')
      :filter(f.eq('attack'))
      :subscribe(function()
        self.target:hurt(1, self)
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
  }
end

function spuju:draw()
  local image = app.art.shadow
  local scale = 60 / image:getWidth()

  g.white(70)
  g.draw(image, self.position.x, self.position.y, 0, scale, scale / 1.5, image:getWidth() / 2, image:getHeight() / 2)

  self:drawRing(255, 40, 40)

  self.animation:tick(lib.tick.delta)

  if util.timeSince(self.lastHurt) < self.config.damageFlashDuration then
    self.animation:draw(self.position.x, self.position.y)
    app.shaders.colorize:send('color', { 1, 1, 1, 1 - util.timeSince(self.lastHurt) / self.config.damageFlashDuration })
    g.setShader(app.shaders.colorize)
    self.animation:draw(self.position.x, self.position.y)
    g.setShader()
  else
    self.animation:draw(self.position.x, self.position.y)
  end


  return -self.position.y
end

return spuju
