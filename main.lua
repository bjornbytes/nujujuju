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
require 'lib/util'

app.scene.load('overgrowth')

love.keypressed
  :filter(f.eq('escape'))
  :subscribe(love.event.quit)
