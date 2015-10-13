local context = {}

function context.load(scene)
  context.scene = app.scenes[scene]

  context.view = lib.view:new()
  context.particles = lib.particles:new()
  context.hud = app.hud:new()
  context.inspector = app.inspector:new()
  context.timeline = app.timeline:new()

  context.objects = {}

  context.objects.enemy = app.enemy.object:new({
    position = {
      x = 500,
      y = 500
    }
  })

  for _, entry in ipairs(context.scene.objects) do
    local path = entry[1]
    entry[1] = nil

    local object = table.get(app, path .. '.object') or table.get(app, path)
    local instance = object:new(entry)

    if entry.key then
      context.objects[entry.key] = instance
    else
      table.insert(context.objects, instance)
    end
  end

  context.positioner = app.positioner:new({object = context.objects.muju})
end

return context
