local muju = {}

function muju:move(input)
  local x, y = input.x, input.y
  local config = self.config
  local direction = math.atan2(y, x)
  local length = math.min(math.distance(0, 0, x, y), 1)

  if x == 0 and y == 0 then
    self.speed.x = math.lerp(self.speed.x, 0, math.min(config.deceleration * lib.tick.rate, 1))
    self.speed.y = math.lerp(self.speed.y, 0, math.min(config.deceleration * lib.tick.rate, 1))
  else
    self.speed.x = math.lerp(self.speed.x, config.speed * math.cos(direction) * length, config.acceleration * lib.tick.rate)
    self.speed.y = math.lerp(self.speed.y, config.speed * math.sin(direction) * length, config.acceleration * lib.tick.rate)
  end

  self.position.x = self.position.x + self.speed.x * lib.tick.rate
  self.position.y = self.position.y + self.speed.y * lib.tick.rate
end

function muju:canShapeshift()
  return lib.tick.index - self.lastShapeshift > self.config.shapeshiftCooldown / lib.tick.rate and self.juju >= self.config.shapeshiftCost
end

function muju:shapeshift()
  self.form = self.form == 'muju' and 'thuju' or 'muju'
  self.animation = self.animations[self.form]

  if self.form == 'thuju' then
    self.animation:clear()
    self.animation:resetTo('spawn')
  end

  self.lastShapeshift = lib.tick.index
  self:spendJuju(self.config.shapeshiftCost)
end

function muju:attack()
  self.animation:set('attack')
end

function muju:animate(input)
  self.animation.speed = 1

  local moving = math.abs(input.x) > .5 or math.abs(input.y) > .5
  local speed = math.sqrt((self.speed.x ^ 2) + (self.speed.y ^ 2)) / self.config.speed

  if moving then
    self.animation:set('walk')
  elseif self.animation.config.states.walk.active and speed < 1 then
    self.animation:set('stop')
  end
end

function muju:interactWithBuilding()
  if self.nearbyBuilding and self.nearbyBuilding:canInteractWith(self) then
    self.nearbyBuilding:interact()
  end
end

function muju:flipAnimation()
  local x = self.speed.x
  if x ~= 0 then
    self.animation.flipped = x > 0
  end
end

function muju:setShuffleVolume()
  local speed = math.sqrt((self.speed.x ^ 2) + (self.speed.y ^ 2)) / self.config.speed
  self.shuffle:setVolume(speed * self.config.shuffleVolume)
end

function muju:setActiveBuilding()
  self.nearbyBuilding = nil
  local buildings = table.filter(app.context.objects, 'isBuilding')
  for _, building in pairs(buildings) do
    local distance = math.distance(self.position.x, self.position.y, building.position.x, building.position.y)
    local direction = math.direction(self.position.x, self.position.y, building.position.x, building.position.y)
    local a, b = building.config.radius, building.config.radius / building.config.perspective
    local r = (a * b) / math.sqrt((b * math.cos(direction)) ^ 2 + (a * math.sin(direction)) ^ 2)
    local ex = building.position.x + math.cos(direction + math.pi) * r
    local ey = building.position.y + math.sin(direction + math.pi) * r
    local overlap = self.config.radius - (math.distance(self.position.x, self.position.y, ex, ey))
    if overlap > -1 then
      self.nearbyBuilding = building
      return
    end
  end
end

function muju:jujuTrickle()
  self.jujuTrickleTimer = math.max(self.jujuTrickleTimer - lib.tick.rate, 0)
  if self.jujuTrickleTimer == 0 then
    self.jujuTrickleTimer = self.config.jujuTrickleRate
    self.juju = math.min(self.juju + 1, self.config.maxJuju)
  end
end

function muju:eventFootstep()
  local sound = love.audio.play(app.muju.sound['footstep' .. love.math.random(1, 2)])
  sound:setVolume(self.config.footstepVolume)
  sound:setPitch(.9 + love.math.random() * .2)
end

function muju:eventLimp()
  local sound = love.audio.play(app.muju.sound.staff)
  sound:setVolume(self.config.staffVolume)
  sound:setPitch(.8 + love.math.random() * .6)

  local x = self.position.x + (self.animation.flipped and 40 or -40)
  local y = self.position.y
  app.context.particles:emit('dust', x, y, 25, function()
    return { direction = love.math.random() < .5 and math.pi or 0 }
  end)
end

function muju:eventAttack()
  table.each(table.filter(app.context.objects, 'isEnemy'), function(enemy)
    local animationDirectionSign = self.animation.flipped and -1 or 1
    local closeEnough = math.distance(self.position.x, self.position.y, enemy.position.x, enemy.position.y) < (self.config.radius + enemy.config.radius) * self.config.staffHitboxThreshold
    local verticallyCloseEnough = math.abs(self.position.y - enemy.position.y) < self.config.staffYPositionThreshold
    local facingTheRightWay = animationDirectionSign == math.sign(self.position.x - enemy.position.x)
    if closeEnough and verticallyCloseEnough and facingTheRightWay then
      enemy:hurt(self.config.staffDamage)
      enemy:push({
        force = 6,
        direction = math.direction(self.position.x, self.position.y, enemy.position.x, enemy.position.y)
      })
    end
  end)
end

function muju:tint(r, g, b)
  for _, slot in pairs({'robebottom', 'torso', 'front_upper_arm', 'rear_upper_arm', 'front_bracer', 'rear_bracer'}) do
    local slot = self.animation.skeleton:findSlot(slot)
    slot.r, slot.g, slot.b = r, g, b
  end
end

function muju:eatMushroom()
  self.health = math.min(self.health + self.config.healthPerShruju, self.config.maxHealth)
  self.juju = math.min(self.juju + self.config.jujuPerShruju, self.config.maxJuju)
end

function muju:hurt(amount)
  if lib.tick.index - self.lastHurt < self.config.hurtGrace / lib.tick.rate then return end
  self.health = math.max(self.health - amount, 0)
  if self.health == 0 then
    print('you lose')
    love.event.quit()
  else
    self.lastHurt = lib.tick.index
  end
end

function muju:spendJuju(amount)
  self.juju = self.juju - amount
end

function muju:draw()
  local image = app.art.shadow
  local scale = 70 / image:getWidth()
  g.setColor(255, 255, 255, 120)
  g.draw(image, self.position.x, self.position.y, 0, scale, scale / 2, image:getWidth() / 2, image:getHeight() / 2)

  g.setColor(255, 255, 255)
  self.animation:tick(lib.tick.delta)
  if lib.tick.index - self.lastHurt > self.config.hurtGrace / lib.tick.rate or math.floor(lib.tick.index / (.25 / lib.tick.rate)) % 2 == 0 then
    self.animation:draw(self.position.x, self.position.y)
  end

  if app.context.inspector.active then
    g.setLineWidth(2)
    g.setColor(255, 255, 255, 50)
    g.circle('line', self.position.x, self.position.y, self.config.radius, 64)
  end

  return -self.position.y
end

return muju
