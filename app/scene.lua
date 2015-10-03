local scene = {}

scene.objects = {}

function scene.load(level)
  scene.level = level
  scene.objects = {}

  scene.grid = app.grid

  if level == 'overgrowth' then
    scene.objects.dirt = app.dirt.object:new({
      x = app.grid.props.size * 2,
      y = app.grid.props.size * 6
    })

    scene.objects.shrine = app.shrine.object:new({
      x = app.grid.props.size * 6,
      y = app.grid.props.size * 2
    })

    scene.objects.rock1 = app.obstacle.object:new({
      image = app.environment.rock1,
      size = 60,
      x = 200,
      y = 200
    })

    scene.objects.rock2 = app.obstacle.object:new({
      image = app.environment.rock2,
      size = 60,
      x = 700,
      y = 500
    })

    scene.objects.rock3 = app.obstacle.object:new({
      image = app.environment.rock3,
      size = 60,
      x = 500,
      y = 400
    })

    scene.objects.rock4 = app.obstacle.object:new({
      image = app.environment.rock4,
      size = 60,
      x = 300,
      y = 450
    })

    scene.objects.bush = app.obstacle.object:new({
      image = app.environment.bush,
      size = 60,
      x = 600,
      y = 150
    })

    scene.objects.muju = app.muju.object:new()
  end

  scene.particles = lib.particles.create():bind()
  scene.inspector = app.inspector
end

return scene
