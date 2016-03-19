local juju = lib.object.create():include(lib.entity)

juju.config = {
  radius = 15,
  gravity = 1000,
  maxBounces = 2,
  shape = 'circle'
}

function juju:init()
  self.position = {
    x = nil,
    y = nil
  }
  self.velocity = {
    x = love.math.randomNormal(50),
    y = love.math.randomNormal(50),
    z = -500
  }

  self.bounces = 0
end

function juju:bind()
  self.position.z = -1

  return {
    love.update
      :filter(function()
        return self.velocity.z == 0
      end)
      :subscribe(function()
        local closest = self:closest('minion')

        if closest and self:distanceTo(closest) <= self.config.radius + closest.config.radius then
          local muju = app.context.objects.muju
          muju.juju = muju.juju + 1
          self:unbind()
          app.context:removeObject(self)
        end
      end),

    love.update
      :subscribe(function()
        self.position.x = self.position.x + self.velocity.x * lib.tick.rate
        self.position.y = self.position.y + self.velocity.y * lib.tick.rate
        self.position.z = self.position.z + self.velocity.z * lib.tick.rate

        if self.position.z < 0 then
          self.velocity.z = self.velocity.z + self.config.gravity * lib.tick.rate
        end

        if self.velocity.z == 0 then
          self.velocity.x = util.lerp(self.velocity.x, 0, lib.tick.getLerpFactor(.1))
          self.velocity.y = util.lerp(self.velocity.y, 0, lib.tick.getLerpFactor(.1))
        end

        if self.position.z > 0 then
          self.velocity.x = self.velocity.x * .7
          self.velocity.y = self.velocity.y * .7

          if self.bounces < self.config.maxBounces then
            self.bounces = self.bounces + 1
            self.velocity.z = math.abs(self.velocity.z) * -.5
            self.position.z = -1
          else
            self.velocity.z = 0
            self.position.z = 0
          end
        end

        if self:isEscaped() then
          if self.position.y < 0 or self.position.y + self.config.radius > app.context.scene.height then
            self.velocity.y = -self.velocity.y
          else
            self.velocity.x = -self.velocity.x
          end
        end
      end),

    app.context.view.draw:subscribe(self:wrap(self.draw))
  }
end

function juju:draw()
  local image = app.art.shadow
  local scale = 80 / image:getWidth()

  g.white(50)
  g.draw(image, self.position.x, self.position.y, 0, scale, scale / 2, image:getWidth() / 2, image:getHeight() / 2)

  self:drawRing(80, 200, 80)

  local image = app.art.juju
  local scale = (self.config.radius * 2) / image:getWidth()
  local angle = math.sin((lib.tick.index + lib.tick.accum) / 20) / 5
  local offset = image:getHeight() * scale / 2

  g.white()
  g.draw(image, self.position.x, self.position.y - offset + self.position.z / 2, angle, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

  return -self.position.y - 1
end

return juju
