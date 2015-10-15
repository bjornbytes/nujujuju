local ai = lib.object.create()

function ai.state()
  return {
    state = 'moving',
    threads = {},
    speed = {
      x = 0,
      y = 0
    },
  }
end

function ai:bind()
  local owner = self.owner

  self.threads.move = function()
    self.state = 'move'
    while true do
      self:chooseDirection()
      coroutine.yield(2)
    end
  end

  self.threads.attack = function()
    self.state = 'windup'
    coroutine.yield(.75)
    self.direction = owner:directionTo(app.context.objects.muju)
    coroutine.yield(.25)

    self.state = 'attack'
    coroutine.yield(.4)
    lib.quilt.remove(self.threads.attack)
    lib.quilt.add(self.threads.move)
  end

  self.threads.scan = function()
    while true do
      if self.state == 'move' and owner:isInRangeOf(app.context.objects.muju) then
        lib.quilt.remove(self.threads.move)
        lib.quilt.add(self.threads.attack)
      end
      coroutine.yield()
    end
  end

  lib.quilt.add(self.threads.move)
  lib.quilt.add(self.threads.scan)

  local currentState = love.update:map(function() return self.state end)

  self:dispose({
    currentState
      :filter(f.eq('move'))
      :subscribe(function()
        lib.entity.adjustSpeedToVector(self, owner.config.speed * 2, self.direction, 3)
        owner.animation:set('walk')
      end),

    currentState
      :filter(f.eq('windup'))
      :subscribe(function()
        lib.entity.adjustSpeedToVector(self, 0, self.direction, 8)
        owner.animation:set('attack')
      end),

    currentState
      :filter(f.eq('attack'))
      :subscribe(function()
        lib.entity.adjustSpeedToVector(self, owner.config.speed * 6, self.direction)
        owner.animation:set('idle')
      end),

    love.update
      :subscribe(function()
        owner:moveWithSpeed(self.speed)
        owner.animation.flipped = self.speed.x > 0
      end)
  })
end

function ai:unbind()
  lib.quilt.remove(self.threads.move, self.threads.attack, self.threads.scan)
  lib.object.unbind(self)
end

-- consider lib/spuju/ai
function ai:chooseDirection()
  local owner = self.owner
  local dx, dy = 0, 0

  while dx == 0 and dy == 0 do
    if owner.position.x < app.context.scene.width / 2 then
      if owner.position.x > app.context.scene.width / 4 and love.math.random() < .75 then
        dx = love.math.random(-1, 1)
      else
        dx = love.math.random(0, 1)
      end
    else
      if owner.position.x < app.context.scene.width * 3 / 4 and love.math.random() < .75 then
        dx = love.math.random(-1, 1)
      else
        dx = love.math.random(-1, 0)
      end
    end

    if owner.position.y < app.context.scene.height / 2 then
      if owner.position.y > app.context.scene.height / 4  and love.math.random() < .75 then
        dy = love.math.random(-1, 1)
      else
        dy = love.math.random(0, 1)
      end
    else
      if owner.position.y < app.context.scene.height * 3 / 4 and love.math.random() < .75 then
        dy = love.math.random(-1, 1)
      else
        dy = love.math.random(-1, 0)
      end
    end
  end

  self.direction = math.direction(0, 0, dx, dy) + love.math.randomNormal(.1)
end

return ai
