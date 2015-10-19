local inspector = {}

function inspector:createOffsetFunction(x, ...)
  local rest = {...}
  return function()
    return self.x + x, unpack(rest)
  end
end

function inspector:toggleActive()
  self.active = not self.active
  lib.flux.to(self, .3, {x = self.active and 0 or -self.config.width}):ease('quartout')
end

function inspector:smoothX()
  local targetX = self.active and 0 or -self.config.width
  --self.x = math.lerp(self.x, targetX, 16 * lib.tick.rate)
end

function inspector:updateCursor(mouse, components)
  local mx, my = unpack(mouse)
  local contains = false
  contains = contains or self.dropdown:contains(mx, my)
  for i = 1, #components do
    contains = contains or f.try(components[i].contains, components[i], mx, my)
  end
  love.mouse.setCursor(contains and lib.gooey.controller.cursors.hand or lib.gooey.controller.cursors.default)
end

function inspector:setupComponents(editing)
  local subject = table.get(app, editing)
  if subject.editor then
    local components = {}
    local y = 44

    for i = 1, #subject.editor.sections do
      local section = subject.editor.sections[i]
      local header = self.gooey:add(lib.gooey.label, 'prop.' .. section.title)
      header.geometry = self:createOffsetFunction(8, y)
      header.label = section.title
      table.insert(components, header)

      y = y + 20

      for j = 1, #section do
        local prop = section[j]
        local editor = self.gooey:add(lib.gooey.editor, 'config.' .. editing .. '.' .. prop, {value = subject.config[prop]})
        editor.label = prop:gsub('[A-Z]', function(x) return ' ' .. x:lower() end)
        editor.valueSubject:onNext(editor.value)
        editor.geometry = self:createOffsetFunction(8, y, self.config.width - 16)
        editor.valueSubject:subscribe(function(newValue)
          subject.config[prop] = tonumber(newValue) or newValue
        end)

        y = y + 20
        table.insert(components, editor)
      end

      y = y + 20
    end

    return components
  else
    local config = subject.config or subject
    return table.map(table.keys(config), function(prop, i)
      local editor = self.gooey:add(lib.gooey.editor, 'config.' .. editing .. '.' .. prop, {value = config[prop]})
      editor.label = prop:gsub('[A-Z]', function(x) return ' ' .. x:lower() end)
      editor.valueSubject:onNext(editor.value)
      editor.geometry = self:createOffsetFunction(8, 24 + 20 * i, self.config.width - 16)
      editor.valueSubject:subscribe(function(newValue)
        subject.config[prop] = tonumber(newValue) or newValue
      end)
      return editor
    end)
  end
end

function inspector:draw(_, editors)
  local u, v = g.getDimensions()
  local x = self.x
  local width = self.config.width
  if x > 0 then
    width = width + x
    x = 0
  end

  g.setColor(35, 35, 35, 220)
  g.rectangle('fill', x, 0, width, v)

  if editors then
    g.setColor(255, 255, 255)
    for i = 1, #editors do
      self.gooey:render(editors[i])
    end
  end

  self.gooey:render(self.dropdown)

  return -10000
end

return inspector
