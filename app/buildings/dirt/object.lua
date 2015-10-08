local dirt = lib.object.create()

dirt:include(lib.obstacle)

dirt.config = app.buildings.dirt.config
dirt.image = app.buildings.dirt.image

function dirt:bind()
  self:setStartPosition()
  self:setSolid()

  love.update
    :subscribe(self:wrap(self.revertToStartPosition))

  app.context.view.draw
    :subscribe(self:wrap(self.draw))

  return self
end

return dirt
