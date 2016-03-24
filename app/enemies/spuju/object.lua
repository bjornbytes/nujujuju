local spuju = lib.object.create():include(lib.entity, lib.unit, lib.enemy, lib.spuju)

function spuju:init()
  self.team = 'enemy'
  self.position = {
    x = app.context.scene.width / 2,
    y = app.context.scene.height / 2
  }
  self.destination = util.copy(self.position)
  self.direction = 0
  self.targetDirection = 0
  self.target = nil
  self.health = spuju.config.maxHealth
  self.dead = false
  self.lastHurt = -math.huge

  self.state = 'idle'

  self.collisions = app.context.collision:add(self)

  self.animation = lib.animation.create(app.enemies.spuju.spine, app.enemies.spuju.animation)
  self.animation.speed = 1

  self:setIsEnemy()
end

function spuju:bind()
  local function bindState(state)
    return love.update
      :reject(function() return self.dead end)
      :map(function() return self.state end)
      :filter(f.eq(state))
      :subscribe(self:wrap(self[state]))
  end

  return {
    bindState('idle'),
    bindState('move'),
    bindState('attack'),

    love.update
      :subscribe(function()
        if not self.dead then
          local sign = self:signTo(self.target)

          if sign ~= 0 then
            self.animation.flipped = sign > 0
          end
        end
      end),

    self.animation.completions
      :filter(f.eq('death'))
      :subscribe(self:wrap(self.remove)),

    self.animation.events
      :pluck('data', 'name')
      :filter(f.eq('attack'))
      :subscribe(function()
        app.context:addObject(app.spells.skull, {
          position = util.copy(self.position),
          destination = util.copy(self.target.position),
          owner = self,
          damage = self.config.damage
        })
      end),

    --[[love.update
      :subscribe(function()
        if self.target and self.target.isMinion and self.target.dead then
          self.target = nil
        end

        if self.dead then return end

        self.target = self:closest('minion', 'player')
        local distance = self:distanceTo(self.target)
        local speed = math.min(self.config.speed * lib.tick.rate, distance)
        if self:isInRangeOf(self.target) then
          self.animation:set('attack')
        else
          self:moveTowards(self.target, speed)
          self.animation:set('walk')
        end
      end),]]

    app.context.view.draw
      :subscribe(self:wrap(self.draw))
  }
end

return spuju
