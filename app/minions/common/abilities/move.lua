local move = lib.object.create()

function move:cast(x, y)
  self.owner.destination.x, self.owner.destination.y = x, y
end

return move
