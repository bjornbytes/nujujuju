local inspector = lib.object.create():include(lib.inspector)

inspector.config = {
  width = 160,
  objects = {'muju', 'enemy'},
  initialObject = 'muju'
}

function inspector:init()
  self.active = false
  self.editing = 'muju'
  self.x = -inspector.config.width
  self.gooey = lib.gooey.controller:new()
  self.dropdown = self.gooey:add(lib.gooey.dropdown, 'inspector.editing', {
    value = inspector.config.initialObject
  })
end

function inspector:bind()
  self.dropdown.geometry = self:createOffsetFunction(6, 8, self.config.width - 16, 20)
  self.dropdown.choices = self.config.objects
  self.dropdown.padding = 6
  self.dropdown.label = 'subject'
  self.components = self.dropdown.value:map(self:wrap(self.setupComponents))

  return {
    love.keypressed
      :filter(f.eq('`'))
      :subscribe(self:wrap(self.toggleActive)),

    love.update
      :subscribe(self:wrap(self.smoothX)),

    love.mousemoved
      :pack()
      :combineLatest(self.components)
      :subscribe(self:wrap(self.updateCursor)),

    app.context.view.hud
      :with(self.components)
      :subscribe(self:wrap(self.draw))
  }
end

return inspector
