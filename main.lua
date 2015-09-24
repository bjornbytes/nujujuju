setmetatable(_G, {__index = require('lib/cargo').init('/')})
dofile('lib/rx-love.lua')
f = lib.funk
lib.tick.init()

function love.load()
  app.grid:bind()
  app.muju:bind()
end

function math.lerp(x, y, z)
  return x + (y - x) * z
end
