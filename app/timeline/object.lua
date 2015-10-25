local timeline = lib.object.create()

timeline.state = function()
  return {
    time = 0
  }
end

function timeline:bind()
  self:dispose({
    love.update
      :subscribe(function()
        self.time = self.time + lib.tick.rate
        if self.events[1] and self.events[1].time <= self.time then
          local enemy = app.enemy.object:new({
            position = {
              x = 800,
              y = 600
            }
          })
          app.context.objects[enemy] = enemy
          table.remove(self.events, 1)
        end
      end)
  })
end

function timeline:addEvent(event)
  table.insert(self.events, event)
  table.sort(self.events, function(a, b)
    return a.time < b.time
  end)
end

return timeline
