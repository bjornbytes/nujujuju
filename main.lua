require 'lib/slam'

setmetatable(_G, {
  __index = require('lib/cargo').init({
    dir = '/',
    loaders = {
      txt = love.filesystem.read,
      json = function(path)
        return (require 'lib/json').decode(love.filesystem.read(path))
      end
    }
  })
})

require 'lib/rx-love'
lib.tick.init()
f = lib.funk
g = love.graphics

function love.load()
  app.grid:bind()

  app.dirt.object:new({
    x = app.grid.props.size * 2,
    y = app.grid.props.size * 6
  }):bind()

  app.shrine.object:new({
    x = app.grid.props.size * 6,
    y = app.grid.props.size * 2
  }):bind()

  muju = app.muju.object:new():bind()
end

function math.lerp(x, y, z)
  return x + (y - x) * z
end
