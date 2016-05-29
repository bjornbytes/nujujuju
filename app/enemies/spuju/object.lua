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

  self.abilities = {
    fear = app.abilities.fear:new()
  }

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
    bindState('fear'),
    bindState('run'),

    love.update
      :subscribe(function()
        if not self.dead and not self:isCarryingShruju() then
          local sign = self:signTo(self.target)

          if sign ~= 0 then
            self.animation.flipped = sign > 0
          end
        end
      end),

    self.animation.completions
      :filter(f.eq('death'))
      :subscribe(self:wrap(self.remove)),

    self.animation.completions
      :filter(f.eq('fear'))
      :subscribe(function()
        self.state = 'move'
      end),

    self.animation.completions
      :filter(f.eq('attack'))
      :subscribe(function()
        self.state = 'move'
      end),

    self.animation.events
      :pluck('data', 'name')
      :filter(f.eq('attack'))
      :subscribe(function()
        for i = 1, self.config.skullCount do
          app.context:addObject(app.spells.skull, {
            position = util.copy(self.position),
            destination = util.copy(self.target.position),
            owner = self,
            damage = self.config.damage
          })
        end

        self.state = 'move'
      end),

    app.context.view.draw
      :subscribe(self:wrap(self.draw))
  }
end

return spuju
