local actions = {}

function actions.move(self)
  return function(input)
    local x, y = input.x, input.y
    local props = app.muju.props
    local direction = math.atan2(y, x)
    local length = math.min(math.distance(0, 0, x, y), 1)

    if x == 0 and y == 0 then
      self.speed.x = math.lerp(self.speed.x, 0, math.min(props.deceleration * lib.tick.rate, 1))
      self.speed.y = math.lerp(self.speed.y, 0, math.min(props.deceleration * lib.tick.rate, 1))
    else
      self.speed.x = math.lerp(self.speed.x, props.speed * math.cos(direction) * length, props.acceleration * lib.tick.rate)
      self.speed.y = math.lerp(self.speed.y, props.speed * math.sin(direction) * length, props.acceleration * lib.tick.rate)
    end

    self.position.x = self.position.x + self.speed.x * lib.tick.rate
    self.position.y = self.position.y + self.speed.y * lib.tick.rate
  end
end

function actions.footstep()
  local props = app.muju.props
  local sound = love.audio.play(app.muju.sound['footstep' .. love.math.random(1, 2)])
  sound:setVolume(props.footstepVolume)
  sound:setPitch(.9 + love.math.random() * .2)
end

function actions.limp(self)
  return function()
    local props = app.muju.props

    local sound = love.audio.play(app.muju.sound.staff)
    sound:setVolume(props.staffVolume)
    sound:setPitch(.8 + love.math.random() * .6)

    local x = self.position.x + (self.animation.flipped and 40 or -40)
    local y = self.position.y
    app.scene.particles:emit('dust', x, y, 25, function()
      return { direction = love.math.random() < .5 and math.pi or 0 }
    end)
  end
end

function actions.canShapeshift(self)
  return function()
    local props = app.muju.props
    return lib.tick.index - self.lastShapeshift > props.shapeshiftCooldown / lib.tick.rate
  end
end

function actions.animate(self)
  return function(_, input)
    local props = app.muju.props
    local speed = math.sqrt((self.speed.x ^ 2) + (self.speed.y ^ 2)) / props.speed
    self.animation.speed = 1
    local moving = math.abs(input.x) > .5 or math.abs(input.y) > .5
    if moving then
      self.animation:set('walk')
    elseif self.animation.state == self.animation.config.states.walk and speed < 1 then
      self.animation:set('stop')
      self.animation:add('idle')
    end
  end
end

function actions.flip(self)
  return function()
    local x = self.speed.x
    if x ~= 0 then
      self.animation.flipped = x > 0
    end
  end
end

function actions.resolveCollision(self, other)
  return function(dx, dy)
    self.position.x = math.lerp(self.position.x, self.position.x - dx / 2, 8 * lib.tick.rate)
    self.position.y = math.lerp(self.position.y, self.position.y - dy / 2, 8 * lib.tick.rate)

    other.position.x = math.lerp(other.position.x, other.position.x + dx / 2, 12 * lib.tick.rate)
    other.position.y = math.lerp(other.position.y, other.position.y + dy / 2, 12 * lib.tick.rate)
  end
end

function actions:tint(r, g, b)
  for _, slot in pairs({'robebottom', 'torso', 'front_upper_arm', 'rear_upper_arm', 'front_bracer', 'rear_bracer'}) do
    local slot = self.animation.skeleton:findSlot(slot)
    slot.r, slot.g, slot.b = r, g, b
  end
end

function actions.draw(self)
  return function()
    local props = app.muju.props

    local image = app.muju.art.shadow
    local scale = 70 / image:getWidth()
    g.setColor(255, 255, 255, 120)
    g.draw(image, self.position.x, self.position.y, 0, scale, scale / 2, image:getWidth() / 2, image:getHeight() / 2)

    g.setColor(255, 255, 255)
    self.animation:tick(lib.tick.delta)
    self.animation:draw(self.position.x, self.position.y)

    return -self.position.y
  end
end

return actions
