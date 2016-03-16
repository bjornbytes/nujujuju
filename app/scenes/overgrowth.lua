local overgrowth = {}

overgrowth.name = 'The Overgrowth'
overgrowth.width = 960
overgrowth.height = 540

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
  { 'input', key = 'input' },
  { 'waves',
    key = 'waves',
    waves = {
      [1] = {
        events = {
          [1] = {
            kind = 'puju',
            count = 1,
            time = 0
          }
        }
      },
      [2] = {
        events = {
          [1] = {
            kind = 'spuju',
            count = 1
          }
        }
      },
      [3] = {
        events = {
          [1] = {
            kind = 'puju',
            count = 1,
            time = 0
          },
          [2] = {
            kind = 'puju',
            count = 1,
            time = 1
          },
          [3] = {
            kind = 'puju',
            count = 1,
            time = 2
          }
        }
      }
    }
  }
}

return overgrowth
