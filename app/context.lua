local context = {}

function context.load(scene, config)
  lib.tick.index = 1

  context.scene = app.scenes[scene]

  context.view = lib.view:new(nil, config)
  context.particles = lib.particles:new(nil, config)
  context.collision = lib.collision:new(nil, config)

  context.view.xmax = context.scene.width
  context.view.ymax = context.scene.height

  context.objects = {}

  for _, entry in ipairs(context.scene.objects) do

    local path = entry[1]

    local object = util.get(app, path .. '.object') or util.get(app, path)
    local instance = object:new(util.copy(entry), config)

    context.objects[instance] = instance

    if entry.key then
      instance._key = entry.key
      context.objects[entry.key] = instance

      context[entry.key] = instance
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
  context.collision:unbind()
end

function context:addObject(class, props)
  local object = class:new(props)
  self.objects[object] = object
  return object
end

function context:removeObject(object)
  self.objects[object] = nil
  self.collision:remove(object)
  if object._key then
    self.objects[object._key] = nil
  end
end

function context:getObject(object)
  return self.objects[object]
end

return context
