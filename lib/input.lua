local joystick = love.joystick.getJoysticks()[1]

return love.update
  :map(function()
    if app.context.inspector.gooey.focused then
      return {
        x = 0,
        y = 0,
        building = false,
        shapeshift = false,
        attack = false,
        spells = {false, false, false}
      }
    end

    -- Movement
    local w = love.keyboard.isDown('w', 'up')
    local a = love.keyboard.isDown('a', 'left')
    local s = love.keyboard.isDown('s', 'down')
    local d = love.keyboard.isDown('d', 'right')

    local x, y

    x = a and -1 or (d and 1 or 0)
    y = w and -1 or (s and 1 or 0)

    if joystick then
      x = joystick:getGamepadAxis('leftx')
      y = joystick:getGamepadAxis('lefty')
      if math.abs(x) < .2 then x = 0 end
      if math.abs(y) < .2 then y = 0 end
    end

    -- Building
    local building = love.keyboard.isDown('e')
    if joystick then
      building = joystick:isGamepadDown('x')
    end

    -- Shapeshift
    local shapeshift = love.keyboard.isDown('q')
    if joystick then
      shapeshift = joystick:isGamepadDown('y')
    end

    -- Attack
    local attack = love.keyboard.isDown(' ')
    if joystick then
      attack = joystick:isGamepadDown('a')
    end

    -- Spells
    local spells = {}
    for i = 1, 3 do
      spells[i] = love.keyboard.isDown(tostring(i))
    end

    return {
      x = x,
      y = y,
      building = building,
      shapeshift = shapeshift,
      attack = attack,
      spells = spells
    }
  end)
