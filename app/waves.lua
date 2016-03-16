local waves = lib.object.create()

function waves:init()
  self.current = 1
  self.event = 1
  self.grace = 0
end

function waves:bind()
  self.waves = self.waves or {}

  self.current = 0
  self.event = 1
  self.grace = 5
  self.waveStart = lib.tick.index

  return {
    love.update
      :subscribe(function()
        if not self.waves[self.current] then return end

        local events = self.waves[self.current].events
        local event = events[self.event]

        if event and (lib.tick.index - self.waveStart) * lib.tick.rate >= (event.time or 0) then
          self:spawn(event.kind, event.count)
          self.event = self.event + 1
        end
      end),

    love.update
      :subscribe(function()
        local enemyCount = #util.filter(app.context.objects, 'isEnemy')
        if self.grace == 0 and self.current < #self.waves and self.event > #self.waves[self.current].events and enemyCount == 0 then
          self.grace = 5
        end
      end),

    love.update
      :filter(function() return self.grace > 0 end)
      :subscribe(function()
        self.grace = math.max(self.grace - lib.tick.rate, 0)
        if self.grace == 0 then
          self.current = self.current + 1
          self.event = 1
          self.waveStart = lib.tick.index
        end
      end)
  }
end

function waves:spawn(kind, count)
  count = count or 1

  for i = 1, count do
    local x = love.math.random() > .5 and app.context.scene.width - 50 or 50
    local y = 100 + love.math.random() * (app.context.scene.height - 200)

    app.context:addObject(app.enemies[kind].object, {
      position = {
        x = x,
        y = y
      }
    })
  end
end

return waves
