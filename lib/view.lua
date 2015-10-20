local view = lib.object.create()

view.state = function()
  return {
    x = 0,
    y = 0,
    width = 800,
    height = 600,
    xmin = 0,
    ymin = 0,
    xmax = 800,
    ymax = 600,
    frame = {
      x = 0,
      y = 0,
      width = g.getWidth(),
      height = g.getHeight()
    },

    viewId = 0,
    draws = {},
    guis = {},
    effects = {},
    toRemove = {},
    target = nil,

    prevx = 0,
    prevy = 0,
    prevscale = 1,
    shake = 0
  }
end

function view:bind()
  self:resize()

  self.draw = lib.rx.Subject.create()
  self.hud = lib.rx.Subject.create()

  self.draw.onNext = f.self(self.doDraw, self)
  self.hud.onNext = f.self(self.doHud, self)

  love.update
    :subscribe(function()
      self:update()
    end)

  love.draw
    :subscribe(function()
      self.draw:onNext()
      self.hud:onNext()
    end)
end

function view:update()
  self.prevx = self.x
  self.prevy = self.y
  self.prevscale = self.scale

  self:contain()

  self.shake = math.max(self.shake - lib.tick.rate, 0)
end

function view:doDraw()
  local w, h = g.getDimensions()
  local subject = self.draw
  local source, target = self.sourceCanvas, self.targetCanvas

  table.sort(subject.observers, function(a, b)
    return (a.depth or 0) > (b.depth or 0)
  end)

  self:worldPush()

  g.setCanvas(source)

  for i = 1, #subject.observers do
    if subject.observers[i] then
      subject.observers[i].depth = subject.observers[i]:onNext() or 0
    end
  end

  g.setCanvas()
  g.pop()

  g.setCanvas()
  g.white()
  g.draw(source)

  local fr = self.frame
  local fx, fy, fw, fh = fr.x, fr.y, fr.width, fr.height

  g.setColor(0, 0, 0)
  g.rectangle('fill', 0, 0, w, fy)
  g.rectangle('fill', 0, 0, fx, h)
  g.rectangle('fill', 0, fy + fh, w, h - (fy + fh))
  g.rectangle('fill', fx + fw, 0, w - (fx + fw), h)
end

function view:doHud()
  local w, h = g.getDimensions()
  local subject = self.hud
  local source, target = self.sourceCanvas, self.targetCanvas

  table.sort(subject.observers, function(a, b)
    return (a.depth or 0) > (b.depth or 0)
  end)

  for i = 1, #subject.observers do
    if subject.observers[i] then
      subject.observers[i].depth = subject.observers[i]:onNext() or 0
    end
  end
end

function view:resize()
  local w, h = g.getDimensions()
  local ratio = w / h

  self.frame.x, self.frame.y, self.frame.width, self.frame.height = 0, 0, self.width, self.height
  if (self.width / self.height) > (w / h) then
    self.scale = w / self.width
    local margin = math.max(math.round(((h - w * (self.height / self.width)) / 2)), 0)
    self.frame.y = margin
    self.frame.height = h - 2 * margin
    self.frame.width = w
  else
    self.scale = h / self.height
    local margin = math.max(math.round(((w - h * (self.width / self.height)) / 2)), 0)
    self.frame.x = margin
    self.frame.width = w - 2 * margin
    self.frame.height = h
  end

  self.sourceCanvas = g.newCanvas(w, h)
  self.targetCanvas = g.newCanvas(w, h)
end

function view:register(x, action)
  x.viewId = self.viewId
  action = action or 'draw'
  if action == 'draw' then
    table.insert(self.draws, x)
    x.depth = x.depth or 0
  elseif action == 'gui' then
    table.insert(self.guis, x)
  elseif action == 'effect' then
    table.insert(self.effects, x)
  end

  self.viewId = self.viewId + 1
end

function view:unregister(x)
  table.insert(self.toRemove, x)
end

function view:convertZ(z)
  return (.8 * z) ^ (1 + (.0008 * z))
end

function view:three(x, y, z)
  local sx, sy = math.lerp(self.prevx, self.x, lib.tick.accum / lib.tick.rate), math.lerp(self.prevy, self.y, lib.tick.accum / lib.tick.rate)
  z = self:convertZ(z)
  return x - (z * ((sx + self.width / 2 - x) / 500)), y - (z * ((sy + self.height / 2 - y) / 500))
end

function view:threeDepth(x, y, z)
  return math.clamp(math.distance(x, y, self.x + self.width / 2, self.y + self.height / 2) * self.scale - 1000 - z, -4096, -16)
end

function view:contain()
  self.x = math.clamp(self.x, 0, self.xmax - self.width)
  self.y = math.clamp(self.y, 0, self.ymax - self.height)
end

function view:worldPoint(x, y)
  x = math.round(((x - self.frame.x) / self.scale) + self.x)
  if y then y = math.round(((y - self.frame.y) / self.scale) + self.y) end
  return x, y
end

function view:screenPoint(x, y)
  local vx, vy = math.lerp(self.prevx, self.x, lib.tick.accum / lib.tick.rate), math.lerp(self.prevy, self.y, lib.tick.accum / lib.tick.rate)
  x = (x - vx) * self.scale
  if y then y = (y - vy) * self.scale end
  return x, y
end

function view:worldMouseX()
  return math.round(((love.mouse.getX() - self.frame.x) / self.scale) + self.x)
end

function view:worldMouseY()
  return math.round(((love.mouse.getY() - self.frame.y) / self.scale) + self.y)
end

function view:frameMouseX()
  return love.mouse.getX() - self.frame.x
end

function view:frameMouseY()
  return love.mouse.getY() - self.frame.y
end

function view:screenshake(amount)
  self.shake = math.max(self.shake, amount)
end

function view:worldPush()
  local x, y, s = unpack(table.interpolate({self.prevx, self.prevy, self.prevscale}, {self.x, self.y, self.scale}, lib.tick.accum / lib.tick.rate))
  if self.shake > .01 then
    local shakex = -1 + love.math.random() * 2
    local shakey = -1 + love.math.random() * 2
    x = x + (shakex * 5)
    y = y + (shakey * 5)
  end

  g.push()
  g.translate(self.frame.x, self.frame.y)
  g.scale(s)
  g.translate(-x, -y)
end

function view:guiPush()
  g.push()
  g.translate(self.self.frame.x, self.self.frame.y)
end

return view
