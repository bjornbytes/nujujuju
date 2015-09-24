local muju = lib.object.create()

muju.props = {
  speed = 160,
  radius = app.grid.props.size / 3,
  image = art.muju,
  origin = {
    x = 40,
    y = 165
  }
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
      g.setColor(255, 255, 255, 50)
      g.circle('fill', self.state.x, self.state.y, self.props.radius, 64)
      g.circle('line', self.state.x, self.state.y, self.props.radius, 64)

      local image = self.props.image
      local scale = 2 * self.props.radius / image:getWidth() * 1.5
      g.setColor(255, 255, 255)
      g.draw(image, self.state.x, self.state.y + 10, 0, scale * self.state.facing, scale, self.props.origin.x, self.props.origin.y)
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
  state.facing = dx or state.facing
  self:setState(state)
end

return muju:new({
  x = 400,
  y = 300,
  facing = 1,
  transformed = false
})
