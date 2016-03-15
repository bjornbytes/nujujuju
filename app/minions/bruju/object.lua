local bruju = lib.object.create():include(lib.entity, lib.unit, lib.minion, lib.bruju)

function bruju:init()
  self.team = 'player'
  self.position = {
    x = app.context.scene.width / 2,
    y = app.context.scene.height / 2
  }
  self.destination = util.copy(self.position)
  self.health = bruju.config.maxHealth
  self.lastHurt = -math.huge
  self.state = 'spawn'

  self.animation = lib.animation.create(app.minions.bruju.spine, app.minions.bruju.animation)
  self.animation.speed = 1

  self.activeAbility = app.abilities.command:new({ owner = self })

  self:setIsMinion()
end

function bruju:bind()
  local function bindState(state)
    return love.update
      :reject(function() return self.dead end)
      :map(function() return self.state end)
      :filter(f.eq(state))
      :subscribe(self:wrap(self[state]))
  end

  return {
    bindState('spawn'),
    bindState('idle'),
    bindState('move'),
    bindState('attack'),

    love.update:subscribe(self:wrap(self.flipAnimation)),

    self.animation.completions
      :filter(f.eq('death'))
      :subscribe(self:wrap(self.remove)),

    self.animation.completions
      :filter(f.eq('spawn'))
      :subscribe(function()
        self.state = 'idle'
      end),

    self.animation.events
      :pluck('data', 'name')
      :filter(f.eq('attack'))
      :subscribe(self:wrap(self.onAttack)),

    app.context.view.draw
      :subscribe(self:wrap(self.draw))
  }
end

return bruju
