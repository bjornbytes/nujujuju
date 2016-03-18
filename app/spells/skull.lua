local skull = lib.object.create():include(lib.entity)

skull.config = {
  gravity = 700,
  explosionSize = 40
}

function skull:bind()
  self.position.z = -1

  self.destination.x = self.destination.x + love.math.randomNormal(self.config.explosionSize / 2)
  self.destination.y = self.destination.y + love.math.randomNormal(self.config.explosionSize / 2)

  local v = 850
  local d = util.distance(self.position.x, self.position.y, self.destination.x, self.destination.y)
  local angle = util.angle(self.position.x, self.position.y, self.destination.x, self.destination.y)
  local gr = self.config.gravity
  local root = math.sqrt(v ^ 4 - (gr * (gr * d ^ 2)))
  local theta
  if root ~= root then
    theta = math.pi / 4
  else
    local a1, a2 = math.atan((v ^ 2 + root) / (gr * d)), math.atan((v ^ 2 - root) / (gr * d))
    theta = math.max(a1, a2)
  end

  self.velocity = {
    x = math.cos(theta) * math.cos(angle) * v,
    y = math.cos(theta) * math.sin(angle) * v,
    z = math.sin(theta) * -v
  }

  self.angle = love.math.random() * 2 * math.pi
  self.angularVelocity = love.math.random() * 2 * math.pi

  return {
    love.update:subscribe(function()
      self.position.x = self.position.x + self.velocity.x * lib.tick.rate
      self.position.y = self.position.y + self.velocity.y * lib.tick.rate
      self.position.z = self.position.z + self.velocity.z * lib.tick.rate

      self.velocity.z = self.velocity.z + self.config.gravity * lib.tick.rate

      if self.position.z >= 0 then
        local targets = util.filter(app.context.objects, function(object)
          if object.isMinion or object == app.context.objects.muju then
            local dir = self:directionTo(object)
            return self:distanceTo(object) < (self.config.explosionSize + object.config.radius) / (2 - math.abs(math.cos(dir)))
          end
        end)

        util.each(util.set(targets), function(target)
          target:hurt(self.damage, self.owner)
        end)

        self:unbind()
        app.context:removeObject(self)
      end
    end),

    love.update
      :subscribe(function()
        self.angle = self.angle + self.angularVelocity * lib.tick.rate
      end),

    app.context.view.draw:subscribe(function()
      g.setColor(255, 0, 0, 60)
      g.ellipse('fill', self.destination.x, self.destination.y, self.config.explosionSize, self.config.explosionSize / 2)

      g.setColor(0, 0, 0, 100)
      local shadowSize = 10 / util.clamp(math.abs(self.position.z / 200), 1, 10)
      g.ellipse('fill', self.position.x, self.position.y, shadowSize, shadowSize / 2)

      g.white()
      local image = app.art.skull
      local scale = g.imageScale(image, 20)
      g.draw(image, self.position.x, self.position.y + self.position.z / 2, self.angle, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

      return -self.position.y
    end)
  }
end

return skull
