local dust = {}

dust.image = app.particles.images.smoke
dust.max = 32
dust.blendMode = 'additive'

dust.options = {}
dust.options.particleLifetime = {.5}
dust.options.colors = {{255, 200, 150, 5}, {255, 200, 150, 12}, {255, 200, 150, 0}}
dust.options.sizes = .6
dust.options.sizeVariation = .5
dust.options.areaSpread = {'normal', 4, 8}
dust.options.linearAcceleration = {0, -150, 0, -350}
dust.options.linearDamping = 10
dust.options.rotation = {0, 2 * math.pi}
dust.options.spin = {-10, 10}
dust.options.speed = {0, 300}
dust.options.spread = math.pi / 10

return dust
