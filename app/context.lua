local context = {}

function context.load(scene)
  context.scene = app.scenes[scene]

  context.view = lib.view:new()
  context.particles = lib.particles:new()
  context.hud = app.hud:new()
  context.inspector = app.inspector:new()

  context.objects = {}

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
end

return context