local game = {}

function game:load()
  lib.quilt:init()
end

function game:update()
  lib.quilt:update(lib.tick.rate)
end

function game:draw()
end

return game
