return {
  scale = .75,
  offset = {
    x = 0,
    y = -8
  },
  default = 'spawn',
  states = {

    spawn = {
      speed = .75
    },

    idle = {
      loop = true,
      speed = .21
    },

    walk = {
      loop = true,
      speed = 1.5
    },

    attack = {
      loop = true,
      speed = 1
    },

    fear = {
      speed = 1
    },

    death = {
      speed = .8
    }
  }
}
