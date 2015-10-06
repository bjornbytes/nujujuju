local hud = lib.object.create()

hud.props = {
  font = fonts.existence(g.getHeight() * .05)
}

function hud:bind()
  app.scene.view.hud
    :subscribe(function()
      local u, v = g.getDimensions()
      local props = app.hud.props
      g.setFont(props.font)
      g.setColor(0, 0, 0, 40)

      local margin = .03 * v
      local padding = .015 * v

      local w = g.getFont():getWidth('SHAPESHIFT') + 2 * padding
      g.rectangle('fill', margin, margin, w, g.getFont():getHeight() + 2 * padding)

      g.setColor(255, 255, 255)
      g.print('SHAPESHIFT', margin + padding, margin + padding)

      local props, state = app.muju.props, app.scene.objects.muju.state
      local percent = math.clamp((lib.tick.index - state.lastShapeshift) / (props.shapeshiftCooldown / lib.tick.rate), 0, 1)
      if percent < 1 then
        g.setColor(0, 0, 0, 255 * (.5 - percent / 2))
        g.rectangle('fill', margin + w * percent, margin, w * (1 - percent), g.getFont():getHeight() + 2 * padding)
      end

      local y = 2 * margin + g.getFont():getHeight() + 2 * padding
      local size = .06 * v
      for i = 1, 3 do
        local ability = state.abilities.list[i]

        g.setColor(0, 0, 0, 40)
        g.rectangle('fill', margin, y, size, size)

        if state.abilities.list[i] then
          g.setColor(255, 255, 255, 150 / ((f.try(ability.canUse, ability)) and 1 or 2))
          g.rectangle('line', margin, y, size, size)
        end

        y = y + size + margin / 2
      end

      return -1000
    end)

  return self
end

return hud
