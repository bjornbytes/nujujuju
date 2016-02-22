local context = {}

function context.load(scene)
  context.scene = app.scenes[scene]

  context.view = lib.view:new()
  context.particles = lib.particles:new()
  context.hud = app.hud:new()
  context.inspector = app.inspector:new()
  context.collision = lib.collision:new()

  context.objects = {}

  for _, entry in ipairs(context.scene.objects) do
    local path = entry[1]

    local object = util.get(app, path .. '.object') or util.get(app, path)
    local instance = object:new(util.copy(entry))

    context.objects[instance] = instance

    if entry.key then
      instance._key = entry.key
      context.objects[entry.key] = instance
    end
  end
end

function context.unload()
  for object in pairs(context.objects) do
    f.try(object.unbind, object)
  end

  context.objects = nil

  context.view:unbind()
  context.particles:unbind()
  context.hud:unbind()
  context.inspector:unbind()
  context.collision:unbind()
end

function context:removeObject(object)
  self.objects[object] = nil
  if object._key then
    self.objects[object._key] = nil
  end
end

return context
