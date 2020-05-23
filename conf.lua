local inspect = require "inspect"
function love.conf(t)
    --print("t", inspect(t))
    t.window.fullscreen = true
    t.window.vsync = false
end
