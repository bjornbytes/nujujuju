local spuju = {}

function spuju:idle()
  self.target = self:closest('minion', 'player')

  if self.target then
    self.state = 'move'
  end
end

function spuju:move()
  self.moveThread = self.moveThread or lib.quilt.add(function()
    while true do
      self.target = self:closest('minion', 'player')

      if self:inRange(self.target) and love.math.random() < .5 then
        --[[self.state = 'attack'
        self.moveThread = nil
        break}]]
      end

      local stdev = .1
      local targetx, targety
      repeat
        local angle = self.target:directionTo(self) + love.math.randomNormal(stdev)
        local range = self.config.range * 1
        targetx = self.target.position.x + util.dx(range, angle)
        targety = self.target.position.y + util.dy(range, angle)
        stdev = stdev + .1
      until targetx >= 0 and targetx <= app.context.scene.width and targety >= 0 and targety <= app.context.scene.height
      self.targetDirection = self:directionToPoint(targetx, targety)

      coroutine.yield(1)
    end
  end)

  self.direction = util.anglerp(self.direction, self.targetDirection, 1)--lib.tick.getLerpFactor(.02))
  self.animation:set('walk')

  self:moveInDirection(self.direction, self.config.speed)

  if self:isEscaped() then
    self:enclose()
  end
end

function spuju:attack()
  --
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
