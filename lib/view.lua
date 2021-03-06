local view = lib.object.create()

function view:init()
  self.x = 0
  self.y = 0
  self.width = 960
  self.height = 720
  self.xmin = -math.huge
  self.ymin = -math.huge
  self.xmax = math.huge--self.width
  self.ymax = math.huge--self.height
  self.frame = {
    x = 0,
    y = 0,
    width = g.getWidth(),
    height = g.getHeight()
  }

  self.viewId = 0
  self.draws = {}
  self.guis = {}
  self.effects = {}
  self.toRemove = {}
  self.target = nil

  self.prevx = 0
  self.prevy = 0
  self.prevscale = 1
  self.shake = 0
end

function view:bind()
  self:resize()

  self.draw = lib.rx.Subject.create()
  self.hud = lib.rx.Subject.create()

  self.draw.onNext = f.self(self.doDraw, self)
  self.hud.onNext = f.self(self.doHud, self)

  return {
    love.resize
      :subscribe(function()
        self:resize()
      end),

    love.update
      :subscribe(function()
        self:update()
      end),

    love.draw
      :subscribe(function()
        self.draw:onNext()
        self.hud:onNext()
      end)
  }
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

  self:worldPush()

  g.setCanvas(source)

  for i = #subject.observers, 1, -1 do
    if subject.observers[i] then
      subject.observers[i].depth = subject.observers[i]:onNext() or 0
      if subject.observers[i] then
        subject.observers[i].depthNudge = subject.observers[i].depthNudge or love.math.random() * .01
      end
    end
  end

  table.sort(subject.observers, function(a, b)
    return (a.depth or 0) + (a.depthNudge or 0) < (b.depth or 0) + (b.depthNudge or 0)
  end)

  g.setCanvas()
  g.pop()

  g.setCanvas()
  g.white()
  g.draw(source)

  --[[local fr = self.frame
  local fx, fy, fw, fh = fr.x, fr.y, fr.width, fr.height

  g.setColor(0, 0, 0)
  g.rectangle('fill', 0, 0, w, fy)
  g.rectangle('fill', 0, 0, fx, h)
  g.rectangle('fill', 0, fy + fh, w, h - (fy + fh))
  g.rectangle('fill', fx + fw, 0, w - (fx + fw), h)]]
end

function view:doHud()
  local w, h = g.getDimensions()
  local subject = self.hud
  local source, target = self.sourceCanvas, self.targetCanvas

  table.sort(subject.observers, function(a, b)
    return (a.depth or 0) < (b.depth or 0)
  end)

  for i = #subject.observers, 1, -1 do
    if subject.observers[i] then
      subject.observers[i].depth = subject.observers[i]:onNext() or 0
    end
  end
end

function view:resize()
  local w, h = g.getDimensions()
  local ratio = w / h

  self.frame.x, self.frame.y, self.frame.width, self.frame.height = 0, 0, self.width, self.height
  if true or (self.width / self.height) > (w / h) then
    self.scale = w / self.width
    local margin = math.max(util.round(((h - w * (self.height / self.width)) / 2)), 0)
    self.frame.y = margin
    self.frame.height = h - 2 * margin
    self.frame.width = w
  else
    self.scale = h / self.height
    local margin = math.max(util.round(((w - h * (self.width / self.height)) / 2)), 0)
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
  local sx, sy = util.lerp(self.prevx, self.x, lib.tick.accum / lib.tick.rate), util.lerp(self.prevy, self.y, lib.tick.accum / lib.tick.rate)
  z = self:convertZ(z)
  return x - (z * ((sx + self.width / 2 - x) / 500)), y - (z * ((sy + self.height / 2 - y) / 500))
end

function view:threeDepth(x, y, z)
  return util.clamp(util.distance(x, y, self.x + self.width / 2, self.y + self.height / 2) * self.scale - 1000 - z, -4096, -16)
end

function view:contain()
  --self.x = util.clamp(self.x, self.xmin, self.xmax - self.width)
  --self.y = util.clamp(self.y, self.ymin, self.ymax - self.height)
end

function view:worldPoint(x, y)
  x = util.round(((x - self.frame.x) / self.scale) + self.x)
  if y then y = util.round(((y - self.frame.y) / self.scale) + self.y) end
  return x, y
end

function view:screenPoint(x, y)
  local vx, vy = util.lerp(self.prevx, self.x, lib.tick.accum / lib.tick.rate), util.lerp(self.prevy, self.y, lib.tick.accum / lib.tick.rate)
  x = (x - vx) * self.scale
  if y then y = (y - vy) * self.scale end
  return x, y
end

function view:worldMouseX()
  return util.round(((love.mouse.getX() - self.frame.x) / self.scale) + self.x)
end

function view:worldMouseY()
  return util.round(((love.mouse.getY() - self.frame.y) / self.scale) + self.y)
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
  local x, y, s = unpack(util.interpolateTable({self.prevx, self.prevy, self.prevscale}, {self.x, self.y, self.scale}, lib.tick.accum / lib.tick.rate))
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
