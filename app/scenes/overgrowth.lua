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
      x = app.grid.config.size.x * 2.5,
      y = app.grid.config.size.y * 3.5
    }
  }
}

overgrowth.events = {}

return overgrowth
