local shrine = lib.object.create()

shrine:include(lib.obstacle)

shrine.config = app.buildings.shrine.config
shrine.image = app.buildings.shrine.image

function shrine:bind()
  self:setStartPosition()
  self:setSolid()

  love.update
    :subscribe(self:wrap(self.revertToStartPosition))

  app.context.view.draw
    :subscribe(self:wrap(self.draw))

  return self
end

return shrine
