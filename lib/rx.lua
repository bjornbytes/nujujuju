local rx

local pack = table.pack or function(...) return {...} end
local unpack = table.unpack or unpack
local function eq(x, y) return x == y end
local function noop() end
local function identity(x) return x end
local function constant(x) return function() return x end end

--- @class Observer
-- @description Observers are simple objects that receive values from Observables.
local Observer = {}
Observer.__index = Observer
Observer.__tostring = constant('Observer')

--- Creates a new Observer.
-- @arg {function=} onNext - Called when the Observable produces a value.
-- @arg {function=} onError - Called when the Observable terminates due to an error.
-- @arg {function=} onComplete - Called when the Observable completes normally.
-- @returns {Observer}
function Observer.create(onNext, onError, onComplete)
  local self = {
    _onNext = onNext or noop,
    _onError = onError or error,
    _onComplete = onComplete or noop,
    stopped = false
  }

  return setmetatable(self, Observer)
end

--- Pushes zero or more values to the Observer.
-- @arg {*...} values
function Observer:onNext(...)
  if not self.stopped then
    return self._onNext(...)
  end
end

--- Notify the Observer that an error has occurred.
-- @arg {string=} message - A string describing what went wrong.
function Observer:onError(message)
  if not self.stopped then
    self.stopped = true
    self._onError(message)
  end
end

--- Notify the Observer that the sequence has completed and will produce no more values.
function Observer:onComplete()
  if not self.stopped then
    self.stopped = true
    self._onComplete()
  end
end

--- @class Observable
-- @description Observables push values to Observers.
local Observable = {}
Observable.__index = Observable
Observable.__tostring = constant('Observable')

--- Creates a new Observable.
-- @arg {function} subscribe - The subscription function that produces values.
-- @returns {Observable}
function Observable.create(subscribe)
  local self = {
    _subscribe = subscribe
  }

  return setmetatable(self, Observable)
end

--- Shorthand for creating an Observer and passing it to this Observable's subscription function.
-- @arg {function} onNext - Called when the Observable produces a value.
-- @arg {function} onError - Called when the Observable terminates due to an error.
-- @arg {function} onComplete - Called when the Observable completes normally.
function Observable:subscribe(onNext, onError, onComplete)
  if type(onNext) == 'table' then
    return self._subscribe(onNext)
  else
    return self._subscribe(Observer.create(onNext, onError, onComplete))
  end
end

--- Creates an Observable that produces a single value.
-- @arg {*} value
-- @returns {Observable}
function Observable.fromValue(value)
  return Observable.create(function(observer)
    observer:onNext(value)
    observer:onComplete()
  end)
end

--- Creates an Observable that produces a range of values in a manner similar to a Lua for loop.
-- @arg {number} initial - The first value of the range, or the upper limit if no other arguments
--                         are specified.
-- @arg {number=} limit - The second value of the range.
-- @arg {number=1} step - An amount to increment the value by each iteration.
-- @returns {Observable}
function Observable.fromRange(initial, limit, step)
  if not limit and not step then
    initial, limit = 1, initial
  end

  step = step or 1

  return Observable.create(function(observer)
    for i = initial, limit, step do
      observer:onNext(i)
    end

    observer:onComplete()
  end)
end

--- Creates an Observable that produces values from a table.
-- @arg {table} table - The table used to create the Observable.
-- @arg {function=pairs} iterator - An iterator used to iterate the table, e.g. pairs or ipairs.
-- @arg {boolean} keys - Whether or not to also emit the keys of the table.
-- @returns {Observable}
function Observable.fromTable(t, iterator, keys)
  iterator = iterator or pairs
  return Observable.create(function(observer)
    for key, value in iterator(t) do
      observer:onNext(value, keys and key or nil)
    end

    observer:onComplete()
  end)
end

