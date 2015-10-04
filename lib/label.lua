local label = setmetatable({}, {__index = lib.component})

getmetatable(label).__call = function()
  return setmetatable({}, {__index = label})
end

function label:render()
  local x, y = self.geometry()

  g.setFont(self.gooey.font)
  g.setColor(255, 255, 255)
  g.print(self.label, x, y)
end

return label
