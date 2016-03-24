return {
  scale = .7,
  offset = {
    x = 0,
    y = -8
  },
  default = 'spawn',
  states = {

    spawn = {
      speed = 1
    },

    idle = {
      loop = true,
      speed = .21
    },

    walk = {
      loop = true,
      speed = .7
    },

    attack = {
      loop = true,
      length = 2.5
    },

    fear = {
      speed = 1
    },

    hurt = {
      speed = .8
    },

    death = {
      length = 1
    }
  }
}
