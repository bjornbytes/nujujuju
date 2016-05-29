local shruju = lib.object.create():include(lib.entity)

function shruju:init()
  self.carrier = nil
  self.isShruju = true

  local animationKey = 'shruju1'
  local animation = app.shruju.animations[animationKey]
  self.animation = lib.animation.create(animation.spine, animation.config)
  self.animation:set('idle')
end

function shruju:bind()
  self.initialPosition = util.copy(self.position)

  return {
    love.update
      :filter(function() return self.carrier end)
      :subscribe(function()
        self.position.x = self.carrier.position.x
        self.position.y = self.carrier.position.y

        local distanceToStart = self:distanceToPoint(self.initialPosition.x, self.initialPosition.y)
        if self.carrier.isMinion and distanceToStart < self.carrier.config.radius / 2 then
          self.carrier = nil
          self.position.x = self.initialPosition.x
          self.position.y = self.initialPosition.y
        end
      end),

    app.context.view.draw
      :subscribe(self:wrap(self.draw))
  }
end

function shruju:pickup(carrier)
  if not self.carrier then
    self.carrier = carrier

    return true
  end

  return false
end

function shruju:die()
  app.context:removeObject(self)
  self:unbind()

  app.context.view:screenshake(.1)

  if #util.filter(app.context.objects, 'isShruju') == 0 then
    app.context:unload()
    app.context.load('overgrowth')
  end
end

function shruju:draw()
  if not self.carrier then
    local image = app.art.shadow
    local size = self.config.radius * 3
    local scale = g.imageScale(image, size)

    g.white(50)
    g.draw(image, self.position.x, self.position.y, 0, scale, scale / 2, image:getWidth() / 2, image:getHeight() / 2)
  end

  local actualPosition = self.position
  self.position = self.initialPosition

  if actualPosition.x ~= self.initialPosition.x or actualPosition.y ~= self.initialPosition.y then
    self:drawRing(255, 40, 40)
  else
    self:drawRing(40, 200, 40)
  end

  self.position = actualPosition

  self.animation:tick(lib.tick.delta)
  self.animation:draw(self.position.x, self.position.y)

  return -self.position.y - 5
end

return shruju
