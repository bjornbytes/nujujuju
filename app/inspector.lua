local inspector = lib.object.create()

inspector.props = {
  width = 140
}

function inspector:bind()
  function offset(x, ...)
    local rest = {...}
    return function()
      return self.state.x + x, unpack(rest)
    end
  end

  self.gooey = lib.gooey.create():bind()
  self.dropdown = self.gooey:add(lib.dropdown, 'inspector.editing')
  self.dropdown.geometry = offset(6, 8, 100, 20)
  self.dropdown.choices = {'muju'}
  self.dropdown.padding = 6
  self.dropdown.label = 'subject'
  self.dropdown.value = 'muju'

  self.editing = lib.rx.Subject.create()
  self.editors = self.editing:map(self.setupEditors(self))

  love.keypressed
    :filter(f.eq(' '))
    :subscribe(self.toggleActive(self))

  self:lerp('x', 16, self.getTargetX)

  love.mousemoved
    :pack()
    :combine(self.editors)
    :subscribe(self.updateCursor(self))

  love.draw
    :with(self.editors)
    :subscribe(self.render(self))

  self.editing:onNext('muju')
end

function inspector:getTargetX()
  return self.state.active and 0 or -self.props.width
end

function inspector:toggleActive()
  return function()
    self:updateState(function(state)
      state.active = not state.active
    end)
  end
end

function inspector:updateCursor()
  local hand = love.mouse.getSystemCursor('hand')
  return function(mouse, editors)
    local mx, my = unpack(mouse)
    local contains = false
    contains = contains or self.dropdown:contains(mx, my)
    for i = 1, #editors do
      contains = contains or editors[i]:contains(mx, my)
    end
    love.mouse.setCursor(contains and hand or nil)
  end
end

function inspector:setupEditors()
  return function(editing)
    return table.map(table.keys(app[editing].props), function(prop, i)
      local editor = self.gooey:add(lib.editor, 'prop.' .. prop)
      editor.label = prop
      editor.value = app[editing].props[prop]
      editor.geometry = offset(8, 24 + 20 * i, self.props.width - 16)
      editor.valueSubject:subscribe(function(newValue)
        app[editing].props[prop] = tonumber(newValue) or newValue
      end)
      return editor
    end)
  end
end

function inspector:render()
  return function(_, editors)
    local props, state = self.props, self.state
    local height = love.graphics.getHeight()
    g.setColor(0, 0, 0, 60)
    g.rectangle('fill', state.x, 0, props.width, height)
    self.gooey:render(self.dropdown)

    if editors then
      g.setColor(255, 255, 255)
      for i = 1, #editors do
        self.gooey:render(editors[i])
      end
    end
  end
end

return inspector:new({
  active = false,
  editing = 'muju',
  x = -inspector.props.width
})