--- Creates an Observable that produces values when the specified coroutine yields.
-- @arg {thread} coroutine
-- @returns {Observable}
function Observable.fromCoroutine(thread)
  thread = type(thread) == 'function' and coroutine.create(thread) or thread
  return Observable.create(function(observer)
    return rx.scheduler:schedule(function()
      while not observer.stopped do
        local success, value = coroutine.resume(thread)

        if success then
          observer:onNext(value)
        else
          return observer:onError(value)
        end

        if coroutine.status(thread) == 'dead' then
          return observer:onComplete()
        end

        coroutine.yield()
      end
    end)
  end)
end

--- Subscribes to this Observable and prints values it produces.
-- @arg {string=} name - Prefixes the printed messages with a name.
function Observable:dump(name)
  name = name and (name .. ' ') or ''

  local function serialize(t)
    return tostring(t)
  end

  local onNext = function(...) print(name .. 'onNext: ' .. serialize(...)) end
  local onError = function(e) print(name .. 'onError: ' .. e) end
  local onComplete = function() print(name .. 'onComplete') end

  return self:subscribe(onNext, onError, onComplete)
end

-- The functions below transform the values produced by an Observable and return a new Observable
-- that produces these values.

--- Returns an Observable that only produces values from the original if they are different from
-- the previous value.
-- @arg {function} comparator - A function used to compare 2 values. If unspecified, == is used.
-- @returns {Observable}
function Observable:changes(comparator)
  comparator = comparator or eq

  return Observable.create(function(observer)
    local first = true
    local currentValue = nil

    local function onNext(value, ...)
      if first or not comparator(value, currentValue) then
        observer:onNext(value, ...)
        currentValue = value
        first = false
      end
    end

    local function onError(message)
      return observer:onError(onError)
    end

    local function onComplete()
      return observer:onComplete()
    end

    return self:subscribe(onNext, onError, onComplete)
  end)
end

--- Returns a new Observable that runs a combinator function on the most recent values from a set
-- of Observables whenever any of them produce a new value. The results of the combinator function
-- are produced by the new Observable.
-- @arg {Observable...} observables - One or more Observables to combine.
-- @arg {function} combinator - A function that combines the latest result from each Observable and
--                              returns a single value.
-- @returns {Observable}
function Observable:combine(...)
  local sources = {...}
  local combinator = table.remove(sources)
  if type(combinator) ~= 'function' then
    table.insert(sources, combinator)
    combinator = function(...) return ... end
  end
  table.insert(sources, 1, self)

  return Observable.create(function(observer)
    local latest = {}
    local pending = {unpack(sources)}
    local completed = {}

    local function onNext(i)
      return function(value)
        latest[i] = value
        pending[i] = nil

        if not next(pending) then
          observer:onNext(combinator(unpack(latest)))
        end
      end
    end

    local function onError(e)
      return observer:onError(e)
    end

    local function onComplete(i)
      return function()
        table.insert(completed, i)

        if #completed == #sources then
          observer:onComplete()
        end
      end
    end

    for i = 1, #sources do
      sources[i]:subscribe(onNext(i), onError, onComplete(i))
    end
  end)
end

--- Returns a new Observable that produces the values of the first with falsy values removed.
-- @returns {Observable}
function Observable:compact()
  return self:filter(identity)
end

--- Returns a new Observable that produces the values produced by all the specified Observables in
-- the order they are specified.
-- @arg {Observable...} sources - The Observables to concatenate.
-- @returns {Observable}
function Observable:concat(other, ...)
  if not other then return self end

  local others = {...}

  return Observable.create(function(observer)
    local function onNext(...)
      return observer:onNext(...)
    end

    local function onError(message)
      return observer:onError(message)
    end

    local function onComplete()
      return observer:onComplete()
    end

    local function chain()
      return other:concat(unpack(others)):subscribe(onNext, onError, onComplete)
    end

    return self:subscribe(onNext, onError, chain)
  end)
end

