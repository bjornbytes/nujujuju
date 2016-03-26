local buff = {}

buff.remove = f.noop

function buff:bind()
  self.timer = self.duration

  return {
    love.update
      :subscribe(self:wrap(self.rot))
  }
end

function buff:rot()
  if self.timer then
    local rate = lib.tick.rate

    self.timer = self.timer - rate
    if self.timer <= 0 then
      self.owner.buffs:remove(self)
    end
  end
end

return buff
