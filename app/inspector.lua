local inspector = lib.object.create()

function inspector:bind()
  self.gooey = lib.gooey.create():bind()
  self.button = self.gooey:add(lib.button, 'test.button')
  self.button.geometry = function() return 20, 20, 40, 20 end
  self.button.text = 'Button'

  self.checkbox = self.gooey:add(lib.checkbox, 'test.checkbox')
  self.checkbox.geometry = function() return 20 + 8, 50 + 8, 8 end
  self.checkbox.label = 'beast mode'

  self.dropdown = self.gooey:add(lib.dropdown, 'test.dropdown')
  self.dropdown.geometry = function() return 20, 76, 100, 20 end
  self.dropdown.choices = {'bruju', 'thuju', 'kuju', 'xuju'}
  self.dropdown.padding = 6
  self.dropdown.label = 'minion'
  self.dropdown.value = 'bruju'

  -- This should go somewhere else more 'global'?
  self.hand = love.mouse.getSystemCursor('hand')
  love.mousemoved:subscribe(function(mx, my)
    if self.button:contains(mx, my) or self.dropdown:contains(mx, my) or self.checkbox:contains(mx, my) then
      love.mouse.setCursor(self.hand)
    else
      love.mouse.setCursor()
    end
  end)

  love.draw:subscribe(function()
    g.setColor(0, 0, 0, 60)
    g.rectangle('fill', 0, 0, 140, 120)
    self.gooey:render(self.button)
    self.gooey:render(self.dropdown)
    self.gooey:render(self.checkbox)
  end)
end

return inspector:new({})
