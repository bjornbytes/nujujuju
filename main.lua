setmetatable(_G, {__index = require('lib/cargo').init('/')})
f = lib.funk
lib.tick.init()

function love.load()
  lib.context:switch(app.game)
end
