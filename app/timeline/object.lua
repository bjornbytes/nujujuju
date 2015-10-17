local timeline = lib.object.create()

timeline.state = function()
  return {
    time = 0,
    events = {}
  }
end

function timeline:bind()
  love.update
    :subscribe(function()
      self.time = self.time + lib.tick.rate
      if self.events[1] and self.events[1].time <= self.time then
        table.insert(app.context.objects, app.enemy.object:new({
          position = {
            x = 800,
            y = 600
          }
        }))
        table.remove(self.events, 1)
      end
    end)
end

function timeline:addEvent(event)
  table.insert(self.events, event)
  table.sort(self.events, function(a, b)
    return a.time < b.time
  end)
end

return timeline