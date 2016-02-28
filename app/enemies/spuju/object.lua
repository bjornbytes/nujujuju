local spuju = lib.object.create()

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
    target = {
      x = nil,
      y = nil
    },
    health = spuju.config.maxHealth
  }

  state.animation = lib.animation.create(app.enemies.spuju.spine, app.enemies.spuju.animation)
  state.animation.speed = 1

  return state
end

function spuju:bind()
  self:setIsEnemy()

  self.target.x = self.position.x + 1
  self.target.y = self.position.y

  self:dispose({
    love.update
      :subscribe(function()
        if self:distanceToPoint(self.target.x, self.target.y) > 0 then
          self.animation:set('walk')
        else
          self.animation:set('idle')
        end

        local sign = util.sign(self.target.x - self.position.x)

        if sign ~= 0 then
          self.animation.flipped = sign > 0
        end

        self.animation:tick(lib.tick.rate)
      end),

    love.update
      :subscribe(function()
        local distance = self:distanceToPoint(self.target.x, self.target.y)
        local speed = math.min(self.config.speed * lib.tick.rate, distance)
        return self:moveTowardsPoint(self.target.x, self.target.y, speed)
      end),

    app.context.view.draw
      :subscribe(self:wrap(self.draw))
  })
end

function spuju:draw()
  local image = app.art.shadow
  local scale = 60 / image:getWidth()

  g.white(70)
  g.draw(image, self.position.x, self.position.y, 0, scale, scale / 1.5, image:getWidth() / 2, image:getHeight() / 2)

  self:drawRing(200, 80, 80)

  self.animation:draw(self.position.x, self.position.y)

  return -self.position.y
end

return spuju
