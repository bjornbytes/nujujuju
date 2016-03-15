local puju = lib.object.create():include(lib.entity, lib.unit, lib.enemy)

function puju:init()
  self.team = 'enemy'
  self.position = {
    x = app.context.scene.width / 2,
    y = app.context.scene.height / 2
  }
  self.velocity = {
    x = 0,
    y = 0
  }
  self.direction = 1
  self.target = nil
  self.health = puju.config.maxHealth
  self.dead = false
  self.lastHurt = -math.huge
  self.attackTimer = 0
  self.yank = 0
  self.floatOffset = lib.tick.index
end

function puju:bind()
  self:setIsEnemy()

  self.target = self:closest('minion', 'player')

  return {
    love.update
      :subscribe(self:wrap(self.enclose)),

    love.update
      :subscribe(function()
        if self.target and self.target.isMinion and self.target.dead then
          self.target = nil
        end

        if self.dead then return end

        self.target = self:closest('minion', 'player')

        if not self.target then return end

        local distance = self:distanceTo(self.target)
        local speed = math.min(self.config.speed * lib.tick.rate, distance)

        self.direction = -self:signTo(self.target)

        self.attackTimer = math.max(self.attackTimer - lib.tick.rate, 0)
        if self:isInRangeOf(self.target) then
          if self.attackTimer == 0 then
            local angle = self:directionTo(self.target) + math.pi
            self.velocity.x = util.dx(3, angle)
            self.velocity.y = util.dy(3, angle)
            self.target:hurt(1, self)
            self.attackTimer = self.config.attackSpeed
          end
        end

        local distance = self:distanceTo(self.target)
        local angle = self:directionTo(self.target)

        local targetVelocityX = math.cos(angle) * self.config.speed * lib.tick.rate
        local targetVelocityY = math.sin(angle) * self.config.speed * lib.tick.rate

        local distanceFactor = util.clamp((distance - self.config.range) / (self.config.range / 4), 0, 1)

        self.velocity.x = util.lerp(self.velocity.x, targetVelocityX * distanceFactor, lib.tick.getLerpFactor(self.config.acceleration))
        self.velocity.y = util.lerp(self.velocity.y, targetVelocityY * distanceFactor, lib.tick.getLerpFactor(self.config.acceleration))

        self.velocity.x = self.velocity.x + math.sin((self.floatOffset + lib.tick.index) * lib.tick.rate * 2) * lib.tick.rate
        self.velocity.y = self.velocity.y + math.cos((self.floatOffset + lib.tick.index) * lib.tick.rate * 2) * lib.tick.rate

        self.position.x = self.position.x + self.velocity.x
        self.position.y = self.position.y + self.velocity.y

        local yank = util.clamp(self.velocity.x / (self.config.speed * lib.tick.rate), -1, 1)
        self.yank = util.lerp(self.yank, yank, lib.tick.getLerpFactor(.02))
      end),

    app.context.view.draw
      :subscribe(function()
        local image = app.art.shadow
        local offset = math.sin(lib.tick.index * lib.tick.rate * 3) * 4
        local scale = g.imageScale(image, 70 + offset)

        g.white(70)
        g.draw(image, self.position.x, self.position.y, 0, scale, scale / 1.5, image:getWidth() / 2, image:getHeight() / 2)

        self:drawRing(255, 40, 40)

        local image = app.art.puju
        local scale = g.imageScale(image, 35)

        g.white()
        g.draw(image, self.position.x, self.position.y - 20 + offset - image:getHeight() * scale, self.yank * .4, scale * self.direction, scale, image:getWidth() / 2, 0)

        return -self.position.y
      end)
  }
end

puju.die = puju.remove

return puju
