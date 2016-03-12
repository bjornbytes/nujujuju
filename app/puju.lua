local puju = lib.object.create()

function puju:bind()
  self:dispose({
    app.context.view.draw
      :subscribe(function()
        local image = app.art.shadow
        local offset = math.sin(lib.tick.index * lib.tick.rate * 3) * 4
        local scale = g.imageScale(image, 60 + offset)

        g.white(70)
        g.draw(image, self.position.x, self.position.y + 30, 0, scale, scale / 1.5, image:getWidth() / 2, image:getHeight() / 2)

        local image = app.art.puju
        local scale = g.imageScale(image, 35)

        g.white()
        g.draw(image, self.position.x, self.position.y + offset, 0, scale, scale, image:getWidth() / 2, image:getHeight())

        return -self.position.y
      end)
  })
end

return puju