--- Returns a new Observable that produces the values from the original with duplicates removed.
-- @returns {Observable}
function Observable:distinct()
  return Observable.create(function(observer)
    local values = {}

    local function onNext(x)
      if not values[x] then
        observer:onNext(x)
      end

      values[x] = true
    end

    local function onError(e)
      return observer:onError(e)
    end

    local function onComplete()
      return observer:onComplete()
    end

    return self:subscribe(onNext, onError, onComplete)
  end)
end

--- Returns a new Observable that only produces values of the first that satisfy a predicate.
-- @arg {function} predicate - The predicate used to filter values.
-- @returns {Observable}
function Observable:filter(predicate)
  predicate = predicate or identity

  return Observable.create(function(observer)
    local function onNext(...)
      if predicate(...) then
        return observer:onNext(...)
      end
    end

    local function onError(e)
      return observer:onError(e)
    end

    local function onComplete()
      return observer:onComplete(e)
    end

    return self:subscribe(onNext, onError, onComplete)
  end)
end

--- Returns a new Observable that produces the first value of the original that satisfies a
-- predicate.
-- @arg {function} predicate - The predicate used to find a value.
function Observable:find(predicate)
  predicate = predicate or identity

  return Observable.create(function(observer)
    local function onNext(...)
      if predicate(...) then
        observer:onNext(...)
        return observer:onComplete()
      end
    end

    local function onError(message)
      return observer:onError(e)
    end

    local function onComplete()
      return observer:onComplete()
    end

    return self:subscribe(onNext, onError, onComplete)
  end)
end

--- Returns a new Observable that only produces the first result of the original.
-- @returns {Observable}
function Observable:first()
  return self:take(1)
end

--- Returns a new Observable that subscribes to the Observables produced by the original and
-- produces their values.
-- @returns {Observable}
function Observable:flatten()
  return Observable.create(function(observer)
    local function onError(message)
      return observer:onError(message)
    end

    local function onNext(observable)
      local function innerOnNext(...)
        observer:onNext(...)
      end

      observable:subscribe(innerOnNext, onError, noop)
    end

    local function onComplete()
      return observer:onComplete()
    end

    return self:subscribe(onNext, onError, onComplete)
  end)
end

--- Returns a new Observable that only produces the last result of the original.
-- @returns {Observable}
function Observable:last()
  return Observable.create(function(observer)
    local value
    local empty = true

    local function onNext(...)
      value = {...}
      empty = false
    end

    local function onError(e)
      return observer:onError(e)
    end

    local function onComplete()
      if not empty then
        observer:onNext(unpack(value or {}))
      end

      return observer:onComplete()
    end

    return self:subscribe(onNext, onError, onComplete)
  end)
end

--- Returns a new Observable that produces the values of the original transformed by a function.
-- @arg {function} callback - The function to transform values from the original Observable.
-- @returns {Observable}
function Observable:map(callback)
  return Observable.create(function(observer)
    callback = callback or identity

    local function onNext(...)
      return observer:onNext(callback(...))
    end

    local function onError(e)
      return observer:onError(e)
    end

    local function onComplete()
      return observer:onComplete()
    end

    return self:subscribe(onNext, onError, onComplete)
  end)
end

--- Returns a new Observable that produces the maximum value produced by the original.
-- @returns {Observable}
function Observable:max()
  return self:reduce(math.max)
end

--- Returns a new Observable that produces the minimum value produced by the original.
-- @returns {Observable}
function Observable:min()
  return self:reduce(math.min)
end

--- Returns a new Observable that produces the values produced by all the specified Observables in
-- the order they are produced.
-- @arg {Observable...} sources - One or more Observables to merge.
-- @returns {Observable}
function Observable:merge(...)
  local sources = {...}
  table.insert(sources, 1, self)

  return Observable.create(function(observer)
    local function onNext(...)
      return observer:onNext(...)
    end

    local function onError(message)
      return observer:onError(message)
    end

    local function onComplete(i)
      return function()
        sources[i] = nil

        if not next(sources) then
          observer:onComplete()
        end
      end
    end

    for i = 1, #sources do
      sources[i]:subscribe(onNext, onError, onComplete(i))
    end
  end)
