local animation = {}
animation.__index = animation

function animation.create(spine, config)
  local self = setmetatable({}, animation)

  self.spine = spine
  self.config = config

  if spine.atlas then
    self.atlas = lib.spine.Atlas.new(spine.atlas)
    self.atlasAttachmentLoader = lib.spine.AtlasAttachmentLoader.new(self.atlas)
  end

  self.skeletonJson = lib.spine.SkeletonJson.new(self.atlasAttachmentLoader)
  self.skeletonJson.scale = self.config.scale or 1
  self.skeletonData = self.skeletonJson:readSkeletonData(spine.data)
  self.skeleton = lib.spine.Skeleton.new(self.skeletonData)
  self.skeletonBounds = lib.spine.SkeletonBounds.new()

  self.skeleton.createImage = function(_, attachment)
    return spine.images[attachment.name]
  end

  self.skeleton.createAtlasImage = function(_, page)
    return spine.image
  end

  self.animationStateData = lib.spine.AnimationStateData.new(self.skeletonData)
  self.animationState = lib.spine.AnimationState.new(self.animationStateData)

	self.skeleton:setToSetupPose()

  self.speed = 1
  self.flipped = false

  self:resetTo(self.config.default)

  self.events = lib.rx.Subject.create()

  self.animationState.onEvent = function(_, event)
    self.events:onNext(event)
  end

  self.animationState.onEnd = function(track)
    local name = self.animationState.tracks[track].animation.name
    local state = self.config.states[name]
    state.active = false
    if state.next then
      self:set(state.next)
    end
  end

  return self
end

function animation:draw(x, y)
  local skeleton = self.skeleton
  self:setPosition(x, y)
  skeleton.flipX = self.flipped
  if self.config.backwards then skeleton.flipX = not skeleton.flipX end
  self.animationState:apply(skeleton)
  skeleton:updateWorldTransform()
  skeleton:draw()
end

function animation:tick(delta)
  delta = delta or lib.tick.rate

  self.animationState.timeScale = self.speed
  for i = 0, self.animationState.trackCount do
    local track = self.animationState.tracks[i]
    if track then
      local state = self.config.states[track.animation.name]
      self.animationState.tracks[i].timeScale = state.speed
    end
  end

  self.animationState:update(delta)
  self.animationState:apply(self.skeleton)
end

function animation:setPosition(x, y)
  local skeleton = self.skeleton
  skeleton.x = x + (self.config.offset.x or 0)
  skeleton.y = y + (self.config.offset.y or 0)
end

function animation:resetTo(name)
  local state = self.config.states[name]
  if state then
    self:clear()
    local track = state.track or 0
    local loop = state.loop
    state.active = true
    self.animationState:setAnimationByName(track, name, loop)
  end
end

function animation:set(name)
  local state = self.config.states[name]
  if state and not state.active then
    local track = state.track or 0
    local loop = state.loop
    state.active = true
    self.animationState:setAnimationByName(track, name, loop)
  end
end

function animation:clear()
  self.animationState:clearTracks()
end

return animation
