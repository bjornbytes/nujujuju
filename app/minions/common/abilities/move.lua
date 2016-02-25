local move = lib.object.create()

function move:cast(x, y)
  self.owner.target.x, self.owner.target.y = x, y
end

return move
