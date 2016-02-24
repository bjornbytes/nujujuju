local bruju = lib.object.create()

bruju:include(lib.entity)
bruju:include(lib.minion)

bruju.config = app.minions.bruju.config

bruju.state = function()
  local state = {
    team = 'player',
    position = {
      x = app.context.scene.width / 2,
      y = app.context.scene.height / 2
    },
    target = {
      x = nil,
      y = nil
    },
    health = 5
  }

  state.animation = lib.animation.create(app.minions.bruju.spine, app.minions.bruju.animation)
  state.animation.speed = 1
  state.animation:set('idle')

  return state
end

function bruju:bind()
  self.abilities = {}
  self.abilities.auto = app.minions.abilities.move:new({ owner = self })

  self:setIsMinion()

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
          self.animation.flipped = sign < 0
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

function bruju:draw()
  local image = app.art.shadow
  local scale = 60 / image:getWidth()

  g.white(70)
  g.draw(image, self.position.x, self.position.y, 0, scale, scale / 1.5, image:getWidth() / 2, image:getHeight() / 2)

  g.setColor(80, 200, 90, 80)
  g.setLineWidth(3)
  g.ellipse('line', self.target.x, self.target.y, 30, 30 / 2)

  g.white(80)
  g.setLineWidth(1)
  g.ellipse('line', self.target.x, self.target.y, 30, 30 / 2)

  self.animation:draw(self.position.x, self.position.y)

  return -self.position.y
end

return bruju