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
  { 'buildings.dirt',
    position = {
      x = w / 2 - 200,
      y = h / 2 - 150
    }
  },
  { 'buildings.dirt',
    position = {
      x = w / 2 - 200,
      y = h / 2 + 150
    }
  },
  { 'buildings.shrine',
    position = {
      x = w / 2 + 100,
      y = h / 2
    }
  },
  { 'muju',
    key = 'muju',
    position = {
      x = w / 2,
      y = h / 2
    }
  }
}

return overgrowth
