local move = lib.object.create()

function move:cast(x, y)
  self.owner.destination.x = x
  self.owner.destination.y = y
  self.owner.target = nil
end

return move
