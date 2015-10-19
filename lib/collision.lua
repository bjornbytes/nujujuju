local collision = lib.object.create()

collision.config = {
  size = 100
}

collision.state = function()
  return {
    grid = {}
  }
end

collision.handlers = {
  ['circle:circle'] = function(o1, o2)
    local x1, y1, x2, y2, r1, r2 = o1.position.x, o1.position.y, o2.position.x, o2.position.y, o1.config.radius, o2.config.radius
    local dis = math.distance(x1, y1, x2, y2)
    if dis <= r1 + r2 then
      local dir = math.direction(x1, y1, x2, y2)
      local overlap = (r1 + r2) - dis
      return overlap * math.cos(dir), overlap * math.sin(dir)
    end
  end,
  ['circle:ellipse'] = function(o1, o2)
    local x1, y1, x2, y2, r1, a, b = o1.position.x, o1.position.y, o2.position.x, o2.position.y, o1.config.radius, o2.config.radius, o2.config.radius / o2.config.perspective
    local dis = math.distance(x1, y1, x2, y2)
    local dir = math.direction(x1, y1, x2, y2)
    local r2 = (a * b) / math.sqrt((b * math.cos(dir)) ^ 2 + (a * math.sin(dir)) ^ 2)
    local ex = x2 + math.cos(dir + math.pi) * r2
    local ey = y2 + math.sin(dir + math.pi) * r2
    local overlap = r1 - math.distance(x1, y1, ex, ey)
    if overlap > 0 then
      return overlap * math.cos(dir), overlap * math.sin(dir)
    end
  end
}

function collision:bind()
  love.update
    :subscribe(function()
      for cell, objects in pairs(self.grid) do
        for object in pairs(objects) do
          self:refresh(object)
          for neighbor in pairs(self:neighbors(object)) do
            local dx, dy = self:resolve(object, neighbor)
            if dx and dy then
              object._collisions(neighbor, dx, dy)
            end
          end
        end
      end
    end)

  app.context.view.draw
    :subscribe(function()
      if not app.context.inspector.active then return end

      g.white(10)
      local w, h = app.context.scene.width, app.context.scene.height

      for x = 0, w, self.config.size do
        g.line(x, 0, x, h)
      end

      for y = 0, h, self.config.size do
        g.line(0, y, w, y)
      end

      return -1000
    end)
end

function collision:refresh(object)
  local cell = self:serialize(self:cell(object.position.x, object.position.y))
  if object._cell ~= cell then
    if object._cell and self.grid[object._cell] then
      self.grid[object._cell][object] = nil
    end
    object._cell = cell
    self.grid[cell] = self.grid[cell] or {}
    self.grid[cell][object] = object
  end
end

function collision:add(object)
  self:refresh(object)
  object._collisions = lib.rx.Subject.create()
  return object._collisions
end

function collision:remove(object)
  if object._collisions then
    object._collisions:onComplete()
    object._collisions = nil
  end

  if object._cell and self.grid[object._cell] then
    self.grid[object._cell][object] = nil
    object._cell = nil
  end
end

function collision:cell(x, y)
  return math.ceil(x / self.config.size), math.ceil(y / self.config.size)
end

function collision:serialize(x, y)
  return x .. ':' .. y
end

function collision:neighbors(object)
  local neighbors = {}
  local ox, oy = self:cell(object.position.x, object.position.y)
  for x = ox - 1, ox + 1 do
    for y = oy - 1, oy + 1 do
      local cell = self.grid[self:serialize(x, y)]
      if cell then
        for object in pairs(cell) do
          neighbors[object] = object
        end
      end
    end
  end
  neighbors[object] = nil
  return neighbors
end

function collision:resolve(o1, o2)
  local s1, s2 = o1.config.shape, o2.config.shape
  local dx, dy = f.try(self.handlers[s1 .. ':' .. s2], o1, o2)
  if dx and dy then return dx, dy end
  return self:invert(f.try(self.handlers[s2 .. ':' .. s1], o2, o1))
end

function collision:invert(x, y)
  if not x or not y then return x, y end
  return -x, -y
end

return collision
