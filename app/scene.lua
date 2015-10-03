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

    scene.objects.muju = app.muju.object:new()
  end

  scene.particles = lib.particles.create():bind()
  scene.inspector = app.inspector
end

return scene
