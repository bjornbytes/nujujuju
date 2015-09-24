setmetatable(_G, {__index = require('lib/cargo').init('/')})
dofile('lib/rx-love.lua')
f = lib.funk
g = love.graphics
lib.tick.init()

function love.load()
  app.grid:bind()
  app.muju:bind()
  app.dirt:new({
    x = app.grid.props.size * 2,
    y = app.grid.props.size * 6
  }):bind()
  app.shrine:new({
    x = app.grid.props.size * 6,
    y = app.grid.props.size * 2
  }):bind()
end

function math.lerp(x, y, z)
  return x + (y - x) * z
end
