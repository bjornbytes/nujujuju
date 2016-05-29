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
      loop = false,
      length = 2.5,
      after = 'idle'
    },

    fear = {
      speed = 1,
      after = 'idle'
    },

    hurt = {
      speed = .8
    },

    death = {
      speed = .5
    }
  }
}
