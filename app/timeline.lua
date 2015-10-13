local timeline = lib.object.create()

timeline:include(lib.timeline)

timeline.config = {
  height = 120
}

timeline.state = function()
  return {
    active = false,
    y = -timeline.config.height,
    hand = love.mouse.getSystemCursor('hand')
  }
end

function timeline:bind()
  love.keypressed
    :filter(f.eq('t'))
    :subscribe(self:wrap(self.toggleActive))

  love.update
    :subscribe(self:wrap(self.smoothY))

  app.context.view.hud
    :subscribe(self:wrap(self.draw))
end

return timeline
