local label = setmetatable({}, {__index = lib.gooey.component})

getmetatable(label).__call = function()
  return setmetatable({}, {__index = label})
end

function label:render()
  local x, y = self.geometry()

  g.setFont(self.gooey.font)
  g.white()
  g.print(self.label, x, y)
end

return label
