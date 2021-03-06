require "snippets"
require "hex"
local cam = require "camera".new()
local inspect = require "inspect"
local tween = require "tween"
local gr = love.graphics

local hexRad = 350
local hexColor = {0.5, 0.6, 1, 1}
local activeHexColor, passiveHexColor = {0.85, 0, 0, 1}, {0.5, 0.6, 0, 1}
local hexField, hexMesh = newHexField(80, 80, 30, 30, hexRad, passiveHexColor)
--local hexField, hexMesh = newHexField(380, 380, 1, 1, hexRad, passiveHexColor)

function drawRefs(hex)
    gr.setColor{1, 0, 0}
    if hex.refs then
        local x, y = hex.cx, hex.cy
        local rad = 8
        local diff = hexRad / 2
        if hex.refs[1] then
            gr.circle("fill", x - diff, y, rad)
        end
        if hex.refs[2] then
            gr.circle("fill", x - diff, y - diff, rad)
        end
        if hex.refs[3] then
            gr.circle("fill", x + diff, y - diff, rad)
        end
        if hex.refs[4] then
            gr.circle("fill", x + diff, y, rad)
        end
        if hex.refs[5] then
            gr.circle("fill", x + diff, y + diff, rad)
        end
        if hex.refs[6] then
            gr.circle("fill", x - diff, y + diff, rad)
        end
    end
end

love.draw = function()
    gr.setColor{1, 1, 1, 1}

    gr.push()
    --gr.scale(0.05, 0.05)
    --gr.rotate(0.3)

    cam:attach()
    gr.draw(hexMesh)
    for _, v in pairs(hexField) do
        drawRefs(v)
    end
    cam:detach()

    gr.setColor{0, 0.85, 0.1, 0.5}
    --drawHexField(hexField)

    gr.pop()
    
    gr.setColor{1, 1, 1, 1}
    gr.print(string.format("FPS %d", love.timer.getFPS()))

end

function updateSelectedItem(x, y)
    for k, v in pairs(hexField) do
        if pointInPolygon(v, x, y) then
            v:setColor(activeHexColor)
        else
            v:setColor(passiveHexColor)
        end
    end
end

love.mousemoved = function(x, y, dx, dy)
    updateSelectedItem(x, y)
end

love.update = function(dt)
    local lk = love.keyboard

    if lk.isDown("x") then
        cam:zoom(0.99)
    elseif lk.isDown("z") then
        cam:zoom(1.01)
    elseif lk.isDown("a") then
        cam:move(-1, 0)
    elseif lk.isDown("w") then
        cam:move(0, -1)
    elseif lk.isDown("d") then
        cam:move(1, 0)
    elseif lk.isDown("s") then
        cam:move(0, 1)
    end
end

love.keypressed = function(_, k, isrepeat)
    if k == "escape" then
        love.event.quit()
    end
end
