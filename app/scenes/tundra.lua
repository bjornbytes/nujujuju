local tundra = {}

tundra.name = 'The Wild North'
tundra.width = 800
tundra.height = 600

local w, h = tundra.width, tundra.height

tundra.objects = {
  { 'environment' },
  { 'muju',
    key = 'muju',
    position = {
      x = w / 2,
      y = h / 2
    }
  },
  { 'hud.game', key = 'hud' },
  { 'abilities', key = 'abilities' }
}

tundra.events = {
  {
    kind = 'spuju',
    time = 5,
    count = 1
  },
  {
    kind = 'spuju',
    time = 25,
    count = 2
  }
}

return tundra
