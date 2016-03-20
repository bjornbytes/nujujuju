return {
  scale = .55,
  offset = {
    x = 0,
    y = 0
  },
  default = 'spawn',
  states = {

    spawn = {
      speed = 2
    },

    idle = {
      loop = true,
      speed = .3
    },

    walk = {
      loop = true,
      speed = .73
    },

    attack = {
      loop = true,
      speed = .45
    },

    death = {
      speed = .8
    }
  }
}
