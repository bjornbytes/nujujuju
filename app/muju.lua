local muju = lib.object.create({
  x = 400,
  y = 300,
  transformed = false
})

muju.props = {
  speed = 160,
  radius = app.grid.props.size / 2
}

function muju:bind()
  love.update
    :map(function()
      return {
        love.keyboard.isDown('w'),
        love.keyboard.isDown('a'),
        love.keyboard.isDown('s'),
        love.keyboard.isDown('d')
      }
    end)
    :unpack()
    :subscribe(f.self(self.move, self))

  love.draw
    :subscribe(function()
      local g = love.graphics
      g.setColor(255, 255, 255, 50)
      g.circle('fill', self.state.x, self.state.y, self.props.radius, 64)
      g.circle('line', self.state.x, self.state.y, self.props.radius, 64)
    end)
end

function muju:move(w, a, s, d)
  local dx, dy

  if a and not d then
    dx = -1
  elseif d then
    dx = 1
  end

  if w and not s then
    dy = -1
  elseif s then
    dy = 1
  end

  if not dx and not dy then
    return
  end

  local direction = math.atan2(dy or 0, dx or 0)
  local state = self.state
  state.x = state.x + math.cos(direction) * self.props.speed * lib.tick.rate
  state.y = state.y + math.sin(direction) * self.props.speed * lib.tick.rate
  self:setState(state)
end

return muju
