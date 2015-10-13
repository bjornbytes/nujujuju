local inspector = lib.object.create()

inspector:include(lib.inspector)

inspector.config = {
  width = 140,
  objects = {'muju', 'buildings.shrine', 'buildings.dirt', 'totem', 'enemy'},
  initialObject = 'muju'
}

inspector.state = function()
  local state = {
    active = false,
    editing = 'muju',
    x = -inspector.config.width,
    hand = love.mouse.getSystemCursor('hand'),
    gooey = lib.gooey.controller:new()
  }

  state.dropdown = state.gooey:add(lib.gooey.dropdown, 'inspector.editing')

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
    :combine(self.components)
    :subscribe(self:wrap(self.updateCursor))

  app.context.view.hud
    :with(self.components)
    :subscribe(self:wrap(self.draw))

  self.dropdown.value:onNext(self.config.initialObject)
end

return inspector