end

--- Returns an Observable that produces the values of the original inside tables.
-- @returns {Observable}
function Observable:pack()
  return self:map(pack)
end

--- Returns two Observables: one that produces values for which the predicate returns truthy for,
-- and another that produces values for which the predicate returns falsy.
-- @arg {function} predicate - The predicate used to partition the values.
-- @returns {Observable}
-- @returns {Observable}
function Observable:partition(predicate)
  return self:filter(predicate), self:reject(predicate)
end

--- Returns a new Observable that produces values computed by extracting the given key from the
-- tables produced by the original.
-- @arg {function} key - The key to extract from the table.
-- @returns {Observable}
function Observable:pluck(key, ...)
  if not key then return self end

  return Observable.create(function(observer)
    local function onNext(t)
      return observer:onNext(t[key])
    end

    local function onError(e)
      return observer:onError(e)
    end

    local function onComplete()
      return observer:onComplete()
    end

    return self:subscribe(onNext, onError, onComplete)
  end):pluck(...)
end

--- Returns a new Observable that produces a single value computed by accumulating the results of
-- running a function on each value produced by the original Observable.
-- @arg {function} accumulator - Accumulates the values of the original Observable. Will be passed
--                               the return value of the last call as the first argument and the
--                               current values as the rest of the arguments.
-- @arg {*} seed - A value to pass to the accumulator the first time it is run.
-- @returns {Observable}
function Observable:reduce(accumulator, seed)
  return Observable.create(function(observer)
    local result

    local function onNext(...)
      result = result or seed or (...)
      result = accumulator(result, ...)
    end

    local function onError(e)
      return observer:onError(e)
    end

    local function onComplete()
      observer:onNext(result)
      return observer:onComplete()
    end

    return self:subscribe(onNext, onError, onComplete)
  end)
end

--- Returns a new Observable that produces values from the original which do not satisfy a
-- predicate.
-- @arg {function} predicate - The predicate used to reject values.
-- @returns {Observable}
function Observable:reject(predicate)
  predicate = predicate or identity

  return Observable.create(function(observer)
    local function onNext(...)
      if not predicate(...) then
        return observer:onNext(...)
      end
    end

    local function onError(e)
      return observer:onError(e)
    end

    local function onComplete()
      return observer:onComplete(e)
    end

    return self:subscribe(onNext, onError, onComplete)
  end)
end

--- Returns a new Observable that skips over a specified number of values produced by the original
-- and produces the rest.
-- @arg {number=1} n - The number of values to ignore.
-- @returns {Observable}
function Observable:skip(n)
  n = n or 1

  return Observable.create(function(observer)
    local i = 1

    local function onNext(...)
      if i > n then
        observer:onNext(...)
      else
        i = i + 1
      end
    end

    local function onError(e)
      return observer:onError(e)
    end

    local function onComplete()
      return observer:onComplete()
    end

    return self:subscribe(onNext, onError, onComplete)
  end)
end

--- Returns a new Observable that skips over values produced by the original until the specified
-- Observable produces a value.
-- @arg {Observable} other - The Observable that triggers the production of values.
-- @returns {Observable}
function Observable:skipUntil(other)
  return Observable.create(function(observer)
    local function trigger()
      local function onNext(...)
        return observer:onNext(...)
      end

      local function onError(message)
        return observer:onNext(message)
      end

      local function onComplete()
        return observer:onComplete()
      end

      return self:subscribe(onNext, onError, onComplete)
    end

    other:subscribe(trigger, trigger, trigger)
  end)
end

