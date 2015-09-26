return {
  scale = .55,
  offset = {
    x = 0,
    y = 0
  },
  default = 'idle',
  states = {

    idle = {
      loop = true,
      speed = .4
    },

    walk = {
      loop = true,
      speed = 1.4
    },

    summon = {
      speed = 1.85
    },

    death = {
      speed = .7
    },

    resurrect = {
      speed = .9
    }
  }
}
