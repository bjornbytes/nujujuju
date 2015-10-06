local scene = {}

scene.objects = {}

function scene.load(level)
  scene.width = 800
  scene.height = 600

  scene.level = level
  scene.objects = {}

  scene.view = lib.view:new()
  scene.grid = app.grid

  if level == 'overgrowth' then
    scene.objects.dirtPatch = app.patch.object:new({
      texture = app.environment.dirt,
      x = scene.width / 2,
      y = scene.height / 2,
      angle = 0
    })

    scene.objects.dirt = app.dirt.object:new({
      position = {
        x = scene.width / 2 - 100,
        y = scene.height / 2
      }
    })

    scene.objects.shrine = app.shrine.object:new({
      position = {
        x = scene.width / 2 + 100,
        y = scene.height / 2
      }
    })

    scene.objects.muju = app.muju.object:new()
  end

  scene.particles = lib.particles.create():bind()
  scene.inspector = app.inspector
  scene.hud = app.hud:new():bind()
end

return scene
