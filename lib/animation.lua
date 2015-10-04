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

  self:set(self.config.default)

  self.events = lib.rx.Subject.create()

  self.animationState.onEvent = function(_, event)
    self.events:onNext(event)
  end

  return self
end

function animation:draw(x, y)
  local skeleton = self.skeleton
  self:setPosition(x, y)
  skeleton.flipX = self.flipped
  if self.config.backwards then skeleton.flipX = not skeleton.flipX end
  self.animationState:apply(skeleton)
  if self.animationState.tracks[0] then
    self.state = self.config.states[self.animationState.tracks[0].animation.name]
  end
  skeleton:updateWorldTransform()
  skeleton:draw()
end

function animation:tick(delta)
  delta = delta or lib.tick.rate
  self.animationState:update(delta * (self.state.speed or 1) * self.speed)
  self.animationState:apply(self.skeleton)
end

function animation:setPosition(x, y)
  local skeleton = self.skeleton
  skeleton.x = x + (self.config.offset.x or 0)
  skeleton.y = y + (self.config.offset.y or 0)
end

function animation:reset(name)
  self.state = self.config.states[name]
  self:clear()
  self.animationState:setAnimationByName(0, name, self.state.loop)
end

function animation:set(name)
  if not self.config.states[name] then return end
  if self.state == self.config.states[name] then return end
  self.state = self.config.states[name]
  self.animationState:setAnimationByName(0, name, self.state.loop)
end

function animation:add(name)
  if not self.config.states[name] then return end
  self.animationState:addAnimationByName(0, name, self.config.states[name].loop)
end

function animation:clear()
  self.animationState:clearTracks()
end

return animation
