local context = {}

function context.load(scene)
  context.scene = app.scenes[scene]

  context.view = lib.view:new()
  context.particles = lib.particles:new()
  context.hud = app.hud:new()
  context.inspector = app.inspector:new()
  context.collision = lib.collision:new()
  context.timeline = app.timeline.object:new()
  context.timelineUI = app.timeline.ui:new()

  context.objects = {}

  for _, entry in ipairs(context.scene.objects) do
    local path = entry[1]
    entry[1] = nil

    local object = table.get(app, path .. '.object') or table.get(app, path)
    local instance = object:new(entry)

    context.objects[instance] = instance

    if entry.key then
      instance._key = entry.key
      context.objects[entry.key] = instance
    end
  end

  --context.positioner = app.positioner:new({object = context.objects.muju})
end

function context:removeObject(object)
  self.objects[object] = nil
  if object._key then
    self.objects[object._key] = nil
  end
end

return context
