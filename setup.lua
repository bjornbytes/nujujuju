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

-- To be organized:

function math.lerp(x, y, z)
  return x + (y - x) * z
end

function math.sign(x)
  return x > 0 and 1 or (x < 0 and -1 or 0)
end
