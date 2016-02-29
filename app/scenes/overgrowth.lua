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
  },
  { 'enemies.spuju',
    position = {
      x = 200,
      y = 300
    }
  }
}

overgrowth.events = {}

return overgrowth
