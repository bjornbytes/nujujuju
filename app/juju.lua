local juju = lib.object.create()

juju:include(lib.entity)

juju.config = {
  radius = 15
}

function juju:state()
  return {
    position = {
      x = nil,
      y = nil
    }
  }
end

function juju:bind()
  return self:dispose({
    love.update
      :subscribe(function()
        local closest = self:closest('minion')

        if closest and self:distanceTo(closest) <= self.config.radius + closest.config.radius then
          local muju = app.context.objects.muju
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

return juju
