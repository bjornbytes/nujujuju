local totem = lib.object.create()

totem.config = app.totem.config

totem.state = function()
  return {
    time = app.totem.config.maxTime
  }
end

function totem:bind()
  self.decay = love.update
    :subscribe(function()
      self.time = math.max(self.time - lib.tick.rate, 0)
      if self.time == 0 then
        self:unbind()
      end
    end)

  self.target = love.update
    :subscribe(function()
      -- look for something to shoot and shoot at it
    end)

  self.render = app.context.view.draw
    :subscribe(self:wrap(self.draw))
end

function totem:unbind()
  self.decay()
  self.target()
  self.render()
end

function totem:draw()
  local x, y = self.position.x, self.position.y
  local w = 20
  local h = 60
  g.setColor(40, 40, 60)
  g.rectangle('fill', x - w / 2, y - h, w, h)

  return -self.position.y + 10
end

return totem