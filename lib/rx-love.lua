-- RxLove
-- https://github.com/bjornbytes/RxLove
-- MIT License

local events = {
  'directorydropped',
  'draw',
  'filedropped',
  'focus',
  'keypressed',
  'keyreleased',
  'lowmemory',
  'mousefocus',
  'mousemoved',
  'mousepressed',
  'mousereleased',
  'quit',
  'resize',
  'textedited',
  'textinput',
  'touchmoved',
  'touchpressed',
  'touchreleased',
  'threaderror',
  'update',
  'visible',
  'wheelmoved'
}

for _, event in pairs(events) do
  love[event] = lib.rx.Subject.create()
end
