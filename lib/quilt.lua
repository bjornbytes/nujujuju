local quilt = {}

function quilt.init()
  quilt.threads = {}
  quilt.delays = {}

  love.update:subscribe(quilt.update)
end

function quilt.add(thread)
  quilt.threads[thread] = coroutine.create(thread)
  quilt.delays[thread] = 0
  return thread
end

function quilt.remove(thread, ...)
  if not thread then return end
  quilt.threads[thread] = nil
  return quilt.remove(...)
end

function quilt.reset(thread)
  quilt.delays[thread] = 0
  return thread
end

function quilt.update()
  for thread, cr in pairs(quilt.threads) do
    if quilt.delays[thread] <= lib.tick.rate then
      local _, delay = coroutine.resume(cr)
      quilt.delays[thread] = delay or 0

      if coroutine.status(cr) == 'dead' then
        quilt.remove(thread)
      end
    else
      quilt.delays[thread] = quilt.delays[thread] - lib.tick.rate
    end
  end
end

return quilt
