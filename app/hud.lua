local hud = lib.object.create()

hud.props = {
  font = fonts.existence(30)
}

function hud:bind()
  love.draw
    :subscribe(function()
      local props = app.hud.props
      g.setFont(props.font)
      g.setColor(0, 0, 0, 40)
      local w = g.getFont():getWidth('SHAPESHIFT') + 20
      g.rectangle('fill', 20, 20, w, g.getFont():getHeight() + 20)

      g.setColor(255, 255, 255)
      g.print('SHAPESHIFT', 30, 30)

      local props, state = app.muju.props, app.scene.objects.muju.state
      local percent = math.clamp((lib.tick.index - state.lastShapeshift) / (props.shapeshiftCooldown / lib.tick.rate), 0, 1)
      if percent < 1 then
        g.setColor(0, 0, 0, 255 * (.5 - percent / 2))
        g.rectangle('fill', 20 + w * percent, 20, w * (1 - percent), g.getFont():getHeight() + 20)
      end

      return -10000
    end)

  return self
end

return hud
