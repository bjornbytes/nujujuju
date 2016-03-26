local buffs = lib.object.create()

function buffs:add(key, config)
  self.list = self.list or {}

  local buff = app.buffs[key]:new(util.merge({ owner = self.owner }, config))

  self.list[buff] = buff

  return buff
end

function buffs:remove(buff)
  if not self.list[buff] then return end

  self.list[buff]:remove()
  self.list[buff] = nil

  return buff
end

function buffs:withTag(tag)
  return util.filter(self.list or {}, function(buff)
    return util.find(buff.tags or {}, tag)
  end)
end

function buffs:getFear()
  return util.first(self:withTag('fear'))
end

return buffs
