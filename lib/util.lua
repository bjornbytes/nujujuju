local util = {}

function util.lerp(x, y, z)
  return x + (y - x) * z
end

function util.anglediff(d1, d2) return math.rad((((math.deg(d2) - math.deg(d1) % 360) + 540) % 360) - 180) end
function util.inside(px, py, rx, ry, rw, rh) return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh end
function util.insideCircle(px, py, cx, cy, r) return math.distance(px, py, cx, cy) <= r end
function util.sign(x) if x == 0 then return 0 else return lib.lume.sign(x) end end
function util.vector(...) return util.distance(...), util.angle(...) end
function util.anglerp(d1, d2, z) return d1 + (util.anglediff(d1, d2) * z) end

function util.choose(...)
  return lib.lume.randomchoice({...})
end

function util.dx(dis, dir)
  return dis * math.cos(dir)
end

function util.dy(dis, dir)
  return dis * math.sin(dir)
end

function util.copy(x, seen)
  seen = seen or {}
  local t = type(x)
  if t ~= 'table' then return x end
  if seen[x] then return seen[x] end
  local y = {}
  seen[x] = y
  for k, v in next, x, nil do y[k] = util.copy(v, seen) end
  setmetatable(y, getmetatable(x))
  return y
end

function util.interpolateTable(t1, t2, z)
  local interp = util.copy(t1)
  for k, v in pairs(interp) do
    if t2[k] then
      if type(v) == 'table' then interp[k] = util.interpolateTable(t1[k], t2[k], z)
      elseif type(v) == 'number' then
        if k == 'angle' then interp[k] = math.anglerp(t1[k], t2[k], z)
        else interp[k] = util.lerp(t1[k], t2[k], z) end
      end
    end
  end
  return interp
end

function util.get(t, path)
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

function util.merge(t1, t2)
  if not t2 then return t1 end
  if not t1 then return t2 end

  for k, v in pairs(t1) do
    t2[k] = v
  end

  return t2
end

function util.isa(object, class)
  return getmetatable(object) and getmetatable(object).__index == class
end

function g.drawCenter(image, size, x, y, a, sx, sy)
  local scale = size / image:getWidth()
  sx = sx or 1
  sy = sy or 1
  g.draw(image, x, y, a, scale * sx, scale * sy, image:getWidth() / 2, image:getHeight() / 2)
end

function g.white(alpha)
  g.setColor(255, 255, 255, alpha)
  return g
end

function g.alpha(color, alpha, ...)
  if type(color) == 'table' then
    local result = util.copy(color)
    result[4] = alpha
    return result
  end

  return color, alpha, ...
end

function g.imageScale(image, size)
  return size / image:getWidth()
end

function lib.tick.getLerpFactor(factor)
  return ((1 / lib.tick.rate) * factor) * lib.tick.rate
end

function util.timeSince(tick)
  return (lib.tick.index - tick) * lib.tick.rate
end

return util
