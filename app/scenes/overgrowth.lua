local overgrowth = {}

overgrowth.width = 800
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
  }
}

overgrowth.events = {
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

return overgrowth
