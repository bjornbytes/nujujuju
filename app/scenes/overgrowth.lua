local overgrowth = {}

overgrowth.name = 'The Overgrowth'
overgrowth.width = 960
overgrowth.height = 720

local w, h = overgrowth.width, overgrowth.height

overgrowth.objects = {
  { 'environment' },
  { 'muju',
    key = 'muju',
    position = {
      x = w * .5,
      y = h * .25
    }
  },
  { 'abilities.manager', key = 'abilities' },
  { 'hud.game', key = 'hud' },
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
            kind = 'puju',
            count = 2
          }
        }
      },
      [3] = {
        events = {
          [1] = {
            kind = 'spuju',
            count = 1,
            time = 0
          }
        }
      },
      [4] = {
        events = {
          [1] = {
            kind = 'puju',
            count = 2,
            time = 0
          }
        }
      },
      [5] = {
        events = {
          [1] = {
            kind = 'spuju',
            count = 2,
            time = 0
          }
        }
      },
      [6] = {
        events = {
          [1] = {
            kind = 'puju',
            count = 5,
            time = 0
          }
        }
      },
      [7] = {
        events = {
          [1] = {
            kind = 'spuju',
            count = 2,
            time = 0
          }
        }
      },
      [8] = {
        events = {
          [1] = {
            kind = 'spuju',
            count = 4,
            time = 0
          }
        }
      }
    }
  },
  { 'shruju',
    position = {
      x = w * .5,
      y = h * .25 + 67
    }
  },
  { 'shruju',
    position = {
      x = w * .5 - 100,
      y = h * .25
    }
  },
  { 'shruju',
    position = {
      x = w * .5 + 100,
      y = h * .25
    }
  }
}

return overgrowth
