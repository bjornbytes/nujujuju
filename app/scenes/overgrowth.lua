local overgrowth = {}

overgrowth.name = 'The Overgrowth'
overgrowth.width = 960
overgrowth.height = 600

local w, h = overgrowth.width, overgrowth.height

overgrowth.objects = {
  { 'environment' },
  { 'muju',
    key = 'muju',
    position = {
      x = w / 2,
      y = h / 2
    }
  },
  { 'juju', position = { x = w / 2, y = h * .75 }},
  { 'puju', position = { x = w * .75, y = h / 2 }},
  { 'hud.game', key = 'hud' },
  { 'input', key = 'input' }
}

--[[overgrowth.events = {
  {
    kind = 'spuju',
    time = 5,
    count = 1
  },
  {
    kind = 'spuju',
    time = 25,
    count = 1
  },
  {
    kind = 'spuju',
    time = 40,
    count = 1
  },
  {
    kind = 'spuju',
    time = 55,
    count = 1
  }
}]]

return overgrowth
