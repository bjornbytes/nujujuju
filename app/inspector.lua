local inspector = lib.object.create()

inspector:include(lib.inspector)

inspector.config = {
  width = 160,
  objects = {'muju', 'enemy'},
  initialObject = 'muju'
}

inspector.state = function()
  local state = {
    active = false,
    editing = 'muju',
    x = -inspector.config.width,
    gooey = lib.gooey.controller:new()
  }

  state.dropdown = state.gooey:add(lib.gooey.dropdown, 'inspector.editing', {
    value = inspector.config.initialObject
  })

  return state
end

function inspector:bind()
  self.dropdown.geometry = self:createOffsetFunction(6, 8, self.config.width - 16, 20)
  self.dropdown.choices = self.config.objects
  self.dropdown.padding = 6
  self.dropdown.label = 'subject'
  self.components = self.dropdown.value:map(self:wrap(self.setupComponents))

  love.keypressed
    :filter(f.eq('`'))
    :subscribe(self:wrap(self.toggleActive))

  love.update
    :subscribe(self:wrap(self.smoothX))

  love.mousemoved
    :pack()
    :combineLatest(self.components)
    :subscribe(self:wrap(self.updateCursor))

  app.context.view.hud
    :with(self.components)
    :subscribe(self:wrap(self.draw))
end

return inspector
