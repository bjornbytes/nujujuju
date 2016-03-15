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
      end,
      ['%.lua'] = function(object, filename)
        local configFile = filename:gsub('[^/]+%.lua', 'config.lua')
        if love.filesystem.exists(configFile) then
          object.config = love.filesystem.load(configFile)()
        end
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

love.update:subscribe(lib.flux.update)

love.keypressed
  :filter(f.eq('escape'))
  :subscribe(love.event.quit)

love.keypressed
  :filter(f.eq('r'))
  :subscribe(function()
    app.context.unload()
    app.context.load('overgrowth')
  end)
