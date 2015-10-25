local totemball = lib.object.create()

totemball:include(lib.entity)

function totemball:bind()
  love.update
    :subscribe(function()
      if self.target then
        self.position.x = math.lerp(self.position.x, self.target.position.x, 6 * lib.tick.rate)
        self.position.y = math.lerp(self.position.y, self.target.position.y, 6 * lib.tick.rate)
        if self:distanceTo(self.target) < 4 then
          --
        end
      end
    end)
end

return totemball
