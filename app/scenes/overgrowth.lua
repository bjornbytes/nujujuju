local overgrowth = {}

overgrowth.width = 800
overgrowth.height = 600

local w, h = overgrowth.width, overgrowth.height

overgrowth.objects = {
  { 'environment' },
  { 'environment.patch',
    x = w / 2,
    y = h / 2,
    angle = 0,
    texture = app.environment.textures.dirt
  },
  { 'muju',
    key = 'muju',
    position = {
      x = w / 2,
      y = h / 2
    }
  },
  { 'buildings.dirt',
    position = {
      x = 200,
      y = 200
    }
  }
}

overgrowth.events = {}

return overgrowth
