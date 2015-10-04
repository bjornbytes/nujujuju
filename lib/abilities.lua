local abilities = {}

function abilities.create()
  local self = {
    list = {}
  }

  return setmetatable(self, {__index = abilities})
end

function abilities:add(ability, position)
  position = position or (#self.list + 1)
  ability = app.abilities[ability]:new({
    position = position,
    timer = 0
  })

  self.list[position] = ability
end

return abilities
