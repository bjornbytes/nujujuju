local juju = lib.object.create()

juju:include(lib.entity)

juju.config = {
  radius = 15
}

function juju:state()
  return {
    carrier = nil,
    position = {
      x = nil,
      y = nil
    }
  }
end

function juju:bind()
  return self:dispose({
    love.update
      :filter(function() return self.carrier end)
      :subscribe(function()
        self.position.x = self.carrier.position.x
        self.position.y = self.carrier.position.y
        local muju = app.context.objects.muju
        if self:distanceTo(muju) <= self.carrier.config.radius + muju.config.radius + 5 then
          self.carrier.destination.x = self.carrier.position.x
          self.carrier.destination.y = self.carrier.position.y
          self.carrier.target = nil
          muju.maxJuju = math.min(muju.maxJuju + 1, muju.config.maxJuju)
          muju.juju = muju.maxJuju
          self:unbind()
          app.context:removeObject(self)
        end
      end),

    app.context.view.draw:subscribe(self:wrap(self.draw))
  })
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
  g.draw(image, self.position.x, self.position.y - offset, angle, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

  return -self.position.y - 1
end

function juju:isHovered(x, y)
  local size = self.config.radius * 2
  return util.inside(x, y, self.position.x - size * .5, self.position.y - size * .75, size, size)
end

function juju:isSelected()
  return false
end

function juju:pickup(carrier)
  if not self.carrier then
    self.carrier = carrier
  end
end

return juju
