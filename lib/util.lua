-- To be organized:

function math.lerp(x, y, z)
  return x + (y - x) * z
end

function math.anglerp(d1, d2, z) return d1 + (math.anglediff(d1, d2) * z) end

function math.sign(x)
  return x > 0 and 1 or (x < 0 and -1 or 0)
end

function math.inside(px, py, rx, ry, rw, rh) return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh end
function math.insideCircle(px, py, cx, cy, r) return math.distance(px, py, cx, cy) <= r end

function math.distance(x1, y1, x2, y2)
  return math.sqrt((y2 - y1) ^ 2 + (x2 - x1) ^ 2)
end

function math.direction(x1, y1, x2, y2)
  return math.atan2((y2 - y1), (x2 - x1))
end

function math.clamp(x, l, h) return math.min(math.max(x, l), h) end

function math.round(x)
  return math.floor(x + .5)
end

function table.copy(x, seen)
  seen = seen or {}
  local t = type(x)
  if t ~= 'table' then return x end
  if seen[x] then return seen[x] end
  local y = {}
  seen[x] = y
  for k, v in next, x, nil do y[k] = table.copy(v, seen) end
  setmetatable(y, getmetatable(x))
  return y
end

function table.interpolate(t1, t2, z)
  local interp = table.copy(t1)
  for k, v in pairs(interp) do
    if t2[k] then
      if type(v) == 'table' then interp[k] = table.interpolate(t1[k], t2[k], z)
      elseif type(v) == 'number' then
        if k == 'angle' then interp[k] = math.anglerp(t1[k], t2[k], z)
        else interp[k] = math.lerp(t1[k], t2[k], z) end
      end
    end
  end
  return interp
end

function table.keys(t)
  local keys = {}
  for k in pairs(t) do
    table.insert(keys, k)
  end
  return keys
end

function table.filter(t, fn, iterator)
  iterator = iterator or pairs
  if type(fn) == 'string' then fn = f.key(fn) end
  local res = {}
  for k, v in iterator(t) do
    if fn(v, k) then
      if iterator == pairs then
        res[k] = v
      else
        table.insert(res, v)
      end
    end
  end
  return res
end

function table.each(t, fn, iterator)
  iterator = iterator or pairs
  if type(fn) == 'string' then fn = f.method(fn) end
  for k, v in iterator(t) do
    if fn(v, k) then
      return
    end
  end
end

function table.map(t, fn, iterator)
  iterator = iterator or pairs
  local res = {}
  for k, v in iterator(t) do
    res[k] = fn(v, k)
  end
  return res
end

function table.get(t, path)
  local pieces = {}
  path:gsub('([^%.]+)', function(piece)
    table.insert(pieces, piece)
  end)
  local result = t
  for i = 1, #pieces do
    result = result[pieces[i]]
  end
  return result
end

function table.random(t)
  return t[love.math.random(1, #t)]
end

function table.merge(t1, t2)
  if not t2 then return t1 end
  if not t1 then return t2 end

  for k, v in pairs(t1) do
    t2[k] = v
  end

  return t2
end

function g.drawCenter(image, size, x, y, a, sx, sy)
  local scale = size / image:getWidth()
  sx = sx or 1
  sy = sy or 1
  g.draw(image, x, y, a, scale * sx, scale * sy, image:getWidth() / 2, image:getHeight() / 2)
end

-- Thanks jericson
function g.ellipse(mode, x, y, a, b, phi, points)
  phi = phi or 0
  points = points or 10
  if points <= 0 then points = 1 end

  local two_pi = math.pi*2
  local angle_shift = two_pi/points
  local theta = 0
  local sin_phi = math.sin(phi)
  local cos_phi = math.cos(phi)

  local coords = {}
  for i = 1, points do
    theta = theta + angle_shift
    coords[2*i-1] = x + a * math.cos(theta) * cos_phi
                      - b * math.sin(theta) * sin_phi
    coords[2*i] = y + a * math.cos(theta) * sin_phi
                    + b * math.sin(theta) * cos_phi
  end

  coords[2*points+1] = coords[1]
  coords[2*points+2] = coords[2]

  love.graphics.polygon(mode, coords)
end

function g.white(alpha)
  g.setColor(255, 255, 255, alpha)
  return g
end

function table.count(t)
  local ct = 0
  for _, _ in pairs(t) do
    ct = ct + 1
  end
  return ct
end
