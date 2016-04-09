local muju = {}

function muju:tint(r, g, b)
  for _, slot in pairs({'robebottom', 'torso', 'front_upper_arm', 'rear_upper_arm', 'front_bracer', 'rear_bracer'}) do
    local slot = self.animation.skeleton:findSlot(slot)
    slot.r, slot.g, slot.b = r, g, b
  end
end

function muju:hurt(amount)
  return
end

function muju:addJuju(amount)
  self.juju = self.juju + amount
  self.totalJuju = self.totalJuju + amount
end

function muju:spendJuju(amount)
  self.juju = self.juju - amount
end

function muju:draw()
  local image = app.environment.art.stump
  local scale = 60 / image:getWidth()

  self:drawRing(180, 40, 255)

  g.white()
  g.draw(image, self.position.x, self.position.y - 10, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

  self.animation:tick(lib.tick.delta)
  self.animation:draw(self.position.x, self.position.y)

  return -self.position.y
end

return muju
