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
  self.dropdown = self.gooey:add(lib.dropdown, 'test.dropdown')
  self.dropdown.geometry = offset(6, 8, 100, 20)
  self.dropdown.choices = {'muju'}
  self.dropdown.padding = 6
  self.dropdown.label = 'subject'
  self.dropdown.value = 'muju'

  self.subject = lib.rx.Subject.create()
  self.editors = self.subject
    :map(function(subject)
      local keys = table.keys(app[subject].props)
      for i = 1, #keys do
        local key = keys[i]
        local editor = self.gooey:add(lib.editor, 'prop.' .. key)
        editor.label = key
        editor.value = app[subject].props[key]
        editor.geometry = offset(8, 24 + 20 * i, self.props.width - 16)
        editor.valueSubject:subscribe(function(value)
          app[subject].props[key] = tonumber(value) or value
        end)
        keys[i] = editor
      end
      return keys
    end)

  love.keypressed
    :filter(f.eq(' '))
    :subscribe(function()
      local state = self.state
      state.active = not state.active
      self:setState(state)
    end)

  love.update
    :map(function()
      return self.state.active and 0 or -self.props.width
    end)
    :subscribe(function()
      local state = self.state
      state.x = math.lerp(state.x, state.active and 0 or -self.props.width, 16 * lib.tick.rate)
      self:setState(state)
    end)

  self.hand = love.mouse.getSystemCursor('hand')
  love.mousemoved
    :pack()
    :combine(self.editors, function(...) return ... end)
    :subscribe(function(mouse, editors)
      local mx, my = unpack(mouse)
      local contains = false
      contains = contains or self.dropdown:contains(mx, my)
      for i = 1, #editors do
        contains = contains or editors[i]:contains(mx, my)
      end
      if contains then
        love.mouse.setCursor(self.hand)
      else
        love.mouse.setCursor()
      end
    end)

  love.draw
    :with(self.editors)
    :subscribe(function(_, editors)
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
    end)

  self.subject:onNext('muju')
end

return inspector:new({
  active = false,
  editing = 'muju',
  x = -inspector.props.width
})
