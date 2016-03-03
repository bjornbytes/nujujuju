local muju = lib.object.create()

muju:include(lib.entity)
muju:include(lib.muju)

muju.config = app.muju.config

muju.state = function()
  local state = {
    team = 'player',
    position = {
      x = app.context.scene.width / 2,
      y = app.context.scene.height / 2
    },
    health = 5,
    maxJuju = 1,
    juju = 0,
    totalJuju = 0,
    jujuTrickleTimer = muju.config.jujuTrickleRate,
    dead = false,
    squishFactor = 0,
    squishActive = false
  }

  state.animation = lib.animation.create(app.muju.spine, app.muju.animation)
  state.animation.speed = 1
  state.animation.flipped = true
  state.animation:set('idle')

  return state
end

function muju:bind()
  self:tint(.5, .2, .7)
  self.collisions = app.context.collision:add(self)

  self.abilities = {}
  self.abilities.auto = app.muju.abilities.summon:new({ owner = self })

  self:dispose({
    love.update
      :subscribe(self:wrap(self.jujuTrickle)),

    app.context.view.draw
      :subscribe(self:wrap(self.draw)),

    love.update:subscribe(function()
      local function makeSpuju(count)
        count = count or 1

        for i = 1, count do
          local x = love.math.random() > .5 and app.context.scene.width - 50 or 50
          local y = 100 + love.math.random() * (app.context.scene.height - 200)

          local spuju = app.enemies.spuju.object:new({
            position = {
              x = x,
              y = y
            }
          })

          app.context.objects[spuju] = spuju
        end
      end

      if lib.tick.index == 3 / lib.tick.rate then
        makeSpuju()
      elseif lib.tick.index == 15 / lib.tick.rate then
        makeSpuju(2)
      elseif lib.tick.index == 30 / lib.tick.rate then
        makeSpuju(3)
      end
    end)
  })
end

return muju
