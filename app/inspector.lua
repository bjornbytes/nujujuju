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
  self.dropdown.choices = {'muju', 'shrine', 'dirt'}
  self.dropdown.padding = 6
  self.dropdown.label = 'subject'
  self.components = self.dropdown.value:map(self.setupComponents(self))

  love.keypressed
    :filter(f.eq('`'))
    :subscribe(self.toggleActive(self))

  self:lerp('x', 16, self.getTargetX)

  love.mousemoved
    :pack()
    :combine(self.components)
    :subscribe(self.updateCursor(self))

  app.scene.view.hud
    :with(self.components)
    :subscribe(self.render(self))

  self.dropdown.value:onNext('muju')
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
  return function(mouse, components)
    local mx, my = unpack(mouse)
    local contains = false
    contains = contains or self.dropdown:contains(mx, my)
    for i = 1, #components do
      contains = contains or f.try(components[i].contains, components[i], mx, my)
    end
    love.mouse.setCursor(contains and hand or nil)
  end
end

function inspector:setupComponents()
  return function(editing)
    local subject = table.get(app, editing)
    if subject.editor then
      local components = {}
      local y = 44

      for i = 1, #subject.editor.sections do
        local section = subject.editor.sections[i]
        local header = self.gooey:add(lib.label, 'prop.' .. section.title)
        header.geometry = offset(8, y)
        header.label = section.title
        table.insert(components, header)

        y = y + 20

        for j = 1, #section do
          local prop = section[j]
          local editor = self.gooey:add(lib.editor, 'prop.' .. prop)
          editor.label = prop:gsub('[A-Z]', function(x) return ' ' .. x:lower() end)
          editor.value = subject.props[prop]
          editor.valueSubject:onNext(editor.value)
          editor.geometry = offset(8, y, self.props.width - 16)
          editor.valueSubject:subscribe(function(newValue)
            subject.props[prop] = tonumber(newValue) or newValue
          end)

          y = y + 20
          table.insert(components, editor)
        end

        y = y + 20
      end

      return components
    else
      local props = subject.props or subject
      return table.map(table.keys(props), function(prop, i)
        local editor = self.gooey:add(lib.editor, 'prop.' .. prop)
        editor.label = prop:gsub('[A-Z]', function(x) return ' ' .. x:lower() end)
        editor.value = props[prop]
        editor.valueSubject:onNext(editor.value)
        editor.geometry = offset(8, 24 + 20 * i, self.props.width - 16)
        editor.valueSubject:subscribe(function(newValue)
          subject.props[prop] = tonumber(newValue) or newValue
        end)
        return editor
      end)
    end
  end
end

function inspector:render()
  return function(_, editors)
    local props, state = self.props, self.state
    local height = love.graphics.getHeight()

    g.setColor(35, 35, 35, 220)
    g.rectangle('fill', state.x, 0, props.width, height)

    if editors then
      g.setColor(255, 255, 255)
      for i = 1, #editors do
        self.gooey:render(editors[i])
      end
    end

    self.gooey:render(self.dropdown)

    return -10000
  end
end

return inspector:new({
  active = false,
  editing = 'muju',
  x = -inspector.props.width
})
