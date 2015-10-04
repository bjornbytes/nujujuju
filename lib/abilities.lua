local abilities = {}

function abilities.create()
  local self = {
    list = {}
  }

  return setmetatable(self, {__index = abilities})
end

function abilities:add(ability, position)
  ability = app.abilities[ability]:new()
  ability:bind()
  self.list[position or (#self.list + 1)] = ability
end

return abilities
