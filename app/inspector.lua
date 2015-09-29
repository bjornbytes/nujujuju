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
    if self.dropdown:contains(mx, my) then
      love.mouse.setCursor(self.hand)
    else
      love.mouse.setCursor()
    end
  end)

  love.draw:subscribe(function()
    local props, state = self.props, self.state
    local height = love.graphics.getHeight()
    g.setColor(0, 0, 0, 60)
    g.rectangle('fill', state.x, 0, props.width, height)
    self.gooey:render(self.dropdown)

    local keys = {}
    local subject = app[state.editing].props
    for k in pairs(subject) do
      table.insert(keys, k)
    end
    g.setColor(255, 255, 255)
    g.print(table.concat(keys, '\n'), state.x + 8, 32)
  end)
end

return inspector:new({
  active = false,
  editing = 'muju',
  x = -inspector.props.width
})
