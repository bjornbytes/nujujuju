local context = {}

function context.load(scene)
  lib.tick.index = 1

  context.scene = app.scenes[scene]

  context.view = lib.view:new()
  context.particles = lib.particles:new()
  context.inspector = app.inspector:new()
  context.collision = lib.collision:new()

  context.view.xmax = context.scene.width
  context.view.ymax = context.scene.height

  context.objects = {}

  for _, entry in ipairs(context.scene.objects) do
    local path = entry[1]

    local object = util.get(app, path .. '.object') or util.get(app, path)
    local instance = object:new(util.copy(entry))

    context.objects[instance] = instance

    if entry.key then
      instance._key = entry.key
      context.objects[entry.key] = instance

      if not context[entry.key] then
        context[entry.key] = instance
      end
    end
  end

  context.events = util.copy(context.scene.events) or {}
  context.timeline = love.update
    :subscribe(function()
      if context.events[1] and lib.tick.index * lib.tick.rate >= context.events[1].time then
        local event = table.remove(context.events, 1)

        context.lastEvent = event

        for i = 1, event.count do
          local x = love.math.random() > .5 and context.scene.width - 50 or 50
          local y = 100 + love.math.random() * (context.scene.height - 200)

          local spuju = app.enemies[event.kind].object:new({
            position = {
              x = x,
              y = y
            }
          })

          context.objects[spuju] = spuju
        end
      end
    end)
end

function context.unload()
  context.timeline:unsubscribe()

  for object in pairs(context.objects) do
    f.try(object.unbind, object)
  end

  context.objects = nil

  context.view:unbind()
  context.particles:unbind()
  context.inspector:unbind()
  context.collision:unbind()
end

function context:removeObject(object)
  self.objects[object] = nil
  if object._key then
    self.objects[object._key] = nil
  end
end

function context:getObject(object)
  return self.objects[object]
end

return context
