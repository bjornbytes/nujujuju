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
  self.button = self.gooey:add(lib.button, 'test.button')
  self.button.geometry = offset(20, 20, 40, 20)
  self.button.text = 'Button'

  self.checkbox = self.gooey:add(lib.checkbox, 'test.checkbox')
  self.checkbox.geometry = offset(20 + 8, 50 + 8, 8)
  self.checkbox.label = 'beast mode'
  self.checkbox.padding = 8

  self.dropdown = self.gooey:add(lib.dropdown, 'test.dropdown')
  self.dropdown.geometry = offset(20, 76, 100, 20)
  self.dropdown.choices = {'bruju', 'thuju', 'kuju', 'xuju'}
  self.dropdown.padding = 6
  self.dropdown.label = 'minion'
  self.dropdown.value = 'bruju'

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
  love.mousemoved:subscribe(function(mx, my)
    if self.button:contains(mx, my) or self.dropdown:contains(mx, my) or self.checkbox:contains(mx, my) then
      love.mouse.setCursor(self.hand)
    else
      love.mouse.setCursor()
    end
  end)

  love.draw:subscribe(function()
    local props, state = self.props, self.state
    g.setColor(0, 0, 0, 60)
    g.rectangle('fill', state.x, 0, props.width, 120)
    self.gooey:render(self.button)
    self.gooey:render(self.dropdown)
    self.gooey:render(self.checkbox)
  end)
end

return inspector:new({
  active = false,
  x = -inspector.props.width
})
