return {
  scale = .65,
  offset = {
    x = 0,
    y = 0
  },
  default = 'idle',
  states = {

    idle = {
      priority = 1,
      loop = true,
      speed = .4,
      mix = {
        walk = .2,
        summon = .1,
        death = .2
      }
    },

    walk = {
      priority = 1,
      loop = true,
      speed = 1.2,
      mix = {
        idle = .1,
        summon = .1,
        death = .2
      }
    },

    summon = {
      priority = 2,
      blocking = true,
      speed = 1.85,
      mix = {
        walk = .2,
        idle = .2
      }
    },

    death = {
      priority = 3,
      blocking = true,
      speed = .7
    },

    resurrect = {
      priority = 3,
      blocking = true,
      speed = .9
    }
  }
}
