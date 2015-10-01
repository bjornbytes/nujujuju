return love.update
  :map(function()
    if app.inspector.gooey.focused then
      return {
        x = 0,
        y = 0
      }
    end

    local w = love.keyboard.isDown('w')
    local a = love.keyboard.isDown('a')
    local s = love.keyboard.isDown('s')
    local d = love.keyboard.isDown('d')

    local x, y

    x = a and -1 or (d and 1 or 0)
    y = w and -1 or (s and 1 or 0)

    local joystick = love.joystick.getJoysticks()[1]
    if joystick then
      x = joystick:getGamepadAxis('leftx')
      y = joystick:getGamepadAxis('lefty')
      if math.abs(x) < .2 then x = 0 end
      if math.abs(y) < .2 then y = 0 end
    end

    return {
      x = x,
      y = y
    }
  end)
