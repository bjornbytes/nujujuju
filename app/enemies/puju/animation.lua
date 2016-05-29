return {
  scale = .22,
  speedHack = true,
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
      speed = 2,
      after = 'walk'
    },

    leafocopter = {
      loop = true,
      speed = 2,
      track = 1
    },

    walk = {
      loop = true,
      speed = .4
    }
  }
}
