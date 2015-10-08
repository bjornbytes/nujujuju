local abilities = lib.object.create()

abilities.state = {
  list = {}
}

function abilities:add(ability, position)
  position = position or (#self.list + 1)
  ability = app.abilities[ability]:new({
    position = position,
    timer = 0
  })

  self.list[position] = ability
end

return abilities
