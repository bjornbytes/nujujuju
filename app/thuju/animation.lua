return {
  scale = .32,
  backwards = true,
  offset = {
    x = 0,
    y = 6
  },
  default = 'spawn',
  states = {

    spawn = {
      speed = .75,
      next = 'idle'
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
      loop = false,
      speed = 1,
      track = 1
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
