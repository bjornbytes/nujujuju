local particles = {}

function particles.create()
  local self = {
    systems = {}
  }

  setmetatable(self, {__index = particles})

  local particleList = {'dust', 'thujustep'}
  for i = 1, #particleList do
    local name = particleList[i]
    local particle = app.particles[name]
    local system = g.newParticleSystem(particle.image, particle.max or 1024)
    system:setOffset(particle.image:getWidth() / 2, particle.image:getHeight() / 2)
    self.systems[name] = system
    for option, value in pairs(particle.options) do
      self:apply(name, option, value)
    end
  end

  return self
end

function particles:bind()
  app.scene.view.draw:subscribe(function()
    g.setColor(255, 255, 255)
    for code, system in pairs(self.systems) do
      system:update(lib.tick.delta)
      g.setBlendMode(app.particles[code].blendMode or 'alpha')
      g.draw(system)
      g.setBlendMode('alpha')
    end
    return -800
  end)

  return self
end

function particles:emit(code, x, y, count, options)
  if type(count) == 'table' then
    options = count
    count = 1
  end

  options = options or {}

  if type(options) == 'function' then
    for i = 1, count do
      self:emit(code, x, y, 1, options())
    end
  else
    for option, value in pairs(options) do
      self:apply(code, option, value)
    end

    self.systems[code]:setPosition(x, y)
    self.systems[code]:emit(count)

    for option, value in pairs(options) do
      if app.particles[code].options[option] then
        self:apply(code, option, app.particles[code].options[option])
      end
    end
  end
end

function particles:apply(code, option, value)
  local system = self.systems[code]
  local capitalized = option:sub(1, 1):upper() .. option:sub(2)
  local setter = system['set' .. capitalized]
  if type(value) == 'table' then setter(system, unpack(value))
  else setter(system, value) end
end

return particles
