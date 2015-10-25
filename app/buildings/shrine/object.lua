local shrine = lib.object.create()

shrine:include(lib.obstacle)
shrine:include(lib.building)

shrine.config = app.buildings.shrine.config
shrine.image = app.buildings.shrine.image

shrine.state = function()
  return {
    team = 'player',
    totem = nil
  }
end

function shrine:bind()
  self:setAnchor()
  self:setIsSolid()
  self:setIsBuilding()

  self.collisions = app.context.collision:add(self)

  self:dispose({
    love.update
      :subscribe(self:wrap(self.revertToStartPosition)),

    app.context.view.draw
      :subscribe(self:wrap(self.draw)),

    self.collisions
      :subscribe(function(other, dx, dy)
        if self.totem and other.isEnemy then
          if other.hasContactDamage then
            self.totem:hurt(1)
          end
        end
      end)
  })

  return self
end

function shrine:unbind()
  app.context.collision:remove(self)
  lib.object.unbind(self)
end

function shrine:canInteractWith(player)
  return player.form == 'muju' and not self.totem and player.juju >= self.config.jujuCost
end

function shrine:interact()
  app.context.objects.muju:spendJuju(self.config.jujuCost)
  self.totem = app.totem.object:new({
    shrine = self,
    position = {
      x = self.position.anchor.x,
      y = self.position.anchor.y
    }
  })
  app.context.objects[self.totem] = self.totem
end

function shrine:resetTotem()
  self.totem = nil
end

function shrine:drawUI(u, v)
  local x, y = app.context.view:screenPoint(self.position.anchor.x, self.position.anchor.y)

  if app.context.objects.muju.nearbyBuilding == self and self:canInteractWith(app.context.objects.muju) then
    local font = app.context.hud.font
    local y = y - .05 * v
    local str = 'Build totem?'
    local w, h = font:getWidth(str), font:getHeight()
    local padding = 4
    g.setColor(0, 0, 0, 180)
    g.rectangle('fill', x - w / 2 - padding, y - h / 2 - padding, w + 2 * padding, h + 2 * padding)
    g.white()
    g.print(str, x - font:getWidth(str) / 2, y - font:getHeight() / 2)
  end
end

return shrine
