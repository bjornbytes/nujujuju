local hollow = {}

hollow.name = 'The Hollow'
hollow.width = 800
hollow.height = 600

local w, h = hollow.width, hollow.height

hollow.objects = {
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

hollow.events = {
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

return hollow
