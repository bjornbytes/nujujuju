local burst = lib.object.create()

function burst:init()
  self.alpha = 1

  lib.flux.to(self, .5, { alpha = 0 })
    :ease('cubicout')
    :oncomplete(function()
      self:unbind()
      app.context:removeObject(self)
    end)
end

function burst:bind()
  return {
    app.context.view.draw
      :subscribe(function()
        g.setColor(160, 255, 140, self.alpha * 255)
        g.ellipse('fill', self.position.x, self.position.y, self.radius, self.radius / 2)
        return -self.position.y
      end)
  }
end

return burst