--- Returns a new Observable that skips elements until the predicate returns falsy for one of them.
-- @arg {function} predicate - The predicate used to continue skipping values.
-- @returns {Observable}
function Observable:skipWhile(predicate)
  predicate = predicate or identity

  return Observable.create(function(observer)
    local skipping = true

    local function onNext(...)
      if skipping then
        skipping = predicate(...)
      end

      if not skipipng then
        return observer:onNext(...)
      end
    end

    local function onError(message)
      return observer:onError(message)
    end

    local function onComplete()
      return observer:onComplete()
    end

    return self:subscribe(onNext, onError, onComplete)
  end)
end

--- Returns a new Observable that only produces the first n results of the original.
-- @arg {number=1} n - The number of elements to produce before completing.
-- @returns {Observable}
function Observable:take(n)
  n = n or 1

  return Observable.create(function(observer)
    if n <= 0 then
      observer:onComplete()
      return
    end

    local i = 1

    local function onNext(...)
      observer:onNext(...)

      i = i + 1

      if i > n then
        observer:onComplete()
      end
    end

    local function onError(e)
      return observer:onError(e)
    end

    local function onComplete()
      return observer:onComplete()
    end

    return self:subscribe(onNext, onError, onComplete)
  end)
end

--- Returns a new Observable that completes when the specified Observable fires.
-- @arg {Observable} other - The Observable that triggers completion of the original.
-- @returns {Observable}
function Observable:takeUntil(other)
  return Observable.create(function(observer)
    local function onNext(...)
      return observer:onNext(...)
    end

    local function onError(e)
      return observer:onError(e)
    end

    local function onComplete()
      return observer:onComplete()
    end

    other:subscribe(onComplete, onComplete, onComplete)

    return self:subscribe(onNext, onError, onComplete)
  end)
end

--- Returns a new Observable that produces elements until the predicate returns falsy.
-- @arg {function} predicate - The predicate used to continue production of values.
-- @returns {Observable}
function Observable:takeWhile(predicate)
  predicate = predicate or identity

  return Observable.create(function(observer)
    local taking = true

    local function onNext(...)
      if taking then
        taking = predicate(...)

        if taking then
          return observer:onNext(...)
        else
          return observer:onComplete()
        end
      end
    end

    local function onError(message)
      return observer:onError(message)
    end

    local function onComplete()
      return observer:onComplete()
    end

    return self:subscribe(onNext, onError, onComplete)
  end)
end

--- Runs a function each time this Observable has activity. Similar to subscribe but does not
-- create a subscription.
-- @arg {function=} onNext - Run when the Observable produces values.
-- @arg {function=} onError - Run when the Observable encounters a problem.
-- @arg {function=} onComplete - Run when the Observable completes.
-- @returns {Observable}
function Observable:tap(_onNext, _onError, _onComplete)
  _onNext, _onError, _onComplete = _onNext or noop, _onError or noop, _onComplete or noop

  return Observable.create(function(observer)
    local function onNext(...)
      _onNext(...)
      return observer:onNext(...)
    end

    local function onError(message)
      _onError(message)
      return observer:onError(message)
    end

    local function onComplete()
      _onComplete()
      return observer:onComplete()
    end

    return self:subscribe(onNext, onError, onComplete)
  end)
end

--- Returns an Observable that unpacks the tables produced by the original.
-- @returns {Observable}
function Observable:unpack()
  return self:map(unpack)
end

--- Returns an Observable that takes any values produced by the original that consist of multiple
-- return values and produces each value individually.
-- @returns {Observable}
function Observable:unwrap()
  return Observable.create(function(observer)
    local function onNext(...)
      local values = {...}
      for i = 1, #values do
        observer:onNext(values[i])
      end
    end

    local function onError(message)
      return observer:onError(message)
    end

    local function onComplete()
      return observer:onComplete()
    end

    return self:subscribe(onNext, onError, onComplete)
  end)
end

