local thujustep = {}

thujustep.image = app.particles.images.smoke
thujustep.max = 32
thujustep.blendMode = 'additive'

thujustep.options = {}
thujustep.options.particleLifetime = {.75}
thujustep.options.colors = {{255, 200, 150, 5}, {255, 200, 150, 12}, {255, 200, 150, 0}}
thujustep.options.sizes = .65
thujustep.options.sizeVariation = .5
thujustep.options.areaSpread = {'normal', 4, 8}
thujustep.options.linearAcceleration = {0, -150, 0, -350}
thujustep.options.linearDamping = 10
thujustep.options.rotation = {0, 2 * math.pi}
thujustep.options.spin = {-10, 10}
thujustep.options.speed = {100, 500}
thujustep.options.spread = math.pi / 10

return thujustep
