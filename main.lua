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
lib.quilt.init()
f = lib.funk
g = love.graphics
require 'lib/util'

app.context.load('overgrowth')

love.update:subscribe(function()
  lib.flux.update(lib.tick.rate)
end)

love.keypressed
  :filter(f.eq('escape'))
  :subscribe(love.event.quit)

love.keypressed
  :filter(f.eq('r'))
  :subscribe(function()
    app.context.unload()
    app.context.load('overgrowth')
  end)
