local gooey = {}

gooey.font = fonts['04B_03'](8)

function gooey.create()
  local self = {
    components = {},
    focused = nil
  }
  return setmetatable(self, {__index = gooey})
end

function gooey:bind()
  love.update:subscribe(function()
    self:call('update')
  end)

  love.keypressed:subscribe(function(key)
    self:call('keypressed', key)
  end)

  love.keyreleased:subscribe(function(key)
    self:call('keyreleased', key)
  end)

  love.mousepressed:subscribe(function(mx, my, b)
    self.hot = nil
    self:call('mousepressed', mx, my, b)
  end)

  love.mousereleased:subscribe(function(mx, my, b)
    self:call('mousereleased', mx, my, b)
    self.hot = nil
  end)

  love.resize:subscribe(function()
    self:call('resize')
  end)

  return self
end

function gooey:render(component)
  if type(component) == 'string' then component = self:get(component) end
  if not component then return end
  component.lastDraw = tick
  component:render()
end

function gooey:get(code)
  return self.components[code]
end

function gooey:call(method, ...)
  if self.focused then
    if self.focused[method] then
      if self.focused[method](self.focused, ...) then return end
    end
  end

  --local components = table.filter(self.components, function(c) return c.lastDraw and tick - c.lastDraw <= 1 and c ~= self.focused end)
  for code, component in pairs(self.components) do
    f.try(component[method], component, ...)
  end
end

function gooey:add(class, code, vars)
  local component = class()
  --table.merge(vars, component, true)
  component.code = code
  component.gooey = self
  f.try(component.activate, component)
  self.components[code] = component
  return component
end

function gooey:focus(component)
  self.focused = component
end

function gooey:unfocus()
  self.focused = nil
end

return gooey
