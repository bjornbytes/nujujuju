local view = lib.object.create()

view.state = {
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

function view:bind()
  self:resize()

  self.draw = lib.rx.Subject.create()
  self.hud = lib.rx.Subject.create()

  self.draw.onNext = function(subject, ...)
    local w, h = g.getDimensions()
    local state = self.state
    local source, target = state.sourceCanvas, state.targetCanvas

    table.sort(subject.observers, function(a, b)
      return (a.depth or 0) > (b.depth or 0)
    end)

    self:worldPush()

    g.setCanvas(source)

    for i = 1, #subject.observers do
      subject.observers[i].depth = subject.observers[i]:onNext(...) or 0
    end

    g.setCanvas()
    g.pop()

    g.setCanvas()
    g.setColor(255, 255, 255)
    g.draw(source)
  end

  self.hud.onNext = function(subject, ...)
    local w, h = g.getDimensions()
    local state = self.state
    local source, target = state.sourceCanvas, state.targetCanvas

    table.sort(subject.observers, function(a, b)
      return (a.depth or 0) > (b.depth or 0)
    end)

    for i = 1, #subject.observers do
      subject.observers[i].depth = subject.observers[i]:onNext(...) or 0
    end
  end

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
  local state = self.state

  state.prevx = state.x
  state.prevy = state.y
  state.prevscale = state.scale

  self:contain()

  state.shake = math.lerp(state.shake, 0, 8 * lib.tick.rate)

  while #state.toRemove > 0 do
    local x = state.toRemove[1]

    if x.draw then
      for i = 1, #state.draws do
        if state.draws[i] == x then table.remove(state.draws, i) i = #state.draws + 1 end
      end
    end

    if x.gui then
      for i = 1, #state.guis do
        if state.guis[i] == x then table.remove(state.guis, i) i = #state.guis + 1 end
      end
    end

    for i = 1, #state.effects do
      if state.effects[i] == x then table.remove(state.effects, i) i = #state.effects + 1 end
    end

    table.remove(state.toRemove, 1)
  end

  table.sort(state.draws, function(a, b)
    return a.depth == b.depth and a.viewId < b.viewId or a.depth > b.depth
  end)
end

function view:resize()
  local state = self.state
  local w, h = g.getDimensions()
  local ratio = w / h

  state.frame.x, state.frame.y, state.frame.width, state.frame.height = 0, 0, state.width, state.height
  if (state.width / state.height) > (w / h) then
    state.scale = w / state.width
    local margin = math.max(math.round(((h - w * (state.height / state.width)) / 2)), 0)
    state.frame.y = margin
    state.frame.height = h - 2 * margin
    state.frame.width = w
  else
    state.scale = h / state.height
    local margin = math.max(math.round(((w - h * (state.width / state.height)) / 2)), 0)
    state.frame.x = margin
    state.frame.width = w - 2 * margin
    state.frame.height = h
  end

  state.sourceCanvas = g.newCanvas(w, h)
  state.targetCanvas = g.newCanvas(w, h)
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
  local sx, sy = math.lerp(self.prevx, self.x, ls.accum / lib.tick.rate), math.lerp(self.prevy, self.y, ls.accum / lib.tick.rate)
  z = self:convertZ(z)
  return x - (z * ((sx + self.width / 2 - x) / 500)), y - (z * ((sy + self.height / 2 - y) / 500))
end

function view:threeDepth(x, y, z)
  return math.clamp(math.distance(x, y, self.x + self.width / 2, self.y + self.height / 2) * self.scale - 1000 - z, -4096, -16)
end

function view:contain()
  local state = self.state
  state.x = math.clamp(state.x, 0, state.xmax - state.width)
  state.y = math.clamp(state.y, 0, state.ymax - state.height)
end

function view:worldPoint(x, y)
  x = math.round(((x - state.frame.x) / self.scale) + self.x)
  if y then y = math.round(((y - state.frame.y) / self.scale) + self.y) end
  return x, y
end

function view:screenPoint(x, y)
  local vx, vy = math.lerp(self.prevx, self.x, ls.accum / lib.tick.rate), math.lerp(self.prevy, self.y, ls.accum / lib.tick.rate)
  x = (x - vx) * self.scale
  if y then y = (y - vy) * self.scale end
  return x, y
end

function view:worldMouseX()
  return math.round(((love.mouse.getX() - self.state.frame.x) / self.scale) + self.x)
end

function view:worldMouseY()
  return math.round(((love.mouse.getY() - self.state.frame.y) / self.scale) + self.y)
end

function view:frameMouseX()
  return love.mouse.getX() - self.state.frame.x
end

function view:frameMouseY()
  return love.mouse.getY() - self.state.frame.y
end

function view:screenshake(amount)
  if self.shake > amount then self.shake = self.shake + (amount / 2) end
  self.shake = amount
end

function view:worldPush()
  local state = self.state
  local x, y, s = unpack(table.interpolate({state.prevx, state.prevy, state.prevscale}, {state.x, state.y, state.scale}, lib.tick.accum / lib.tick.rate))
  local shakex = 1 - (2 * love.math.noise(state.shake + x + lib.tick.accum))
  local shakey = 1 - (2 * love.math.noise(state.shake + y + lib.tick.accum))
  x = x + (shakex * state.shake)
  y = y + (shakey * state.shake)

  g.push()
  g.translate(state.frame.x, state.frame.y)
  g.scale(s)
  g.translate(-x, -y)
end

function view:guiPush()
  g.push()
  g.translate(self.state.frame.x, self.state.frame.y)
end

return view