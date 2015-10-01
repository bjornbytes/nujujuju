local scene = {}

scene.objects = {}

function scene.load(level)
  scene.level = level
  scene.objects = {}

  if level == 'overgrowth' then
    scene.objects.grid = app.grid
    scene.objects.dirt = app.dirt.object:new({
      x = app.grid.props.size * 2,
      y = app.grid.props.size * 6
    })

    scene.objects.shrine = app.shrine.object:new({
      x = app.grid.props.size * 6,
      y = app.grid.props.size * 2
    })

    scene.objects.muju = app.muju.object:new()
    scene.objects.particles = lib.particles.create():bind()
    scene.objects.inspector = app.inspector
  end
end

return scene
