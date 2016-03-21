return {
  scale = .3,
  flipped = true,
  offset = {
    x = 0,
    y = 0
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
      speed = 1
    },

    leafocopter = {
      loop = true,
      speed = .1,
      track = 1
    }
  }
}
