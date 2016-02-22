return {
  scale = .5,
  offset = {
    x = 0,
    y = 10
  },
  default = 'idle',
  states = {

    idle = {
      loop = true,
      speed = .4
    },

    walk = {
      loop = true,
      length = .6
    },

    stop = {
      speed = .75,
      next = 'idle'
    },

    attack = {
      loop = false,
      speed = 1,
      track = 1
    },

    summon = {
      speed = 1.85
    },

    death = {
      length = 1
    },

    resurrect = {
      speed = .9
    }
  }
}
