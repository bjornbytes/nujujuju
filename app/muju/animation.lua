return {
  scale = .6,
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
      after = 'idle'
    },

    attack = {
      loop = false,
      speed = 1,
      track = 1
    },

    summon = {
      speed = 1.85,
      after = 'idle'
    },

    death = {
      length = 1
    },

    resurrect = {
      speed = .9
    }
  }
}
