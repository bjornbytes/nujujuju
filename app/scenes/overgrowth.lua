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
  { 'hud.game', key = 'hud' },
  { 'input', key = 'input' }
}

overgrowth.events = {
  {
    kind = 'puju',
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
    count = 2
  },
  {
    kind = 'puju',
    time = 55,
    count = 3
  }
}

return overgrowth
