return {
  image = app.particles.images.smoke,
  max = 32,
  blendMode = 'additive',

  options = {
    particleLifetime = {.5},
    colors = {{255, 200, 150, 5}, {255, 200, 150, 12}, {255, 200, 150, 0}},
    sizes = .6,
    sizeVariation = .5,
    areaSpread = {'normal', 4, 8},
    linearAcceleration = {0, -150, 0, -350},
    linearDamping = 10,
    rotation = {0, 2 * math.pi},
    spin = {-10, 10},
    speed = {0, 300},
    spread = math.pi / 10
  }
}
