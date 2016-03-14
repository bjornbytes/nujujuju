require 'lib/slam'

setmetatable(_G, {
  __index = require('lib/cargo').init({
    dir = '/',
    loaders = {
      txt = love.filesystem.read,
      json = function(path)
        return (require 'lib/json').decode(love.filesystem.read(path))
      end
    },
    processors = {
      abilities = function(ability, filename)
        ability.tag = filename:gsub('%.lua$', ''):gsub('.+/', '')
      end
    }
  })
})

require 'lib/rx-love'
lib.tick.init()
lib.quilt.init()
f = lib.funk
g = love.graphics
util = setmetatable(lib.util, { __index = lib.lume })

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
