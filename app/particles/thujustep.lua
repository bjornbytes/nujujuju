return {
  image = app.particles.images.smoke,
  max = 32,
  blendMode = 'add',

  options = {
    particleLifetime = {.75},
    colors = {{255, 200, 150, 5}, {255, 200, 150, 12}, {255, 200, 150, 0}},
    sizes = .65,
    sizeVariation = .5,
    areaSpread = {'normal', 4, 8},
    linearAcceleration = {0, -150, 0, -350},
    linearDamping = 10,
    rotation = {0, 2 * math.pi},
    spin = {-10, 10},
    speed = {100, 500},
    spread = math.pi / 10
  }
}
