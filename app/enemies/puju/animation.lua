return {
  scale = .22,
  flipped = true,
  offset = {
    x = 0,
    y = -16
  },
  default = 'leafocopter',
  states = {

    mouthsuck = {
      speed = 1,
      after = 'mouthloop'
    },

    mouthloop = {
      loop = true,
      speed = 1
    },

    mouthblow = {
      speed = .75
    },

    leafocopter = {
      loop = true,
      speed = 2,
      track = 1
    }
  }
}