--- Returns an Observable that produces a sliding window of the values produced by the original.
-- @arg {number} size - The size of the window. The returned observable will produce this number
--                      of the most recent values as multiple arguments to onNext.
-- @returns {Observable}
function Observable:window(size)
  return Observable.create(function(observer)
    local window = {}

    local function onNext(value)
      table.insert(window, value)

      if #window > size then
        table.remove(window, 1)
        observer:onNext(unpack(window))
      end
    end

    local function onError(message)
      return observer:onError(message)
    end

    local function onComplete()
      return observer:onComplete()
    end

    return self:subscribe(onNext, onError, onComplete)
  end)
end

--- Returns an Observable that produces values from the original along with the most recently
-- produced value from all other specified Observables. Note that only the first argument from each
-- source Observable is used.
-- @arg {Observable...} sources - The Observables to include the most recent values from.
-- @returns {Observable}
function Observable:with(...)
  local sources = {...}

  return Observable.create(function(observer)
    local latest = setmetatable({}, {__len = constant(#sources)})

    local function setLatest(i)
      return function(value)
        latest[i] = value
      end
    end

    local function onNext(value)
      return observer:onNext(value, unpack(latest))
    end

    local function onError(e)
      return observer:onError(e)
    end

    local function onComplete()
      return observer:onComplete()
    end

    for i = 1, #sources do
      sources[i]:subscribe(setLatest(i), noop, noop)
    end

    return self:subscribe(onNext, onError, onComplete)
  end)
end

--- Returns an Observable that buffers values from the original and produces them as multiple
-- values.
-- @arg {number} size - The size of the buffer.
function Observable:wrap(size)
  return Observable.create(function(observer)
    local buffer = {}

    local function emit()
      if #buffer > 0 then
        observer:onNext(unpack(buffer))
        buffer = {}
      end
    end

    local function onNext(...)
      local values = {...}
      for i = 1, #values do
        table.insert(buffer, values[i])
        if #buffer >= size then
          return emit()
        end
      end
    end

    local function onError(message)
      emit()
      return observer:onError(message)
    end

    local function onComplete()
      emit()
      return observer:onComplete()
    end

    return self:subscribe(onNext, onError, onComplete)
  end)
end

function Observable.zip(...)
  local sources = {...}
  local values = {}

  return Observable.create(function(observer)
    local function onNext(i)
      return function(value)
        values[i] = values[i] or {}
        table.insert(values[i], value)
        local ready = true
        for i = 1, #sources do
          if not values[i] or #values[i] == 0 then
            ready = false
            break
          end
        end
        if ready then
          local payload = {}
          for i = 1, #sources do
            payload[i] = values[i][1]
            table.remove(values[i], 1)
          end
          observer:onNext(unpack(payload))
        end
      end
    end

    local function onError(message)
      return observer:onError(message)
    end

    local function onComplete()
      return observer:onComplete()
    end

    for i = 1, #sources do
      sources[i]:subscribe(onNext(i), onError, onComplete)
    end
  end)
end

--- @class Scheduler
-- @description Schedulers manage groups of Observables.
local Scheduler = {}

--- @class ImmediateScheduler
-- @description Schedules Observables by running all operations immediately.
local Immediate = {}
Immediate.__index = Immediate
Immediate.__tostring = constant('ImmediateScheduler')

--- Creates a new Immediate Scheduler.
-- @returns {Scheduler.Immediate}
function Immediate.create()
  return setmetatable({}, Immediate)
end

--- Schedules a function to be run on the scheduler. It is executed immediately.
-- @arg {function} action - The function to execute.
function Immediate:schedule(action)
  action()
end

Scheduler.Immediate = Immediate

--- @class CooperativeScheduler
-- @description Manages Observables using coroutines and a virtual clock that must be updated
-- manually.
local Cooperative = {}
Cooperative.__index = Cooperative
Cooperative.__tostring = constant('CooperativeScheduler')

--- Creates a new Cooperative Scheduler.
-- @arg {number=0} currentTime - A time to start the scheduler at.
-- @returns {Scheduler.Cooperative}
function Cooperative.create(currentTime)
  local self = {
    tasks = {},
    currentTime = currentTime or 0
  }

  return setmetatable(self, Cooperative)
end

--- Schedules a function to be run after an optional delay.
-- @arg {function} action - The function to execute. Will be converted into a coroutine. The
--                          coroutine may yield execution back to the scheduler with an optional
--                          number, which will put it to sleep for a time period.
-- @arg {number=0} delay - Delay execution of the action by a time period.
function Cooperative:schedule(action, delay)
  table.insert(self.tasks, {
    thread = coroutine.create(action),
    due = self.currentTime + (delay or 0)
  })
end

--- Triggers an update of the Cooperative Scheduler. The clock will be advanced and the scheduler
-- will run any coroutines that are due to be run.
-- @arg {number=0} delta - An amount of time to advance the clock by. It is common to pass in the
--                         time in seconds or milliseconds elapsed since this function was last
--                         called.
function Cooperative:update(delta)
  self.currentTime = self.currentTime + (delta or 0)

  for i = #self.tasks, 1, -1 do
    local task = self.tasks[i]

    if self.currentTime >= task.due then
      local success, delay = coroutine.resume(task.thread)

      if success then
        task.due = math.max(task.due + (delay or 0), self.currentTime)
      else
        error(delay)
      end

      if coroutine.status(task.thread) == 'dead' then
        table.remove(self.tasks, i)
      end
    end
  end
end

--- Returns whether or not the Cooperative Scheduler's queue is empty.
function Cooperative:isEmpty()
  return not next(self.tasks)
end

Scheduler.Cooperative = Cooperative

--- @class Subject
-- @description Subjects function both as an Observer and as an Observable. Subjects inherit all
-- Observable functions, including subscribe. Values can also be pushed to the Subject, which will
-- be broadcasted to any subscribed Observers.
local Subject = setmetatable({}, Observable)
Subject.__index = Subject
Subject.__tostring = constant('Subject')

--- Creates a new Subject.
-- @arg {*...} value - The initial values.
-- @returns {Subject}
function Subject.create(...)
  local self = {
    value = {...},
    observers = {}
  }

  return setmetatable(self, Subject)
end

--- Creates a new Observer and attaches it to the Subject.
-- @arg {function} onNext - Called when the Subject produces a value.
-- @arg {function} onError - Called when the Subject terminates due to an error.
-- @arg {function} onComplete - Called when the Subject completes normally.
function Subject:subscribe(onNext, onError, onComplete)
  local observer = Observer.create(onNext, onError, onComplete)
  table.insert(self.observers, observer)
  return self:dispose(observer)
end

function Subject:dispose(observer)
  return function()
    for i = 1, #self.observers do
      if self.observers[i] == observer then
        table.remove(self.observers, i)
        return true
      end
    end
    return false
  end
end

--- Pushes zero or more values to the Subject. It will be broadcasted to all Observers.
-- @arg {*...} values
function Subject:onNext(...)
  self.value = {...}

  for i = 1, #self.observers do
    self.observers[i]:onNext(...)
  end
end

--- Signal to all Observers that an error has occurred.
-- @arg {string=} message - A string describing what went wrong.
function Subject:onError(message)
  for i = 1, #self.observers do
    self.observers[i]:onError(message)
  end
end

--- Signal to all Observers that the Subject will not produce any more values.
function Subject:onComplete()
  for i = 1, #self.observers do
    self.observers[i]:onComplete()
  end
end

--- Returns the last value emitted by the Subject, or the initial value passed to the constructor
-- if nothing has been emitted yet.
-- @returns {*...}
function Subject:getValue()
  return unpack(self.value or {})
end

Subject.__call = Subject.onNext

rx = {
  Observer = Observer,
  Observable = Observable,
  Scheduler = Scheduler,
  scheduler = Scheduler.Immediate.create(),
  Subject = Subject
}

return rx
