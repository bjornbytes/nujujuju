local puju = lib.object.create():include(lib.entity, lib.unit, lib.enemy, lib.puju)

function puju:init()
  self.team = 'enemy'
  self.position = {
    x = app.context.scene.width / 2,
    y = app.context.scene.height / 2
  }
  self.velocity = {
    x = 0,
    y = 0
  }
  self.direction = 1
  self.target = nil
  self.health = puju.config.maxHealth
  self.dead = false
  self.lastHurt = -math.huge
  self.yank = 0
  self.floatOffset = lib.tick.index
  self.state = 'idle'
  self:setIsEnemy()
end

function puju:bind()
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

    love.update:subscribe(self:wrap(self.enclose)),
    love.update:subscribe(self:wrap(self.drift)),
    app.context.view.draw:subscribe(self:wrap(self.draw))
  }
end

puju.die = puju.remove

return puju
