return {
  scale = .525,
  offset = {
    x = 0,
    y = 0
  },
  default = 'spawn',
  states = {

    spawn = {
      speed = .85
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
      speed = .75
    },

    death = {
      speed = .8
    }
  }
}
