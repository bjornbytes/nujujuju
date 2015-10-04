return {
  scale = .32,
  offset = {
    x = 0,
    y = 0
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

    taunt = {
      speed = 1
    },

    tremor = {
      speed = 1
    },

    death = {
      speed = .8
    }
  }
}
